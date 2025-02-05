struct JsResponseMessage: Codable {
    let event: EventType
    let responseUpdate: ResponseUpdate?
}

struct ResponseUpdate: Codable {
    let data: [String: AnyCodable]?
    let ttc: [String: AnyCodable]?
    let finished: Bool?
    let variables: [String: AnyCodable]?
    let language: String?
}
