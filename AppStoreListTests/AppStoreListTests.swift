//
//  AppStoreListTests.swift
//  AppStoreListTests
//
//  Created by Irányi Csaba on 15/08/16.
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

import XCTest
@testable import AppStoreList

class AppStoreListTests: XCTestCase {
    
    //////////////////////////////////////////////////////////////////
    // MARK: -
    // MARK: TEST SUITE INIT
    // MARK: -

    /// Set up test suite
    override func setUp() {
        super.setUp()
    }
    
    /// Tear down test suite
    override func tearDown() {
        super.tearDown()
    }
    
    //////////////////////////////////////////////////////////////////
    // MARK: -
    // MARK: TEST URL CONSTRUCTION
    // MARK: -

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct1() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopFreeApplications, limit: 25)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/gb/rss/topfreeapplications/limit=25/json", "Test URL construct #1 failed")
    }
    
    /// Test AppStore list RSS feed URL construction
    func testURLConstruct2() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.Hungary, listType: AppStoreListType.TopPaidApplications, limit: 50)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/hu/rss/toppaidapplications/limit=50/json", "Test URL construct #2 failed")
    }
    
    /// Test AppStore list RSS feed URL construction
    func testURLConstruct3() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.NewApplications, limit: 100)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/newapplications/limit=100/json", "Test URL construct #3 failed")
    }
    
    /// Test AppStore list RSS feed URL construction
    func testURLConstruct4() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.NewFreeApplications, limit: 10)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/newfreeapplications/limit=10/json", "Test URL construct #4 failed")
    }

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct5() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.NewPaidApplications, limit: 20)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/newpaidapplications/limit=20/json", "Test URL construct #5 failed")
    }

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct6() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopFreeIpadApplications, limit: 30)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/topfreeipadapplications/limit=30/json", "Test URL construct #6 failed")
    }

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct7() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopGrossingApplications, limit: 40)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/topgrossingapplications/limit=40/json", "Test URL construct #7 failed")
    }

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct8() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopGrossingIpadApplications, limit: 50)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=50/json", "Test URL construct #8 failed")
    }

    /// Test AppStore list RSS feed URL construction
    func testURLConstruct9() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopPaidIpadApplications, limit: 60)
        
        // Test URL
        XCTAssertTrue(appStoreListURL.absoluteString == "https://itunes.apple.com/us/rss/toppaidipadapplications/limit=60/json", "Test URL construct #9 failed")
    }

    
    //////////////////////////////////////////////////////////////////
    // MARK: -
    // MARK: TEST URL DOWNLOAD
    // MARK: -

    /// Test URL download
    func testURLDownload_BadURL() {
        
        // Create URL downloader
        let downloader = URLDownloader()
        
        // Download URL
        downloader.downloadDataFromURL(NSURL(string: "bad_url")!) { (data, error) in
            
            // Check error result
            XCTAssertTrue(error != nil, "Test URL download (bad URL) failed")
        }
    }

    /// Test URL download
    func testURLDownload_URL() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopFreeApplications, limit: 50)

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Download URL
        downloader.downloadDataFromURL(appStoreListURL) { (data, error) in

            // Check data result
            XCTAssertTrue(data != nil, "Test URL download failed with no data")

            // Check error result
            XCTAssertTrue(error == nil, "Test URL download failed with error")
        }
    }

    /// Test URL download
    func testURLDownload_Parallelism() {
        
        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopFreeApplications, limit: 5)

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Download URL
        downloader.downloadDataFromURL(appStoreListURL) { (data, error) in
            
            // Check current thread
            XCTAssertFalse(NSThread.currentThread().isMainThread, "Test URL download (handler background parallelism)) failed")
            
            // Change to main thread
            dispatch_async(dispatch_get_main_queue(), {
                
                // Check current thread
                XCTAssertTrue(NSThread.currentThread().isMainThread, "Test URL download (handler foreground parallelism)) failed")
            });
        }
    }

    /// Test URL download
    func testURLDownload_CompleteHandlerTimeout() {
        
        // Creates and returns an expectation associated with the test case
        let expectation = self.expectationWithDescription("URL Download async")

        // Construct URL
        let appStoreListURL = NSURL(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopPaidApplications, limit: 100)
        
        // Create URL downloader
        let downloader = URLDownloader()
        
        // Download URL
        downloader.downloadDataFromURL(appStoreListURL) { (data, error) in
            
            // Mark an expectation as having been met
            expectation.fulfill()
            }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(10.0) { (error) in

            if error != nil {
                XCTFail("Test URL download (time out) failed")
            }
        }
    }
    
    /// Measure URL download
    func testURLDownload_PerformanceSync() {
        
        self.measureBlock {
            // Construct URL
            let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopFreeApplications, limit: 100)
            
            // Create URL downloader
            let downloader = URLDownloader()
            
            // Download URL
            downloader.downloadDataFromURL(appStoreListURL) { (data, error) in
                
            }
        }
    }
    
    /// Measure URL download
    func testURLDownload_PerformanceAsync() {
        
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring:false, forBlock:{

            // Creates and returns an expectation associated with the test case
            let expectation = self.expectationWithDescription("URL Download async")
            
            // Measurement of metrics will start at this point
            self.startMeasuring()
            
            // Construct URL
            let appStoreListURL = NSURL(country: AppStoreCountry.UnitedStates, listType: AppStoreListType.TopFreeApplications, limit: 100)
            
            // Create URL downloader
            let downloader = URLDownloader()
            
            // Download URL
            downloader.downloadDataFromURL(appStoreListURL) { (data, error) in
                
                // Measurement of metrics will stop at this point
                self.stopMeasuring()
                
                // Mark an expectation as having been met
                expectation.fulfill()
            }
            
            // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
            self.waitForExpectationsWithTimeout(5.0) { (error) in
                
                if error != nil {
                    XCTFail("Test URL download (time out) failed")
                }
            }
        })
    }

    //////////////////////////////////////////////////////////////////
    // MARK: -
    // MARK: TEST APPSTORE LIST DOWNLOAD
    // MARK: -

    /// Test AppStore list download
    func testAppStoreList_BeforeHandler() {
        
        // Creates expectation associated with the test case
        let expectationBeforeHandler = self.expectationWithDescription("Before handler")

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Create
        let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopPaidApplications, limit: 25, downloader: downloader)

        // Download AppStore list
        appStoreList.download({

            // Mark an expectation as having been met
            expectationBeforeHandler.fulfill()
            
            }) {
        }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(1.0) { (error) in
            
            if error != nil {
                XCTFail("Test AppStore list (call before handler) failed")
            }
        }
    }
    
    /// Test AppStore list download
    func testAppStoreList_CompleteHandlerTimeout() {
        
        // Creates expectation associated with the test case
        let expectationCompleteHandler = self.expectationWithDescription("Complete handler")
        
        // Create URL downloader
        let downloader = URLDownloader()
        
        // Create
        let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopPaidApplications, limit: 100, downloader: downloader)
        
        // Download AppStore list
        appStoreList.download({
            
        }) {
            
            // Mark an expectation as having been met
            expectationCompleteHandler.fulfill()
        }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(10.0) { (error) in
            
            if error != nil {
                XCTFail("Test AppStore list (complete handler timeout) failed")
            }
        }
    }
    
    /// Test AppStore list download
    func testAppStoreList_Parallelism() {
        
        // Creates expectation associated with the test case
        let expectationCompleteHandler = self.expectationWithDescription("Complete handler")

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Create
        let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopPaidApplications, limit: 25, downloader: downloader)
        
        // Download AppStore list
        appStoreList.download({
            
            // Check current thread
            XCTAssertTrue(NSThread.currentThread().isMainThread, "Test AppStore list (before handler foreground parallelism)) failed")

        }) {
            
            // Check current thread
            XCTAssertFalse(NSThread.currentThread().isMainThread, "Test AppStore list (complete handler background parallelism) failed")
            
            // Change to main thread
            dispatch_async(dispatch_get_main_queue(), {
                
                // Check current thread
                XCTAssertTrue(NSThread.currentThread().isMainThread, "Test AppStore list (complete handler foreground parallelism)) failed")
            });
            
            // Mark an expectation as having been met
            expectationCompleteHandler.fulfill()
        }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            
            if error != nil {
                XCTFail("Test AppStore list (complete handler timeout) failed")
            }
        }
    }

    /// Test AppStore list download
    func testAppStoreList_DownloadState() {
        
        // Creates expectation associated with the test case
        let expectationCompleteHandler = self.expectationWithDescription("Complete handler")

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Create
        let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopGrossingApplications, limit: 10, downloader: downloader)
        
        // Download AppStore list
        appStoreList.download({

            // Check state
            XCTAssertTrue(appStoreList.downloadState == AppStoreListState.Downloading, "Test AppStore list download (before handler state) failed")

        }) {

            // Check state
            XCTAssertTrue(appStoreList.downloadState == AppStoreListState.DownloadSuccess, "Test AppStore list download (complete handler state) failed")
            
            // Check error result
            XCTAssertTrue(appStoreList.downloadError == nil, "Test AppStore list download (complete handler error) failed")

            // Check list items result
            XCTAssertTrue(appStoreList.listItems != nil, "Test AppStore list download (complete handler list items) failed")
            
            // Mark an expectation as having been met
            expectationCompleteHandler.fulfill()
        }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            
            if error != nil {
                XCTFail("Test AppStore list (complete handler timeout) failed")
            }
        }
    }
    
    /// Test AppStore list download
    func testAppStoreList_DownloadStateError() {
        
        // Creates expectation associated with the test case
        let expectationCompleteHandler = self.expectationWithDescription("Complete handler")

        // Create URL downloader
        let downloader = URLDownloader()
        
        // Create
        let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopGrossingApplications, limit: 100000, downloader: downloader)
        
        // Download AppStore list
        appStoreList.download({
            
            // Check state
            XCTAssertTrue(appStoreList.downloadState == AppStoreListState.Downloading, "Test AppStore list download (before handler state) failed")
            
        }) {
            
            // Check state
            XCTAssertTrue(appStoreList.downloadState == AppStoreListState.DownloadFailed, "Test AppStore list download (complete handler state) failed")
            
            // Check error result
            XCTAssertTrue(appStoreList.downloadError != nil, "Test AppStore list download (complete handler error) failed")
            
            // Check list items result
            XCTAssertTrue(appStoreList.listItems == nil, "Test AppStore list download (complete handler list items) failed")
            
            // Mark an expectation as having been met
            expectationCompleteHandler.fulfill()
        }
        
        // Runs the run loop while handling events until all expectations are fulfilled or the timeout is reached
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            
            if error != nil {
                XCTFail("Test AppStore list (complete handler timeout) failed")
            }
        }
    }
    
    /// Measure AppStore list
    func testAppStoreList_PerformanceSync() {
        
        self.measureBlock {
            
            // Create URL downloader
            let downloader = URLDownloader()
            
            // Create
            let appStoreList = AppleAppStoreList(country: AppStoreCountry.UnitedKingdom, listType: AppStoreListType.TopGrossingApplications, limit: 100000, downloader: downloader)
            
            // Download AppStore list
            appStoreList.download({
                
            }) {
                
            }
        }
    }
}
