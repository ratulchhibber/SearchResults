import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    configureAppearance()
    
    return true
  }
  
  func configureAppearance() {
    UISearchBar.appearance().tintColor = .candyGreen
    UINavigationBar.appearance().tintColor = .candyGreen
  }
}
