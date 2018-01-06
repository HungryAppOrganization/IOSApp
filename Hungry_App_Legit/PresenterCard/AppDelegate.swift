/*
 *  #######
 *  # ### #
 *  ### # #
 *      # #        Hungry LLC 
 *      ###        IOS Swift Application
 *                      v1 1/5/2018
 *      ###        John Peurifoy
 */

import UIKit
import Material
import Firebase
import GoogleMaps
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        FirebaseApp.configure()
        let clientID = valueForAPIKey(keyname :"API_SECRET")
        GMSServices.provideAPIKey(clientID)
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = ViewController()
        window!.makeKeyAndVisible()
        
    }

	func valueForAPIKey(keyname:String) -> String {
		// Credit to the original source for this technique at
		// http://blog.lazerwalker.com/blog/2014/05/14/handling-private-api-keys-in-open-source-ios-apps
        let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
		return value
	}

    
}

