import UIKit

extension UIApplication {
    static var safeShared: UIApplication? {
        return UIApplication.value(forKeyPath: "sharedApplication") as? UIApplication
    }
}
