import UIKit
import SoraFoundation
import SoraKeystore
import CommonWallet

final class MainTabBarViewFactory: MainTabBarViewFactoryProtocol {
    static let walletIndex: Int = 0
    static let crowdloanIndex: Int = 1

    static func createView() -> MainTabBarViewProtocol? {
        guard let keystoreImportService: KeystoreImportServiceProtocol = URLHandlingService.shared
            .findService()
        else {
            Logger.shared.error("Can't find required keystore import service")
            return nil
        }

        let localizationManager = LocalizationManager.shared

        let serviceCoordinator = ServiceCoordinator.createDefault()

        let interactor = MainTabBarInteractor(
            eventCenter: EventCenter.shared,
            serviceCoordinator: serviceCoordinator,
            keystoreImportService: keystoreImportService
        )

        let presenter = MainTabBarPresenter()

        guard
            let walletController = createWalletController(
                localizationManager: localizationManager
            )
        else {
            return nil
        }

        guard let stakingController = createStakingController(for: localizationManager) else {
            return nil
        }

        // TODO: Move setup to loading state
        let crowdloanState = CrowdloanSharedState()
        crowdloanState.settings.setup()

        guard let crowdloanController = createCrowdloanController(
            for: localizationManager,
            state: crowdloanState
        ) else {
            return nil
        }

        guard let settingsController = createProfileController(for: localizationManager) else {
            return nil
        }

        let view = MainTabBarViewController(
            presenter: presenter,
            localizationManager: LocalizationManager.shared
        )
        view.viewControllers = [
            walletController,
            crowdloanController,
            stakingController,
            settingsController
        ]

        let wireframe = MainTabBarWireframe()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.wireframe = wireframe
        interactor.presenter = presenter

        return view
    }

    static func reloadWalletView(
        on view: MainTabBarViewProtocol,
        wireframe _: MainTabBarWireframeProtocol
    ) {
        let localizationManager = LocalizationManager.shared

        guard
            let walletController = createWalletController(
                localizationManager: localizationManager
            )
        else {
            return
        }

        view.didReplaceView(for: walletController, for: Self.walletIndex)
    }

    static func reloadCrowdloanView(on view: MainTabBarViewProtocol) -> UIViewController? {
        let localizationManager = LocalizationManager.shared

        // TODO: Move setup to loading state
        let crowdloanState = CrowdloanSharedState()
        crowdloanState.settings.setup()

        guard let crowdloanController = createCrowdloanController(
            for: localizationManager,
            state: crowdloanState
        ) else {
            return nil
        }

        view.didReplaceView(for: crowdloanController, for: Self.crowdloanIndex)

        return crowdloanController
    }

    static func createWalletController(
        localizationManager: LocalizationManagerProtocol
    ) -> UIViewController? {
        do {
            guard let viewController = ChainAccountBalanceListViewFactory.createView()?.controller else {
                return nil
            }

            let localizableTitle = LocalizableResource { locale in
                R.string.localizable.tabbarWalletTitle(preferredLanguages: locale.rLanguages)
            }

            let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
            let icon = R.image.iconTabWallet()
            let normalIcon = icon?.tinted(with: R.color.colorGray()!)?
                .withRenderingMode(.alwaysOriginal)
            let selectedIcon = icon?.tinted(with: R.color.colorWhite()!)?
                .withRenderingMode(.alwaysOriginal)
            viewController.tabBarItem = createTabBarItem(
                title: currentTitle,
                normalImage: normalIcon,
                selectedImage: selectedIcon
            )

            localizationManager.addObserver(with: viewController) { [weak viewController] _, _ in
                let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
                viewController?.tabBarItem.title = currentTitle
            }

            let navigationController = FearlessNavigationController(rootViewController: viewController)

            return navigationController
        } catch {
            Logger.shared.error("Can't create wallet: \(error)")

            return nil
        }
    }

