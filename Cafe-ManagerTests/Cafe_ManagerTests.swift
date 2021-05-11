//
//  Cafe_ManagerTests.swift
//  Cafe-ManagerTests
//
//  Created by Lahiru on 4/3/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import XCTest
import Firebase
import FirebaseAuth
@testable import Cafe_Manager
class Cafe_ManagerTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAuthentication() {
        let authScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "authScreen") as! AuthScreen
        authScreen.loadView()
        authScreen.viewDidLoad()
        authScreen.email.text="Lahiru.atomic@gmail.com"
        //"Wrong credendials.Please check your credentials"
        XCTAssertTrue(authScreen.isEmpty([authScreen.email,authScreen.password]))
        authScreen.password.text = "123456"
        XCTAssertFalse(authScreen.isEmpty([authScreen.email,authScreen.password]))
        
        authScreen.loginUser()
        sleep(5)
        XCTAssertTrue(Auth.auth().currentUser?.email == "Lahiru.atomic@gmail.com")
    }
  
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
