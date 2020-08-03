import UIKit
import IrohaCrypto

final class AccountCreateInteractor {
    weak var presenter: AccountCreateInteractorOutputProtocol!

    let mnemonicCreator: IRMnemonicCreatorProtocol

    init(mnemonicCreator: IRMnemonicCreatorProtocol) {
        self.mnemonicCreator = mnemonicCreator
    }
}

extension AccountCreateInteractor: AccountCreateInteractorInputProtocol {
    func setup() {
        do {
            let mnemonic = try mnemonicCreator.randomMnemonic(.entropy128)

            let availableAccountTypes: [SNAddressType] = [.kusamaMain, .polkadotMain, .genericSubstrate]
            let metadata = AccountCreationMetadata(mnemonic: mnemonic.allWords(),
                                                   availableAccountTypes: availableAccountTypes,
                                                   defaultAccountType: .kusamaMain,
                                                   availableCryptoTypes: CryptoType.allCases,
                                                   defaultCryptoType: .sr25519)
            presenter.didReceive(metadata: metadata)
        } catch {
            presenter.didReceiveMnemonicGeneration(error: error)
        }
    }

    func createAccount(request: AccountCreationRequest) {}
}
