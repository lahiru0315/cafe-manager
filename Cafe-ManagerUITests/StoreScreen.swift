//
//  StoreScreen.swift
//  Cafe-ManagerUITests
//
//  Created by Lahiru on 4/27/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import XCTest
import Firebase
class StoreScreen: XCTestCase {
    override func setUpWithError() throws {
//        let paths = Bundle(for: type(of: self)).paths(forResourcesOfType: "plist", inDirectory: nil)
//        //GoogleService-Info
//        for p in paths{
//            print("path "+p)
//        }
        
        if !StaticInfoManager.didUITestingFirebaseConfigured {
            StaticInfoManager.didUITestingFirebaseConfigured = true
            let filePath = Bundle(for: type(of: self)).path(forResource: "GoogleService-Info", ofType: "plist")
            guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
                else { assert(false, "Couldn't load config file") }
            FirebaseApp.configure(options:fileopts)
            
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func waitForFoodToLoad(){
        let app = XCUIApplication()
        expectation(for: NSPredicate(format: "count > 0"), evaluatedWith: app.tables.cells, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        expectation(for: NSPredicate(format: "isEnabled == 1"), evaluatedWith: app.tables.cells.element(boundBy: 0), handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    func testAvailabilityCheck() throws {
        let app = XCUIApplication()
        waitForFoodToLoad()
        var awailabilitySwitch = app.tables.cells.element(boundBy: 0).switches.element(boundBy: 0)
        let intialValue = awailabilitySwitch.value  as! String
        print("intial Vlaue - "+String(intialValue))
        awailabilitySwitch.tap()
        app.terminate()
        app.launch()
        waitForFoodToLoad()
        awailabilitySwitch = app.tables.cells.element(boundBy: 0).switches.element(boundBy: 0)
        print("intial Vlaue - "+String(awailabilitySwitch.isSelected))
        XCTAssertTrue(intialValue != awailabilitySwitch.value as! String)
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func checkPickerWheel(picker:XCUIElementQuery,value:String,app:XCUIApplication)->Bool{
        for element in picker.allElementsBoundByIndex{
            if element.value as! String == value{
                return true
            }
            print(element.value as! String)
        }
        return false
    }
    func checkInPickerWheel(value:String) throws{
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.staticTexts["Menu + "]/*[[".buttons[\"Menu + \"].staticTexts[\"Menu + \"]",".staticTexts[\"Menu + \"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.textFields["Select Category"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: value)
    }
    func testAddCategory() throws{
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.staticTexts["Category"]/*[[".buttons[\"Category\"].staticTexts[\"Category\"]",".staticTexts[\"Category\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Add +"].tap()
        Helper.handleAlert(title: "Missing name", app: app)
        let newCategoryName = "new category"
        Helper.typeText(textField: app.textFields.firstMatch, value: newCategoryName, app: app)
        app.buttons["Add +"].tap()
        
        let insertedRow = app.tables.cells.staticTexts[newCategoryName]
        XCTAssertTrue(insertedRow.waitForExistence(timeout: 4))
        XCTAssertNoThrow(try checkInPickerWheel(value: newCategoryName))
        app.toolbars["Toolbar"].buttons["Cancel"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Category"]/*[[".buttons[\"Category\"].staticTexts[\"Category\"]",".staticTexts[\"Category\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        Helper.typeText(textField: app.textFields.firstMatch, value: newCategoryName, app: app)
        app.buttons["Add +"].tap()
        Helper.handleAlert(title: "Name already exist", app: app,timeOut: 3)
        Helper.typeText(textField: app.textFields.firstMatch, value: "unknown category", app: app)
        app.buttons["Add +"].tap()
        Helper.handleAlert(title: "Invalid name", app: app)
        insertedRow.swipeRight()
        insertedRow.swipeRight()
        Helper.handleAlert(title: "Are you sure", app: app,buttonName: "Yes remove", timeOut: 2)
        XCTAssertFalse(app.tables.cells.staticTexts[newCategoryName].waitForExistence(timeout: 3))
        
        //app.tables.cells.staticTexts
    }
 
    func testFoodAdd() throws{
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.staticTexts["Menu + "]/*[[".buttons[\"Menu + \"].staticTexts[\"Menu + \"]",".staticTexts[\"Menu + \"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let elementsQuery = app.scrollViews.otherElements
        Helper.typeText(field: "Food name", value: "sample food name", app: app)
        Helper.typeText(field: "Price", value: "not a number", app: app)
        app.tap()
        XCTAssertTrue(app.alerts["Invalid cost"].exists)
        app.alerts["Invalid cost"].buttons.firstMatch.tap()
        Helper.typeText(field: "Price", value: "120", app: app)
        app.tap()
        let selectCategoryTextField = elementsQuery.textFields["Select Category"]
        selectCategoryTextField.tap()
        app.pickerWheels.element(boundBy: 0).tap()
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        Helper.typeText(field: "Discount", value: "not a number", app: app)
        app.tap()
        XCTAssertTrue(app.alerts["Invalid Discount"].exists)
        app.alerts["Invalid Discount"].buttons.firstMatch.tap()
        Helper.typeText(field: "Discount", value: "20", app: app)
        app.tap()
        let addBtn = app.buttons["Add +"]
        addBtn.tap()
        XCTAssertTrue(app.alerts["Fields Empty"].exists)
        app.alerts["Fields Empty"].buttons.firstMatch.tap()
        Helper.typeText(field: "Food description", value: "sample food description", app: app)
        app.tap()
        addBtn.tap()
        XCTAssertTrue(app.alerts["No image"].exists)
        app.alerts.buttons["Ok"].tap()
        elementsQuery.images["emptyFood"].tap()
        app.sheets["Choose Method"].buttons["From gallery"].tap()
        XCTAssertTrue(app.tables.cells.element(boundBy: 1).waitForExistence(timeout: 4))
        app.tables.cells.element(boundBy: 1).tap()
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssertTrue(addBtn.waitForExistence(timeout: 4))
        addBtn.tap()
        XCTAssertTrue(app.tables.cells.staticTexts["sample food name"].waitForExistence(timeout: 6))
    }
 
    func testOrders() throws{
        let db = Firestore.firestore()
        let app = XCUIApplication()
        app.tabBars.buttons["Orders"].tap()
        db.collection("ordersList").document("h43fZY6FVZ3b8B0Yf5jy").updateData(["status":1])
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: app.tables.cells.staticTexts["Kamal"], handler: nil)
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: app.tables.cells.buttons["Accept"], handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        let initialCount = app.tables.cells.count
        let testingRow = app.tables.cells.allElementsBoundByIndex.first(where: {$0.staticTexts["Kamal"].exists && $0.buttons["Accept"].exists})!
        testingRow.buttons["Accept"].tap()
        proceedToNextOrderStatus(status:"Preparing",testingRow: testingRow)
        proceedToNextOrderStatus(status: "Ready", testingRow: testingRow)
        db.collection("ordersList").document("h43fZY6FVZ3b8B0Yf5jy").updateData(["status":4])
        proceedToNextOrderStatus(status: "Arriving", testingRow: testingRow,ignoreNavigationBack: true)
        XCTAssertFalse(testingRow.staticTexts["Kamal"].waitForExistence(timeout: 5))
        let afterCellCount = app.tables.cells.count
        XCTAssertTrue((initialCount==1 && afterCellCount==1) || (initialCount == afterCellCount + 1))
    }
    func proceedToNextOrderStatus(status:String,testingRow:XCUIElement,ignoreNavigationBack:Bool = false){
        let app = XCUIApplication()
        XCTAssertTrue(testingRow.buttons[status].waitForExistence(timeout: 2))
        testingRow.tap()
        XCTAssertTrue(app.buttons[status].exists)
        app.buttons[status].tap()
        if !ignoreNavigationBack{
            	app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}

