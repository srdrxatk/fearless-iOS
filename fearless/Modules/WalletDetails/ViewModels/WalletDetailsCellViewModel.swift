import UIKit

struct WalletDetailsCellViewModel {
    let chainImageViewModel: RemoteImageViewModel?
    let chainAccount: ChainAccountInfo
    let addressImage: UIImage?
    let address: String?
    let actionsAvailable: Bool
}
