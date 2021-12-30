final class StakingBalanceWireframe: StakingBalanceWireframeProtocol {
    func showBondMore(
        from view: ControllerBackedProtocol?,
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel
    ) {
        guard let bondMoreView = StakingBondMoreViewFactory.createView(
            asset: asset,
            chain: chain,
            selectedAccount: selectedAccount
        ) else { return }
        let navigationController = ImportantFlowViewFactory.createNavigation(from: bondMoreView.controller)
        view?.controller.present(navigationController, animated: true, completion: nil)
    }

    func showUnbond(
        from view: ControllerBackedProtocol?,
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel
    ) {
        guard let unbondView = StakingUnbondSetupViewFactory.createView(
            chain: chain,
            asset: asset,
            selectedAccount: selectedAccount
        ) else {
            return
        }

        let navigationController = ImportantFlowViewFactory.createNavigation(from: unbondView.controller)

        view?.controller.present(navigationController, animated: true, completion: nil)
    }

    func showRedeem(
        from view: ControllerBackedProtocol?,
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel
    ) {
        guard let redeemView = StakingRedeemViewFactory.createView(
            chain: chain,
            asset: asset,
            selectedAccount: selectedAccount
        ) else {
            return
        }

        let navigationController = ImportantFlowViewFactory.createNavigation(from: redeemView.controller)

        view?.controller.present(navigationController, animated: true, completion: nil)
    }

    func showRebond(
        from view: ControllerBackedProtocol?,
        option: StakingRebondOption,
        chain: ChainModel,
        asset: AssetModel,
        selectedAccount: MetaAccountModel
    ) {
        let rebondView: ControllerBackedProtocol? = {
            switch option {
            case .all:
                return StakingRebondConfirmationViewFactory.createView(
                    chain: chain,
                    asset: asset,
                    selectedAccount: selectedAccount,
                    variant: .all
                )
            case .last:
                return StakingRebondConfirmationViewFactory.createView(
                    chain: chain,
                    asset: asset,
                    selectedAccount: selectedAccount,
                    variant: .last
                )
            case .customAmount:
                return StakingRebondSetupViewFactory.createView(
                    chain: chain,
                    asset: asset,
                    selectedAccount: selectedAccount
                )
            }
        }()

        guard let controller = rebondView?.controller else {
            return
        }

        let navigationController = ImportantFlowViewFactory.createNavigation(from: controller)

        view?.controller.present(navigationController, animated: true, completion: nil)
    }

    func cancel(from view: ControllerBackedProtocol?) {
        view?.controller.navigationController?.popViewController(animated: true)
    }
}
