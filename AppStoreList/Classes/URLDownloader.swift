//
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

// Apple: Foundation framework
import Foundation

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: URL DOWNLOADER
// MARK: -

/// URL downloader
public class URLDownloader : NSObject {

    //////////////////////////////////////////////
    // MARK: Variables

    /// Error domain
    public static let URLDownloaderErrorDomain = "com.blackswan.error.urldownloader"

    
    //////////////////////////////////////////////
    // MARK: Methods

    /// Download data from URL.
    ///
    /// - Parameters:
    ///     - url: URL.
    ///     - completion: Completion handler.
    public func downloadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        
        // Log
        print("Download data from: \(url)");
        
        // Get shared singleton session
        let session = NSURLSession.sharedSession()
        
        // Create a task that retrieves the contents of the URL
        let downloadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            
            // This handler is executed on the delegate queue. (not in main thread)
            print("Download completed from: \(url)");
            
            // Detect network related error
            if let networkError = error {
                
                // Call the completion handler with error
                completion(data: nil, error: networkError)
                
                // Detect HTTP response
            } else if let httpResponse = response as? NSHTTPURLResponse {
                
                // Log
                print("  HTTP: ", httpResponse.statusCode)
                
                // Check HTTP status code mismatch
                if httpResponse.statusCode != 200 {
                    
                    // Custom HTTP status related error
                    let statusError = NSError(domain:URLDownloader.URLDownloaderErrorDomain, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has wrong value."])
                    
                    // Call the completion handler with error
                    completion(data: nil, error: statusError)
                    
                } else {
                    
                    // Check HTTP Content-Length header presence
                    if (httpResponse.allHeaderFields["Content-Length"] != nil)
                    {
                        // Log
                        print("  Content length: ", httpResponse.allHeaderFields["Content-Length"]!)
                    }

                    // Call the completion handler with data
                    completion(data: data, error: nil)
                }
            }
        }
        
        // Start task
        downloadDataTask.resume()
    }
}
