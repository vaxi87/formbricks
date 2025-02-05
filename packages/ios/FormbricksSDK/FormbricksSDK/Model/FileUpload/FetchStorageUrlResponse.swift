struct FetchStorageUrlResponse: Codable {
    let data: StorageData
}

struct StorageData: Codable {
    let signedUrl: String
    let signingData: SigningData
    let updatedFileName: String
    let fileUrl: String
}

struct SigningData: Codable {
    let signature: String
    let timestamp: Int
    let uuid: String
}
