//
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

// Apple: UIKit framework
import UIKit

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: APPSTORE LIST VIEWCONTROLLER
// MARK: -

/// AppStore list viewcontroller.
class AppStoreListViewController: UIViewController {

    //////////////////////////////////////////////
    // MARK: Variables

    /// AppStore list
    private var appStoreList: AppleAppStoreList?
    
    /// Table view
    private var tableView: UITableView?

    /// Table cell unique ID
    private let cellId = "CellID"

    
    //////////////////////////////////////////////
    // MARK: Initializers

    /// Create an AppStore list viewcontroller.
    ///
    /// - Parameters:
    ///     - appStoreList: AppStore list.
    init(appStoreList: AppleAppStoreList) {
        
        // Store AppStore list object
        self.appStoreList = appStoreList

        // Init view controller
        super.init(nibName: nil, bundle: nil)

        // Init subviews
        self.initSubViews()
    }
    
    /// Returns an object initialized from data in a given unarchiver.
    ///
    /// - Parameters:
    ///     - aDecoder: An unarchiver object.
    required init?(coder aDecoder: NSCoder) {
        
        // Init view controller
        super.init(coder: aDecoder)
    }
    
    
    //////////////////////////////////////////////
    // MARK: Methods
    
    /// Create and initialize subviews.
    private func initSubViews() {
        
        print("Init subviews")

        //////////////////////////////////////////////
        // Table view
        //////////////////////////////////////////////

        // Create table view
        self.tableView = UITableView(frame: self.view.bounds, style: .Plain)

        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.whiteColor()
        self.tableView!.clipsToBounds = true
        self.tableView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.tableView!.sectionHeaderHeight = 0
        self.tableView!.sectionFooterHeight = 0
        self.tableView!.rowHeight = 60
        //self.tableView!.cellLayoutMarginsFollowReadableWidth = false;
        self.tableView!.separatorStyle = .None;
        
        // Add table view to view
        self.view.addSubview(self.tableView!)

        
        //////////////////////////////////////////////
        // Refresh control
        //////////////////////////////////////////////

        // Create refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AppStoreListViewController.refreshList), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor(red: 0x0c/255.0, green: 0x93/255.0, blue: 0xd3/255.0, alpha: 1.0)
        refreshControl.tag = 999
        
        // Add refresh control to table view
        self.tableView!.addSubview(refreshControl)
        
        
        //////////////////////////////////////////////
        // Rigth buttons
        //////////////////////////////////////////////

        // Settings button (right)
        let settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(AppStoreListViewController.openSettings))
        self.navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        
        print("View did load")
        
        // Call super
        super.viewDidLoad()
        
        // Refresh table view content
        self.refreshList()
    }
    
    /// Refresh table view content
    func refreshList() {
        
        print("Refresh list")

        // Set title
        self.navigationItem.title = self.appStoreList?.longDescription()


        // Show indicator of network activity
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // Download the AppStore list
        self.appStoreList?.download({
            
            if (self.tableView != nil)
            {
                // Reloads the rows and sections of the table view
                self.tableView!.reloadData()
            }

            }, completion: {
            
            // Change to main thread
            dispatch_async(dispatch_get_main_queue(), {
                
                // Hide indicator of network activity
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                // End refreshing control
                let refreshControl: UIRefreshControl = self.tableView?.viewWithTag(999) as! UIRefreshControl
                refreshControl.endRefreshing()

                // Reloads the rows and sections of the table view
                self.tableView!.reloadData()
            });
        })
    }
    
    /// Open settings
    func openSettings() {

        // Open Settings
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        
        // Call super
        super.didReceiveMemoryWarning()
        
        // Catch-22
        print("Please purchase a better iDevice...or change to Android")
    }
}

//////////////////////////////////////////////////////////////////
// MARK: -
// MARK: APPSTORE LIST TABLE VIEWCONTROLLER
// MARK: -

/// Table viewcontroller extension
extension AppStoreListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// The number of sections in tableView.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //  Only one section
        return 1
    }
    
    /// The number of rows in section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Check  AppStore list current state
        switch self.appStoreList!.downloadState {
            
        // Initialized
        case AppStoreListState.Initialized:
            return 1
            
        // Downloading in progress
        case AppStoreListState.Downloading:
            return 1
            
        // Download failed
        case AppStoreListState.DownloadFailed:
            return 1
            
        // Download success
        case AppStoreListState.DownloadSuccess:
            return (self.appStoreList?.listItems?.count)!
        }
    }

    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Returns a reusable table-view cell object located by its identifier
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)

        // There is no reusable table-view cell
        if (cell == nil)
        {
            // Create new table-view cell
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            
            // Config default cell attributes and behaviour
            cell!.textLabel!.numberOfLines = 1
            cell!.textLabel!.textColor = UIColor.blackColor()  //UIColor(red: 0x0c/255.0, green: 0x93/255.0, blue: 0xd3/255.0, alpha: 1.0)
            cell!.textLabel!.font = UIFont(name: "OpenSans-Light", size: 14.0)
            cell!.detailTextLabel!.numberOfLines = 1
            cell!.detailTextLabel!.font = UIFont(name: "OpenSans-Light", size: 12.0)
            cell!.detailTextLabel!.textColor = UIColor.lightGrayColor()
            cell!.imageView!.layer.masksToBounds = true;
            cell!.imageView!.layer.opaque = false;
            cell!.imageView!.layer.cornerRadius = 11
            cell!.imageView!.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
        }
        
        // Check  AppStore list current state
        switch self.appStoreList!.downloadState {
        
        // Initialized
        case AppStoreListState.Initialized:
            // Config cell
            cell!.textLabel!.text = "Downloading..."
            cell!.detailTextLabel!.text = ""
            cell!.imageView?.image = UIImage(named: "Logo")
            cell!.accessoryType = UITableViewCellAccessoryType.None

        // Downloading in progress
        case AppStoreListState.Downloading:
            // Config cell
            cell!.textLabel!.text = "Downloading..."
            cell!.detailTextLabel!.text = ""
            cell!.imageView?.image = UIImage(named: "Logo")
            cell!.accessoryType = UITableViewCellAccessoryType.None

        // Download failed
        case AppStoreListState.DownloadFailed:
            // Config cell
            cell!.textLabel!.text = "Download failed"
            cell!.detailTextLabel!.text = ""
            cell!.imageView?.image = UIImage(named: "Logo")
            cell!.accessoryType = UITableViewCellAccessoryType.None

        // Download success
        case AppStoreListState.DownloadSuccess:
            
            // Current AppStore list item
            let appStoreListItem = (self.appStoreList?.listItems![indexPath.row])!
            
            // Config cell
            cell!.textLabel!.text = appStoreListItem.appName
            cell!.detailTextLabel!.text = appStoreListItem.vendorName
            
            if appStoreListItem.thumbnailImageData != nil {
                cell!.imageView?.image = UIImage(data: appStoreListItem.thumbnailImageData!, scale: 2.0)
            } else {
                cell!.imageView?.image = nil
            }
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        // Return configured cell
        return cell!
    }
    
    /// Tells the delegate that the specified row is now selected.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        // Current AppStore list item
        let appStoreListItem = (self.appStoreList?.listItems![indexPath.row])!
        
        // Open AppStore app
        print("Open URL: ", appStoreListItem.iTunesURL)
        UIApplication.sharedApplication().openURL(NSURL(string: appStoreListItem.iTunesURL)!)
        
        // Deselect cell
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
