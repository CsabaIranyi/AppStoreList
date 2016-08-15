//
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

// Apple: Foundation framework
import Foundation

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: APPSTORE LIST
// MARK: -

/// Apple AppStore country
public enum AppStoreCountry: String {

    /// Canada
    case Canada = "ca"

    /// China
    case China = "cn"

    /// France
    case France = "fr"

    /// Germany
    case Germany = "de"

    /// Greece
    case Greece = "gr"

    /// Hungary
    case Hungary = "hu"

    /// Russia
    case Russia = "ru"

    /// Spain
    case Spain = "es"

    /// United Kingdom
    case UnitedKingdom = "gb"

    /// United States
    case UnitedStates = "us"
}

/// Apple AppStore list type
public enum AppStoreListType: String {
    
    /// New applications
    case NewApplications = "newapplications"
    
    /// New free applications
    case NewFreeApplications = "newfreeapplications"
    
    /// New paid applications
    case NewPaidApplications = "newpaidapplications"
    
    /// Top free applications
    case TopFreeApplications = "topfreeapplications"
    
    /// Top free iPad applications
    case TopFreeIpadApplications = "topfreeipadapplications"

    /// Top grossing applications
    case TopGrossingApplications = "topgrossingapplications"
    
    /// Top grossing iPad applications
    case TopGrossingIpadApplications = "topgrossingipadapplications"
    
    /// Top paid applications
    case TopPaidApplications = "toppaidapplications"
    
    /// Top paid iPad applications
    case TopPaidIpadApplications = "toppaidipadapplications"
}

/// Apple AppStore list state
public enum AppStoreListState {
    
    /// Initialized state
    case Initialized

    /// Downloading state
    case Downloading

    /// Downloaded successfully state
    case DownloadSuccess

    /// Download failed state
    case DownloadFailed
}

/// AppStore list
public class AppleAppStoreList : NSObject {

    //////////////////////////////////////////////
    // MARK: Constants

    /// Default list limit
    private static let DefaultLimit: UInt = 10
    
    /// AppStore URL pattern
    private static let AppStoreURL = "https://itunes.apple.com/%@/rss/%@/limit=%d/json"
    
    
    //////////////////////////////////////////////
    // MARK: Variables

    /// Country
    public var country: AppStoreCountry = .UnitedKingdom
    
    /// List type
    public var listType: AppStoreListType = .TopFreeApplications
    
    /// List limit
    public var limit: UInt = DefaultLimit
    
    /// URL downloader
    public let downloader: URLDownloader
    
    /// Download state
    private(set) public var downloadState: AppStoreListState = .Initialized

    /// Last download error
    private(set) public var downloadError: NSError?

    // List items
    private(set) public var listItems: [AppStoreListItem]?

    
    //////////////////////////////////////////////
    // MARK: Initializers

    /// Create an AppStore list.
    ///
    /// - Parameters:
    ///     - country: Country of AppStore.
    ///     - listType: List type.
    ///     - limit: Limit of the list.
    ///     - downloader: URL downloader object.
    public init(country: AppStoreCountry, listType: AppStoreListType, limit: UInt, downloader: URLDownloader) {
        
        // Save properties
        self.country = country
        self.listType = listType
        self.limit = limit
        self.downloader = downloader
    }

    /// Create an AppStore list.
    ///
    /// - Parameters:
    ///     - downloader: URL downloader object.
    public init(downloader: URLDownloader) {
        
        // Save properties
        self.downloader = downloader
    }
    
    //////////////////////////////////////////////
    // MARK: Methods

    /// Download an AppStore list.
    ///
    /// - Parameters:
    ///     - beforeDownload: Before download handler.
    ///     - completion: Completion handler.
    public func download(beforeDownload:() -> Void, completion:() -> Void) {

        // Set download state
        self.downloadState = .Downloading
        
        // Clear results
        self.downloadError = nil
        self.listItems = nil
        
        // Run before handler
        beforeDownload()
        
        // Construct AppStore RSS feed URL
        let appStoreURL = NSURL(country: self.country, listType: self.listType, limit: self.limit)
        
        // Download AppStore list asynchronous
        self.downloader.downloadDataFromURL(appStoreURL) { (data, error) in
            
            // If an error occured
            if error != nil {
                
                print("Download error: ", error)
                
                // Set download state
                self.downloadState = .DownloadFailed
                
                // Set download error
                self.downloadError = error
                
            // No error            
            } else  {
                
                // Has data returned by server
                if data != nil
                {
                    do {
                        guard
                            // Serialize JSON to objects
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? JSON,
                            
                            // Parse JSON objects as AppStore List RSS Feed document
                            let appStoreListRSSFeed = AppStoreListRSSFeed(json: jsonData)
                            
                            else {
                                
                                print("JSON parse error")

                                // Set download state
                                self.downloadState = .DownloadFailed
                                
                                // Run completion handler
                                completion()
                                
                                return
                        }
                        
                        // Save list items
                        self.listItems = appStoreListRSSFeed.listItems
                        
                        // Set download state
                        self.downloadState = .DownloadSuccess
                        
                        print("AppStore list items: ", self.listItems?.count ?? 0)
                        
                    } catch let JSONError as NSError {
                        
                        print("JSON parse error")

                        // Set download state
                        self.downloadState = .DownloadFailed
                        
                        // Set download error
                        self.downloadError = JSONError
                    }
                }
                // Empty server result
                else {
                    
                    print("No server data error")

                    // Set download state
                    self.downloadState = .DownloadFailed
                }
            }
            
            // Run completion handler
            completion()
        }
    }
    
