import Foundation
import Web3

typealias DecodedOrmlAccountInfo = ChainStorageDecodedItem<OrmlAccountInfo>
typealias DecodedAccountInfo = ChainStorageDecodedItem<AccountInfo>
typealias DecodedBigUInt = ChainStorageDecodedItem<StringScaleMapper<BigUInt>>
typealias DecodedU32 = ChainStorageDecodedItem<StringScaleMapper<UInt32>>
typealias DecodedNomination = ChainStorageDecodedItem<Nomination>
typealias DecodedValidator = ChainStorageDecodedItem<ValidatorPrefs>
typealias DecodedLedgerInfo = ChainStorageDecodedItem<StakingLedger>
typealias DecodedActiveEra = ChainStorageDecodedItem<ActiveEraInfo>
typealias DecodedEraIndex = ChainStorageDecodedItem<StringScaleMapper<EraIndex>>
typealias DecodedPayee = ChainStorageDecodedItem<RewardDestinationArg>
typealias DecodedBlockNumber = ChainStorageDecodedItem<StringScaleMapper<BlockNumber>>
typealias DecodedCrowdloanFunds = ChainStorageDecodedItem<CrowdloanFunds>
typealias DecodedBalanceLocks = ChainStorageDecodedItem<BalanceLock>
typealias DecodedParachainStakingCandidate = ChainStorageDecodedItem<ParachainStakingCandidate>
typealias DecodedParachainDelegatorState = ChainStorageDecodedItem<ParachainStakingDelegatorState>
typealias DecodedParachainScheduledRequests = ChainStorageDecodedItem<[ParachainStakingScheduledRequest]>
typealias DecodedPoolMember = ChainStorageDecodedItem<StakingPoolMember>
