import UIKit
import FormbricksSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // rename apiHost - AppUrl
        let config = FormbricksConfig.Builder(appUrl: "http://localhost:3000", environmentId: "cm6ovvfoc000asf0k39wbzc8s")
            .setLogLevel(.debug)
            .build()
        
        
        Formbricks.setup(with: config)
        
        Formbricks.setup(with: config)
        
        Formbricks.test()
        
        return true
    }

}
