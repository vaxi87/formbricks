final class UpdateQueue {
    
    static var active = UpdateQueue()
    
    private var userId: String?
    private var attributes: [String : String]?
    private var language: String?
    private var timer: Timer?
    
    func set(userId: String) {
        
    }
    
    func set(attributes: [String : String]) {
        
    }
    
    func add(attribute: String, forKey key: String) {
        
    }
    
    func set(language: String) {
        
    }
}

private extension UpdateQueue {
    func startDebounceTimer() {
        
    }
    
    func commit() {
        
    }
}
