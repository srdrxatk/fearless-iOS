import Foundation

final class StakingPoolCreateConfirmRouter: StakingPoolCreateConfirmRouterInput {
    func finish(view: ControllerBackedProtocol?) {
        view?.controller.navigationController?.dismiss(
            animated: true,
            completion: nil
        )
    }

    func complete(
        on view: ControllerBackedProtocol?,
        extrinsicHash: String,
        text: String,
        closure: (() -> Void)?
    ) {
        guard let view = view else {
            return
        }
        let presenter = view.controller.navigationController?.presentingViewController

        if let presenter = presenter as? ControllerBackedProtocol {
            presentDone(description: text, extrinsicHash: extrinsicHash, from: presenter, closure: closure)
        }
    }

    func proceedToSelectValidatorsStart(
        from view: ControllerBackedProtocol?,
        poolId: UInt32,
        state: InitiatedBonding,
        chainAsset: ChainAsset,
        wallet: MetaAccountModel
    ) {
        guard let recommendedView = SelectValidatorsStartViewFactory
            .createView(
                wallet: wallet,
                chainAsset: chainAsset,
                flow: .poolInitiated(poolId: poolId, state: state)
            )
        else {
            return
        }

        view?.controller.navigationController?.pushViewController(recommendedView.controller, animated: true)
    }
}
