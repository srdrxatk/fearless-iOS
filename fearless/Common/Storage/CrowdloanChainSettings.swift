import Foundation
import SoraKeystore
import RobinHood

final class CrowdloanChainSettings: PersistentValueSettings<ChainModel> {
    let settings: SettingsManagerProtocol
    let operationQueue: OperationQueue

    init(
        storageFacade: StorageFacadeProtocol,
        settings: SettingsManagerProtocol,
        operationQueue: OperationQueue
    ) {
        self.settings = settings
        self.operationQueue = operationQueue

        super.init(storageFacade: storageFacade)
    }

    override func performSetup(completionClosure: @escaping (Result<ChainModel?, Error>) -> Void) {
        let repository: AnyDataProviderRepository<ChainModel>
        let mapper = AnyCoreDataMapper(ChainModelMapper())

        let maybeChainId = settings.crowdloanChainId

        if let chainId = maybeChainId {
            let filter = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate.chainBy(identifier: chainId),
                NSPredicate.relayChains()
            ])

            repository = AnyDataProviderRepository(
                storageFacade.createRepository(filter: filter, sortDescriptors: [], mapper: mapper)
            )
        } else {
            let filter = NSPredicate.relayChains()
            repository = AnyDataProviderRepository(
                storageFacade.createRepository(filter: filter, sortDescriptors: [], mapper: mapper)
            )
        }

        let fetchOperation = repository.fetchAllOperation(with: RepositoryFetchOptions())

        let mappingOperation = ClosureOperation<ChainModel?> {
            let chains = try fetchOperation.extractNoCancellableResultData()

            if let selectedChain = chains.first(where: { $0.chainId == maybeChainId }) {
                return selectedChain
            }

            if let firstRelayChain = chains.min(by: { $0.addressPrefix < $1.addressPrefix }) {
                self.settings.crowdloanChainId = firstRelayChain.chainId
                return firstRelayChain
            }

            return nil
        }

        mappingOperation.addDependency(fetchOperation)

        mappingOperation.completionBlock = {
            do {
                let result = try mappingOperation.extractNoCancellableResultData()
                completionClosure(.success(result))
            } catch {
                completionClosure(.failure(error))
            }
        }

        operationQueue.addOperations([fetchOperation, mappingOperation], waitUntilFinished: false)
    }

    override func performSave(
        value: ChainModel,
        completionClosure: @escaping (Result<ChainModel, Error>
        ) -> Void
    ) {
        settings.crowdloanChainId = value.chainId
        completionClosure(.success(value))
    }
}