    /// Get long description
    public func longDescription() -> String {
        
        // List type description
        var listTypeDescription: String
        
        // Check current list type
        switch self.listType {
            
        case .NewApplications:
            listTypeDescription = "new applications"
            
        case .NewFreeApplications:
            listTypeDescription = "new free applications"

        case .NewPaidApplications:
            listTypeDescription = "new paid applications"
            
        case .TopFreeApplications:
            listTypeDescription = "free applications"

        case .TopFreeIpadApplications:
            listTypeDescription = "free iPad applications"

        case .TopGrossingApplications:
            listTypeDescription = "grossing applications"

        case .TopGrossingIpadApplications:
            listTypeDescription = "grossing iPad applications"
            
        case .TopPaidApplications:
            listTypeDescription = "paid applications"
            
        case .TopPaidIpadApplications:
            listTypeDescription = "paid iPadapplications"
        }
        
        // Construct readable description
        return "Top \(self.limit) \(listTypeDescription) (\(self.country.rawValue.uppercaseString))"
    }
}

/// NSURL extension to construct AppStore RSS feed URL
extension NSURL {
    
    //////////////////////////////////////////////
    // MARK: Initializers
    
    /// Create an AppStore URL.
    ///
    /// - Parameters:
    ///     - country: Country of AppStore.
    ///     - listType: List type.
    ///     - limit: Limit of the list.
    convenience init(country: AppStoreCountry, listType: AppStoreListType, limit: UInt) {
        
        // Construct URL string
        // Format: https://itunes.apple.com/gb/rss/topfreeapplications/limit=25/xml
        let urlString = String(format: AppleAppStoreList.AppStoreURL, arguments: [country.rawValue, listType.rawValue, limit]);
        
        // Create URL object
        self.init(string: urlString)!
    }
}

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: APPSTORE LIST ITEM
// MARK: -

/// AppStore list item
public struct AppStoreListItem: Decodable {
    
    //////////////////////////////////////////////
    // MARK: Variables
    
    /// App name
    public let appName: String
    
    /// Vendor name
    public let vendorName: String
    
    /// iTunes URL
    public let iTunesURL: String
    
    /// Copyright
    public let copyright: String
    
    // Price amount
    public let priceAmount: String
    
    /// Price currency
    public let priceCurrency: String
    
    /// Thumbnail image (53x53px) URL
    public let thumbnailImageURL: String
    
    /// Thumbnail image (53x53px) data
    public let thumbnailImageData: NSData?
    
    
    //////////////////////////////////////////////
    // MARK: Initializers
    
    /// Create an AppStore list item.
    ///
    /// - Parameters:
    ///     - json: JSON object.
    public init?(json: JSON) {
        
        guard
            // Get JSON container objects
            let nameContainer: JSON = "im:name" <~~ json,
            let artistContainer: JSON = "im:artist" <~~ json,
            let idContainer: JSON = "id" <~~ json,
            let copyrightContainer: JSON = "rights" <~~ json,
            let priceContainer: JSON = "im:price" <~~ json,
            let priceAttributesContainer: JSON = "attributes" <~~ priceContainer,
            let imageContainer: [JSON] = "im:image" <~~ json
            
            else { return nil }
        
        guard let
            // Get important JSON values
            appName: String = "label" <~~ nameContainer,
            vendorName: String = "label" <~~ artistContainer,
            iTunesURL: String = "label" <~~ idContainer,
            copyright: String = "label" <~~ copyrightContainer,
            priceAmount: String = "amount" <~~ priceAttributesContainer,
            priceCurrency: String = "currency" <~~ priceAttributesContainer,
            imageURL3: String = "label" <~~ imageContainer[2]
            
            else { return nil }
        
        // Save AppStore list item properties
        self.appName = appName
        self.vendorName = vendorName
        self.iTunesURL = iTunesURL
        self.thumbnailImageURL = imageURL3
        self.copyright = copyright
        self.priceAmount = priceAmount;
        self.priceCurrency = priceCurrency;
        
        // Preload thumbnail image data for fluid UX
        let imageData = NSData(contentsOfURL: NSURL(string: self.thumbnailImageURL)!)
        self.thumbnailImageData = imageData!
    }
}

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: APPSTORE LIST RSS FEED
// MARK: -

/// AppStore list RSS feed
private struct AppStoreListRSSFeed: Decodable {
    
    //////////////////////////////////////////////
    // MARK: Variables

    /// AppStore list items
    private var listItems: [AppStoreListItem]?
    
    
    //////////////////////////////////////////////
    // MARK: Initializers
    
    /// Create an AppStore list item.
    ///
    /// - Parameters:
    ///     - json: JSON object.
    private init?(json: JSON) {
        
        guard
            // Get JSON container objects
            let feedContainer: JSON = "feed" <~~ json
            
            else { return nil }
        
        // Get important JSON values
        let entries: [AppStoreListItem] = ("entry" <~~ feedContainer)!
        
        // Save AppStore list items
        self.listItems = entries
    }
}
