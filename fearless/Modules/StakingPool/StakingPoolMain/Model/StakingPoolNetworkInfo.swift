import Foundation
import Web3

struct StakingPoolNetworkInfo {
    let minJoinBond: BigUInt?
    let minCreateBond: BigUInt?
    let existingPoolsCount: UInt32?
    let possiblePoolsCount: UInt32?
    let maxMembersInPool: UInt32?
    let maxPoolsMembers: UInt32?
}
