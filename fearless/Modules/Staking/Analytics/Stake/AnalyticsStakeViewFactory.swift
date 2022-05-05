import Foundation
import SoraKeystore
import SoraFoundation

struct AnalyticsStakeViewFactory {
    static func createView() -> AnalyticsStakeViewProtocol? {
        let settings = SettingsManager.shared
        let operationManager = OperationManagerFacade.sharedManager

        let networkType = settings.selectedConnection.type
        let primitiveFactory = WalletPrimitiveFactory(settings: settings)
        let asset = primitiveFactory.createAssetForAddressType(networkType)
        let addressType = settings.selectedConnection.type
        let chain = addressType.chain
        guard
            let accountAddress = settings.selectedAccount?.address,
            let assetId = WalletAssetId(rawValue: asset.identifier),
            let selectedMetaAccount = SelectedWalletSettings.shared.value
        else {
            return nil
        }

        let substrateProviderFactory = SubstrateDataProviderFactory(
            facade: SubstrateDataStorageFacade.shared,
            operationManager: operationManager
        )
        let interactor = AnalyticsStakeInteractor(
            singleValueProviderFactory: SingleValueProviderFactory.shared,
            substrateProviderFactory: substrateProviderFactory,
            operationManager: operationManager,
            selectedAccountAddress: accountAddress,
            assetId: assetId,
            chain: chain
        )
        let wireframe = AnalyticsStakeWireframe()

        let targetAssetInfo = AssetBalanceDisplayInfo.forCurrency(selectedMetaAccount.selectedCurrency)
        let balanceViewModelFactory = BalanceViewModelFactory(
            targetAssetInfo: targetAssetInfo,
            selectedMetaAccount: selectedMetaAccount
        )
        let viewModelFactory = AnalyticsStakeViewModelFactory(
            assetInfo: targetAssetInfo,
            balanceViewModelFactory: balanceViewModelFactory,
            calendar: Calendar(identifier: .gregorian)
        )
        let presenter = AnalyticsStakePresenter(
            interactor: interactor,
            wireframe: wireframe,
            viewModelFactory: viewModelFactory,
            localizationManager: LocalizationManager.shared
        )

        let view = AnalyticsStakeViewController(presenter: presenter, localizationManager: LocalizationManager.shared)

        presenter.view = view
        interactor.presenter = presenter

        return view
    }
}
