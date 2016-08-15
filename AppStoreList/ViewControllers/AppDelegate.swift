//
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

// Apple: Foundation framework
import Foundation

// Apple: UIKit framework
import UIKit

@UIApplicationMain

/// Delegate of singleton application object
class AppDelegate: UIResponder, UIApplicationDelegate {

    //////////////////////////////////////////////
    // MARK: Constants
    
    /// User defaults setting: AppStore list country
    private static let SettingCountry = "AppStoreList_Country"
    
    /// User defaults setting: AppStore list type
    private static let SettingListType = "AppStoreList_ListType"

    /// User defaults setting: AppStore limit
    private static let SettingLimit = "AppStoreList_Limit"

    
    //////////////////////////////////////////////
    // MARK: Variables

    // Main window
    var window: UIWindow?

    // AppStore list
    var appStoreList: AppleAppStoreList?
    
    // AppStore list view controller
    var appStoreListViewController: AppStoreListViewController?
    
    
    //////////////////////////////////////////////
    // MARK: Methods

    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        #if !DEBUG
            Swift.print("Release build: print is disabled")
        #endif
        
        //////////////////////////////////////////////
        // User defaults
        //////////////////////////////////////////////

        // Get standard user defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Register user defaults
        userDefaults.registerDefaults([
            AppDelegate.SettingCountry: AppStoreCountry.UnitedKingdom.rawValue,
            AppDelegate.SettingListType: AppStoreListType.TopFreeApplications.rawValue,
            AppDelegate.SettingLimit: 25])
        
        // Read user defaults
        let appStoreCountrySetting: AppStoreCountry = AppStoreCountry(rawValue: userDefaults.stringForKey(AppDelegate.SettingCountry)!)!
        let appStoreListTypeSetting: AppStoreListType = AppStoreListType(rawValue: userDefaults.stringForKey(AppDelegate.SettingListType)!)!
        let appStoreLimitSetting = UInt(userDefaults.integerForKey(AppDelegate.SettingLimit))
        
        
        //////////////////////////////////////////////
        // Window
        //////////////////////////////////////////////

        // Create main window
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        
        //////////////////////////////////////////////
        // AppStore list and URL Downloader
        //////////////////////////////////////////////

        // Create URL downloader
        let downloader = URLDownloader.init()
        
        // Create AppStore list
        self.appStoreList = AppleAppStoreList(country: appStoreCountrySetting, listType: appStoreListTypeSetting, limit: appStoreLimitSetting, downloader: downloader)

        // Create AppStore list viewcontroller
        self.appStoreListViewController = AppStoreListViewController(appStoreList: self.appStoreList!)
        
        
        //////////////////////////////////////////////
        // Navigation controller
        //////////////////////////////////////////////

        // Create navigation controller
        let navControllerTopFree = UINavigationController(rootViewController: self.appStoreListViewController!)
        UINavigationBar.appearance().tintColor = UIColor(red: 0xf7/255.0, green: 0xf9/255.0, blue: 0xfc/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 0x0c/255.0, green: 0x93/255.0, blue: 0xd3/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red: 0xf7/255.0, green: 0xf9/255.0, blue: 0xfc/255.0, alpha: 1.0),
            NSFontAttributeName: UIFont(name:"OpenSans-Light", size:18.0)!]
        navControllerTopFree.navigationBarHidden = false
        navControllerTopFree.toolbarHidden = true
        navControllerTopFree.navigationBar.translucent = false
        
        
        //////////////////////////////////////////////
        // Show root controller
        //////////////////////////////////////////////

        // Init root view controller
        window!.rootViewController = navControllerTopFree;

        // Makes the receiver the key window and visible
        window!.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        return true
    }
    
    /// Tells the delegate that the app has become active.
    func applicationDidBecomeActive(application: UIApplication) {
     
        // Stop monitoring user defaults changes
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }

    /// Tells the delegate that the app is about to become inactive.
    func applicationWillResignActive(application: UIApplication) {
        
        // Start monitoring user defaults changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.applyUserDefaultsChanges), name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    /// Apply changed user settings
    func applyUserDefaultsChanges() {
        
        // Get standard user defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Read user defaults
        let appStoreCountrySetting: AppStoreCountry = AppStoreCountry(rawValue: userDefaults.stringForKey(AppDelegate.SettingCountry)!)!
        let appStoreListTypeSetting: AppStoreListType = AppStoreListType(rawValue: userDefaults.stringForKey(AppDelegate.SettingListType)!)!
        let appStoreLimitSetting = UInt(userDefaults.integerForKey(AppDelegate.SettingLimit))
        
        // Set new search parameters
        self.appStoreList!.country = appStoreCountrySetting
        self.appStoreList!.listType = appStoreListTypeSetting
        self.appStoreList!.limit = appStoreLimitSetting
        
        // Refresh list
        self.appStoreListViewController!.refreshList()
    }
}

