import Foundation
import SoraFoundation
import SoraKeystore
import RobinHood

final class StakingRebondSetupViewFactory: StakingRebondSetupViewFactoryProtocol {
    static func createView(
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel
    ) -> StakingRebondSetupViewProtocol? {
        // MARK: - Interactor

        let settings = SettingsManager.shared

        guard let interactor = createInteractor(
            chain: chain,
            asset: asset,
            selectedAccount: selectedAccount,
            settings: settings
        ) else {
            return nil
        }

        // MARK: - Router

        let wireframe = StakingRebondSetupWireframe()

        // MARK: - Presenter

        let balanceViewModelFactory = BalanceViewModelFactory(
            targetAssetInfo: asset.displayInfo,
            limit: StakingConstants.maxAmount
        )

        let dataValidatingFactory = StakingDataValidatingFactory(presentable: wireframe)

        let presenter = StakingRebondSetupPresenter(
            wireframe: wireframe,
            interactor: interactor,
            balanceViewModelFactory: balanceViewModelFactory,
            dataValidatingFactory: dataValidatingFactory,
            chain: chain,
            asset: asset,
            selectedAccount: selectedAccount
        )

        // MARK: - View

        let localizationManager = LocalizationManager.shared

        let view = StakingRebondSetupViewController(
            presenter: presenter,
            localizationManager: localizationManager
        )
        view.localizationManager = localizationManager

        presenter.view = view
        dataValidatingFactory.view = view
        interactor.presenter = presenter

        return view
    }

    private static func createInteractor(
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel,
        settings _: SettingsManagerProtocol
    ) -> StakingRebondSetupInteractor? {
        let chainRegistry = ChainRegistryFacade.sharedRegistry

        guard
            let connection = chainRegistry.getConnection(for: chain.chainId),
            let runtimeService = chainRegistry.getRuntimeProvider(for: chain.chainId),
            let accountResponse = selectedAccount.fetch(for: chain.accountRequest()) else {
            return nil
        }

        let operationManager = OperationManagerFacade.sharedManager

        let extrinsicService = ExtrinsicService(
            accountId: accountResponse.accountId,
            chainFormat: chain.chainFormat,
            cryptoType: accountResponse.cryptoType,
            runtimeRegistry: runtimeService,
            engine: connection,
            operationManager: operationManager
        )

        let substrateStorageFacade = SubstrateDataStorageFacade.shared
        let logger = Logger.shared

        let priceLocalSubscriptionFactory = PriceProviderFactory(storageFacade: substrateStorageFacade)
        let stakingLocalSubscriptionFactory = StakingLocalSubscriptionFactory(
            chainRegistry: chainRegistry,
            storageFacade: substrateStorageFacade,
            operationManager: operationManager,
            logger: Logger.shared
        )

        let walletLocalSubscriptionFactory = WalletLocalSubscriptionFactory(
            chainRegistry: chainRegistry,
            storageFacade: substrateStorageFacade,
            operationManager: operationManager,
            logger: logger
        )

        let feeProxy = ExtrinsicFeeProxy()

        return StakingRebondSetupInteractor(
            priceLocalSubscriptionFactory: priceLocalSubscriptionFactory,
            walletLocalSubscriptionFactory: walletLocalSubscriptionFactory,
            stakingLocalSubscriptionFactory: stakingLocalSubscriptionFactory,
            runtimeCodingService: runtimeService,
            operationManager: operationManager,
            feeProxy: feeProxy,
            chain: chain,
            asset: asset,
            selectedAccount: selectedAccount,
            connection: connection,
            extrinsicService: extrinsicService
        )
    }
}