    static func createStakingController(
        for localizationManager: LocalizationManagerProtocol
    ) -> UIViewController? {
        // TODO: Remove when staking is fixed
        let viewController = StakingMainViewFactory.createView()?.controller ?? UIViewController()

        let localizableTitle = LocalizableResource { locale in
            R.string.localizable.tabbarStakingTitle(preferredLanguages: locale.rLanguages)
        }

        let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
        let icon = R.image.iconTabStaking()
        let normalIcon = icon?.tinted(with: R.color.colorGray()!)?
            .withRenderingMode(.alwaysOriginal)
        let selectedIcon = icon?.tinted(with: R.color.colorWhite()!)?
            .withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem = createTabBarItem(
            title: currentTitle,
            normalImage: normalIcon,
            selectedImage: selectedIcon
        )

        localizationManager.addObserver(with: viewController) { [weak viewController] _, _ in
            let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
            viewController?.tabBarItem.title = currentTitle
        }

        let navigationController = FearlessNavigationController(rootViewController: viewController)

        return navigationController
    }

    static func createProfileController(
        for localizationManager: LocalizationManagerProtocol
    ) -> UIViewController? {
        // TODO: Remove when settings fixed
        let viewController = ProfileViewFactory.createView()?.controller ?? UIViewController()

        let navigationController = FearlessNavigationController(rootViewController: viewController)

        let localizableTitle = LocalizableResource { locale in
            R.string.localizable.tabbarSettingsTitle(preferredLanguages: locale.rLanguages)
        }

        let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
        let icon = R.image.iconTabSettings()
        let normalIcon = icon?.tinted(with: R.color.colorGray()!)?
            .withRenderingMode(.alwaysOriginal)
        let selectedIcon = icon?.tinted(with: R.color.colorWhite()!)?
            .withRenderingMode(.alwaysOriginal)
        navigationController.tabBarItem = createTabBarItem(
            title: currentTitle,
            normalImage: normalIcon,
            selectedImage: selectedIcon
        )

        localizationManager.addObserver(with: navigationController) { [weak navigationController] _, _ in
            let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
            navigationController?.tabBarItem.title = currentTitle
        }

        return navigationController
    }

    static func createCrowdloanController(
        for localizationManager: LocalizationManagerProtocol,
        state: CrowdloanSharedState
    ) -> UIViewController? {
        guard let crowloanView = CrowdloanListViewFactory.createView(
            with: state
        ) else {
            return nil
        }

        let navigationController = FearlessNavigationController(rootViewController: crowloanView.controller)

        let localizableTitle = LocalizableResource { locale in
            R.string.localizable.tabbarCrowdloanTitle_v190(preferredLanguages: locale.rLanguages)
        }

        let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
        let icon = R.image.iconTabCrowloan()
        let normalIcon = icon?.tinted(with: R.color.colorGray()!)?
            .withRenderingMode(.alwaysOriginal)
        let selectedIcon = icon?.tinted(with: R.color.colorWhite()!)?
            .withRenderingMode(.alwaysOriginal)
        navigationController.tabBarItem = createTabBarItem(
            title: currentTitle,
            normalImage: normalIcon,
            selectedImage: selectedIcon
        )

        localizationManager.addObserver(with: navigationController) { [weak navigationController] _, _ in
            let currentTitle = localizableTitle.value(for: localizationManager.selectedLocale)
            navigationController?.tabBarItem.title = currentTitle
        }

        return navigationController
    }

    static func createTabBarItem(
        title: String,
        normalImage: UIImage?,
        selectedImage: UIImage?
    ) -> UITabBarItem {
        let tabBarItem = UITabBarItem(
            title: title,
            image: normalImage,
            selectedImage: selectedImage
        )

        // Style is set here for compatibility reasons for iOS 12.x and less.
        // For iOS 13 styling see MainTabBarViewController's 'configure' method.

        if #available(iOS 13.0, *) {
            return tabBarItem
        }

        let normalAttributes = [NSAttributedString.Key.foregroundColor: R.color.colorGray()!]
        let selectedAttributes = [NSAttributedString.Key.foregroundColor: R.color.colorWhite()!]

        tabBarItem.setTitleTextAttributes(normalAttributes, for: .normal)
        tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)

        return tabBarItem
    }
}
