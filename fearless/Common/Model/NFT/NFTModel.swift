import Foundation
import SSFModels

struct NFT: Codable, Equatable, Hashable {
    let chain: ChainModel
    let tokenId: String?
    let title: String?
    let description: String?
    let smartContract: String?
    let metadata: NFTMetadata?
    let mediaThumbnail: String?
    let media: [NFTMedia]?
    let tokenType: NFTTokenType?
    let collectionName: String?
    let collection: NFTCollection?

    var thumbnailURL: URL? {
        if let mediaThumbnail = mediaThumbnail {
            return URL(string: mediaThumbnail)
        }

        if metadata?.imageURL != nil {
            return metadata?.imageURL
        }

        return media?.first(where: { $0.isImage })?.normalizedURL
    }

    var displayDescription: String? {
        if let description = description, description.isNotEmpty {
            return description
        }

        if let description = metadata?.description, description.isNotEmpty {
            return description
        }

        return collection?.opensea?.description
    }

    var displayName: String? {
        if let name = title, name.isNotEmpty {
            return name
        }

        if let name = metadata?.name, name.isNotEmpty {
            return name
        }

        if let collectionName = collection?.displayName, let tokenId = tokenId {
            return "\(collectionName) #\(tokenId)"
        }

        if let tokenId = tokenId {
            return "#\(tokenId)"
        }

        return nil
    }

    init(
        chain: ChainModel,
        tokenId: String?,
        title: String?,
        description: String?,
        smartContract: String?,
        metadata: NFTMetadata?,
        mediaThumbnail: String?,
        media: [NFTMedia]?,
        tokenType: NFTTokenType?,
        collectionName: String?,
        collection: NFTCollection?
    ) {
        self.chain = chain
        self.tokenId = tokenId
        self.title = title
        self.description = description
        self.smartContract = smartContract
        self.metadata = metadata
        self.mediaThumbnail = mediaThumbnail
        self.media = media
        self.tokenType = tokenType
        self.collectionName = collectionName
        self.collection = collection
    }

    init(nft: NFT, collection: NFTCollection) {
        chain = nft.chain
        tokenId = nft.tokenId
        title = nft.title
        description = nft.description
        smartContract = nft.smartContract
        metadata = nft.metadata
        mediaThumbnail = nft.mediaThumbnail
        media = nft.media
        tokenType = nft.tokenType
        collectionName = nft.collectionName
        self.collection = collection
    }
}

enum NFTTokenType: String, Codable {
    case erc721 = "ERC721"
    case erc1155 = "ERC1155"
}

struct NFTMetadata: Codable, Equatable, Hashable {
    let name: String?
    let description: String?
    let image: String?

    var imageURL: URL? {
        guard let image = image, let url = URL(string: image) else {
            return nil
        }

        return url.normalizedIpfsURL
    }
}

struct NFTMedia: Codable, Equatable, Hashable {
    let thumbnail: String?
    let mediaPath: String?
    let format: String?

    var normalizedThumbnailURL: URL? {
        guard let thumbnail = thumbnail, let url = URL(string: thumbnail) else {
            return nil
        }

        return url.normalizedIpfsURL
    }

    var normalizedURL: URL? {
        guard let mediaPath = mediaPath, let url = URL(string: mediaPath) else {
            return nil
        }

        return url.normalizedIpfsURL
    }

    var isImage: Bool {
        guard let format = format else {
            return false
        }

        return MimePathExtensions.imageExtensions.contains(format)
    }

    var isVideo: Bool {
        guard let format = format else {
            return false
        }

        return MimePathExtensions.videoExtensions.contains(format)
    }
}

struct NFTCollection: Codable, Equatable, Hashable {
    let address: String?
    let numberOfTokens: UInt32?
    let isSpam: Bool?
    let title: String?
    let name: String?
    let creator: String?
    let price: Float?
    let media: [NFTMedia]?
    let tokenType: NFTTokenType?
    let desc: String?
    let opensea: AlchemyNftOpenseaInfo?
    let chain: ChainModel
    var totalSupply: String?
    var nfts: [NFT]?
    var availableNfts: [NFT]?

    var displayName: String? {
        if let name = opensea?.collectionName, name.isNotEmpty {
            return name
        }

        if let name = name, name.isNotEmpty {
            return name
        }

        return nfts?.first?.displayName
    }

    var displayImageUrl: URL? {
        if let imageUrl = opensea?.imageUrl {
            return URL(string: imageUrl)
        }

        if let url = media?.first(where: { $0.isImage })?.normalizedURL {
            return url
        }

        return nfts?.first?.thumbnailURL
    }

    var displayThumbnailImageUrl: URL? {
        if let imageUrl = opensea?.imageUrl {
            return URL(string: imageUrl)
        }

        if let url = media?.first(where: { $0.isImage })?.normalizedThumbnailURL {
            return url
        }

        return nfts?.first?.thumbnailURL
    }
}

struct NFTBatch: Equatable, Hashable {
    let nfts: [NFT]?
    let nextTokenId: String?
}
