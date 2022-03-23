import UIKit
import RobinHood
import IrohaCrypto
import SoraFoundation

final class ChainAccountBalanceListInteractor {
    weak var presenter: ChainAccountBalanceListInteractorOutputProtocol?

    let selectedMetaAccount: MetaAccountModel
    let chainRepository: AnyDataProviderRepository<ChainModel>
    let assetRepository: AnyDataProviderRepository<AssetModel>
    let accountInfoSubscriptionAdapter: AccountInfoSubscriptionAdapterProtocol
    let operationQueue: OperationQueue
    let priceLocalSubscriptionFactory: PriceProviderFactoryProtocol
    let eventCenter: EventCenterProtocol

    var chains: [ChainModel]?

    private var priceProviders: [AnySingleValueProvider<PriceData>]?

    init(
        selectedMetaAccount: MetaAccountModel,
        chainRepository: AnyDataProviderRepository<ChainModel>,
        assetRepository: AnyDataProviderRepository<AssetModel>,
        accountInfoSubscriptionAdapter: AccountInfoSubscriptionAdapterProtocol,
        operationQueue: OperationQueue,
        priceLocalSubscriptionFactory: PriceProviderFactoryProtocol,
        eventCenter: EventCenterProtocol
    ) {
        self.selectedMetaAccount = selectedMetaAccount
        self.chainRepository = chainRepository
        self.assetRepository = assetRepository
        self.accountInfoSubscriptionAdapter = accountInfoSubscriptionAdapter
        self.operationQueue = operationQueue
        self.priceLocalSubscriptionFactory = priceLocalSubscriptionFactory
        self.eventCenter = eventCenter
    }

    private func fetchChainsAndSubscribeBalance() {
        let fetchOperation = chainRepository.fetchAllOperation(with: RepositoryFetchOptions())

        fetchOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.handleChains(result: fetchOperation.result)
            }
        }

        operationQueue.addOperation(fetchOperation)
    }

    private func handleChains(result: Result<[ChainModel], Error>?) {
        switch result {
        case let .success(chains):
            self.chains = chains

            let accountSupportsEthereum = SelectedWalletSettings.shared.value?.ethereumPublicKey != nil

            let filteredChains: [ChainModel] = accountSupportsEthereum ? chains : chains.filter { $0.isEthereumBased == false }
            presenter?.didReceiveChains(result: .success(filteredChains))
            subscribeToAccountInfo(for: filteredChains)
            subscribeToPrice(for: filteredChains)
        case let .failure(error):
            presenter?.didReceiveChains(result: .failure(error))
        case .none:
            presenter?.didReceiveChains(result: .failure(BaseOperationError.parentOperationCancelled))
        }
    }

    private func subscribeToPrice(for chains: [ChainModel]) {
        var providers: [AnySingleValueProvider<PriceData>] = []

        for chain in chains {
            for asset in chain.assets {
                if
                    let priceId = asset.asset.priceId,
                    let dataProvider = subscribeToPrice(for: priceId) {
                    providers.append(dataProvider)
                }
            }
        }

        priceProviders = providers
    }

    private func subscribeToAccountInfo(for chains: [ChainModel]) {
        accountInfoSubscriptionAdapter.subscribe(chains: chains, handler: self)
    }

    private func refreshChain(_: ChainModel) {}
}

extension ChainAccountBalanceListInteractor: PriceLocalStorageSubscriber, PriceLocalSubscriptionHandler {
    func handlePrice(result: Result<PriceData?, Error>, priceId: AssetModel.PriceId) {
        switch result {
        case let .success(priceData):
            let chainAsset = chains?.compactMap { Array($0.assets) }.reduce([], +).first(where: { $0?.asset.priceId == priceId })
            if let asset = chainAsset?.asset,
               let price = priceData?.price {
                let updatedAsset = asset.replacingPrice(Decimal(string: price))

                let saveOperation = assetRepository.saveOperation {
                    [updatedAsset]
                } _: {
                    []
                }

                operationQueue.addOperation(saveOperation)
            }
        case .failure:
            break
        }

        presenter?.didReceivePriceData(result: result, for: priceId)
    }
}

extension ChainAccountBalanceListInteractor: ChainAccountBalanceListInteractorInputProtocol {
    func setup() {
        eventCenter.add(observer: self, dispatchIn: .main)

        fetchChainsAndSubscribeBalance()

        presenter?.didReceiveSelectedAccount(selectedMetaAccount)
    }

    func refresh() {
        fetchChainsAndSubscribeBalance()
    }
}

extension ChainAccountBalanceListInteractor: AccountInfoSubscriptionAdapterHandler {
    func handleAccountInfo(
        result: Result<AccountInfo?, Error>,
        accountId _: AccountId,
        chainId: ChainModel.Id
    ) {
        presenter?.didReceiveAccountInfo(result: result, for: chainId)
    }
}

extension ChainAccountBalanceListInteractor: EventVisitorProtocol {
    func processSelectedAccountChanged(event _: SelectedAccountChanged) {
        refresh()
    }

    func processChainSyncDidComplete(event _: ChainSyncDidComplete) {
        refresh()
    }

    func processChainsUpdated(event _: ChainsUpdatedEvent) {
        refresh()
    }

    func processSelectedConnectionChanged(event _: SelectedConnectionChanged) {
        refresh()
    }
}

extension ChainAccountBalanceListInteractor: ApplicationHandlerDelegate {
    func didReceiveDidBecomeActive(notification _: Notification) {
        refresh()
    }
}

extension ChainAccountBalanceListInteractor: AnyProviderAutoCleaning {}
