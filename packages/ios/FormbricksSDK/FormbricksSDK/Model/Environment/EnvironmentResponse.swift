struct EnvironmentResponse: Codable {
    let data: EnvironmentResponseData
    
    var responseDictionary: [String: Any] = [:]
    
    enum CodingKeys: CodingKey {
        case data
    }
}

extension EnvironmentResponse {
    func getFirstSurveyJson() -> [String: Any]? {
        let responseDict = responseDictionary["data"] as? [String: Any]
        let dataDict = responseDict?["data"] as? [String: Any]
        let surveysArray = dataDict?["surveys"] as? [[String: Any]]
        return surveysArray?.first as? [String: Any]
    }
    
    func getStylingJson() -> [String: Any]? {
        let responseDict = responseDictionary["data"] as? [String: Any]
        let dataDict = responseDict?["data"] as? [String: Any]
        let projectDict = dataDict?["project"] as? [String: Any]
        return projectDict?["styling"] as? [String: Any]
    }
}
