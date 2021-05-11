//
//  LoginAuthentication.swift
//  Cafe-ManagerUITests
//
//  Created by Lahiru on 4/27/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import XCTest
class LoginAuthentication: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    var monitor:NSObjectProtocol!
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //removeUIInterruptionMonitor(monitor)kkg
//        if(XCUIApplication().navigationBars["Cafe_Manager.MainScreenContainer"].buttons["Sign Out"].exists){
//            XCUIApplication().navigationBars["Cafe_Manager.MainScreenContainer"].buttons["Sign Out"].tap()
        
    
    }
    func openSettings(_ permissionMode:Int,skipOpening:Bool = false,turnOnLocationOnly:Bool = false){
        let permissionModes = ["Never","Ask Next Time","While Using the app"]
        let settings  = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        if !skipOpening{
            settings.launch()
        }else{
            XCTAssertTrue(settings.waitForExistence(timeout: 5))
        }
        settings.tables.staticTexts["Privacy"].tap()
        settings.tables.staticTexts["Location Services"].tap()
        if !turnOnLocationOnly{
            settings.tables.staticTexts["Cafe-Manager"].tap()
        }
        settings.tables.staticTexts["Ask Next Time"].tap()
        settings.terminate()
    }
   
    
    
    func toggleLocationService(turnOn:Bool){
        let settings  = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
         settings.launch()
         settings.tables.staticTexts["Privacy"].tap()
         settings.tables.staticTexts["Location Services"].tap()
        if settings.tables.switches["Location Services"].value as! String == (turnOn ? "1":"0"){
            return settings.terminate()
        }
        if settings.tables.switches["Location Services"].value as! String == "1"{
             settings.tables.switches["Location Services"].tap()
             settings.buttons["Turn Off"].tap()
        }else{
            settings.tables.switches["Location Services"].tap()
        }
        settings.terminate()
    }
    
    func testLocationServiceAvailability() throws{
        let app = XCUIApplication()
        toggleLocationService(turnOn: false)
        app.launch()
        Helper.handleAlert(title: "Location service is disabled", app: app,buttonName: "Open Settings")
        toggleLocationService(turnOn: true)
        app.activate()
        let message = "You have turned off the location service please turn on the location service manually in settings"
        XCTAssertFalse(app.alerts.staticTexts[message].waitForExistence(timeout: 3),"the warning alert is still shown") 
    }
    func testLocationAcccessPaths() throws{
        let app = XCUIApplication()
        openSettings(1)
        app.launch()
        let locationBtn = app/*@START_MENU_TOKEN@*/.staticTexts["Allow Location"]/*[[".buttons[\"Allow Location\"].staticTexts[\"Allow Location\"]",".staticTexts[\"Allow Location\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        locationBtn.tap()
        let permissionAlert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts
        Helper.handleAlert(alert: permissionAlert,buttonName: "Don’t Allow",timeOut: 3)
        let noNeedBtn = app.buttons["No need"]
        XCTAssertTrue(noNeedBtn.waitForExistence(timeout: 3))
        noNeedBtn.tap()
        locationBtn.tap()
        Helper.handleAlert(title: "Location service is disabled", app: app,buttonName: "Open Settings",timeOut: 3)
        openSettings(1, skipOpening: true)
        app.activate()
        //locationBtn.tap()
        let button = permissionAlert.buttons["Allow While Using App"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
    }
    var primaryButtonName = "Login"
    func testRegister() throws{
        let app = XCUIApplication()
        if app.buttons["Register?"].exists{
            app.buttons["Register?"].tap()
        }
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let phoneNumberField = app.textFields["Phonenumber"]
        let confirmPassword = app.secureTextFields["Confirm Password"]
        XCTAssertTrue(phoneNumberField.exists)
        XCTAssertTrue(confirmPassword.exists)
        primaryButtonName = "Register"
        handleFieldInputWithError(field: [emailField], value: ["jkasasds"], errorTitle: "Field error")
        handleFieldInputWithError(field: [passwordField,phoneNumberField,confirmPassword], value: ["password","u234i24hu3","password2"], errorTitle: "Field mismatch")
        handleFieldInputWithError(field: [confirmPassword], value: ["password"], errorTitle: "Invalid contact number")
        handleFieldInputWithError(field: [phoneNumberField], value: ["0770665281"], errorTitle: "Email field error",timeOut: 5)
        handleFieldInputWithError(field: [emailField], value: ["Lahiru.atomic@gmail.com"], errorTitle: "Email field error",timeOut: 7)
    }
    func handleFieldInputWithError(field:[XCUIElement],value:[String],errorTitle:String,timeOut:Double=0){
        let app = XCUIApplication()
        let primaryButton = app.buttons[primaryButtonName]
        for i in 0..<field.count{
            Helper.typeText(textField: field[i], value: value[i], app: app)
        }
        if !primaryButton.isHittable{
            field.last?.typeText("\n")
           // app.coordinate(withNormalizedOffset: CGVector(dx: 20, dy: 20)).tap()
        }
        primaryButton.tap()
        Helper.handleAlert(title:errorTitle, app: app,timeOut: timeOut)
    }

    func testLogin() throws{
        let app = XCUIApplication()
        if app.buttons["Login?"].exists{
            app.buttons["Login?"].tap()
        }
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginBtn = app.buttons["Login"]
        primaryButtonName = "Login"
        handleFieldInputWithError(field: [emailField], value: ["jkasasds"], errorTitle: "Field error")
        handleFieldInputWithError(field: [passwordField], value: ["sdkfndkfs"], errorTitle: "Email field error",timeOut: 5)
        handleFieldInputWithError(field: [emailField], value: ["Lahiru.atomic@gmail.com"], errorTitle: "Authentication failed",timeOut: 5)
        Helper.typeText(textField: passwordField, value: "123456", app: app)
        loginBtn.tap()
        let storeTab = app.tabBars.buttons["Store"]
        XCTAssertTrue(storeTab.waitForExistence(timeout: 5),"failed to navigate to main screen")
        app.navigationBars["Cafe_Manager.MainScreenContainer"].buttons["Sign Out"].tap()
        app.terminate()
        app.launch()
        XCTAssertFalse(storeTab.waitForExistence(timeout: 5),"App accidentally navigate to main screen")
    }
    

}
