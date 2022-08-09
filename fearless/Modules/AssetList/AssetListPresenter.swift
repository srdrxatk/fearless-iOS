final class AssetListPresenter {
    private let interactor: AssetListInteractorInput
    private let viewModelFactory: AssetListViewModelFactoryProtocol
    private let wallet: MetaAccountModel
    private var chainAssets: [ChainAsset]?
    
    private var accountInfos: [ChainAssetKey: AccountInfo?] = [:]
    private var prices: PriceDataUpdated = ([], false)

    init(
        interactor: AssetListInteractorInput,
        wallet: MetaAccountModel,
        viewModelFactory: AssetListViewModelFactoryProtocol
    ) {
        self.interactor = interactor
        self.wallet = wallet
        self.viewModelFactory = viewModelFactory
    }
}

private extension AssetListPresenter {
    private func provideViewModel() {
        guard let chainAssets = chainAssets else {
            return
        }
        
        let viewModel = viewModelFactory.buildViewModel(
            selectedMetaAccount: wallet,
            chainAssets: chainAssets,
            locale: <#T##Locale#>,
            accountInfos: accountInfos,
            prices: prices)

        view?.didReceive(state: .loaded(viewModel: viewModel))
    }
}

extension AssetListPresenter: AssetListModuleInput {
    func updateChainAssets(
        using filters: [ChainAssetsFetching.Filter],
        sorts: [ChainAssetsFetching.SortDescriptor]
    ) {
        interactor.updateChainAssets(using: filters, sorts: sorts)
    }
}

extension AssetListPresenter: AssetListInteractorOutput {
    func didReceiveChainAssets(result: Result<[ChainAsset], Error>) {
        switch result {
        case let .success(chainAssets):
            self.chainAssets = chainAssets
            provideViewModel()
        case let .failure(error):
            break
//            _ = wireframe.present(error: error, from: view, locale: selectedLocale)
        }
    }

    func didReceiveAccountInfo(result: Result<AccountInfo?, Error>, for chainAsset: ChainAsset) {
        switch result {
        case let .success(accountInfo):
            guard let accountId = wallet.fetch(for: chainAsset.chain.accountRequest())?.accountId else {
                return
            }
            let key = chainAsset.uniqueKey(accountId: accountId)
            accountInfos[key] = accountInfo
        case let .failure(error):
            break
//            wireframe.present(error: error, from: view, locale: selectedLocale)
        }
        provideViewModel()
    }

    func didReceivePricesData(result: Result<[PriceData], Error>) {
        switch result {
        case let .success(priceDataResult):
            let priceDataUpdated = (pricesData: priceDataResult, updated: true)
            prices = priceDataUpdated
        case let .failure(error):
            break
//            wireframe.present(error: error, from: view, locale: selectedLocale)
        }

        provideViewModel()
    }
}
