//
//  ObserverTestCase.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import JZToolKit

class ObserverTestCase: XCTestCase {
    
    @objc class Notifier: NSObject {
        class var defaultInitialValue: Int {
            return 0
        }
        class var defaultOtherInitialValue: Int {
            return 1
        }
        dynamic var emitter: Int
        dynamic var otherEmitter: Int
        required override init() {
            self.emitter = type(of: self).defaultInitialValue
            self.otherEmitter = type(of: self).defaultOtherInitialValue
            super.init()
        }
    }
    
    class ObservingClass: ObservingObject {
        let testCase: ObserverTestCase
        var notifier: Notifier? {
            return observedObject as? Notifier
        }
        
        required init(testCase: ObserverTestCase) {
            self.testCase = testCase
            super.init()
        }
        
        class override var observerResponses: [String : Selector]? {
            return [#keyPath(Notifier.emitter): #selector(self.receivedEmitterUpdate)]
        }
        
        func receivedEmitterUpdate() {
            print(#function)
            testCase.finalEmitterValue = notifier!.emitter
        }
    }
    
    class SubclassObserver: ObservingClass {
        class override var observerResponses: [String : Selector]? {
            let subclassOR = [#keyPath(Notifier.otherEmitter): #selector(self.receivedOtherEmitterUpdate)]
            if let superObserverResponses = super.observerResponses {
                return subclassOR.merged(with: superObserverResponses)
            } else {
                return subclassOR
            }
        }
        
        func receivedOtherEmitterUpdate() {
            testCase.finalOtherEmitterValue = notifier!.otherEmitter
        }
    }
    
    public dynamic var finalEmitterValue: Int = Int.max
    
    var expectedEmitterValue: Int!
    
    public dynamic var finalOtherEmitterValue: Int = Int.max
    
    var expectedOtherEmitterValue: Int!
    
    var notifier = Notifier()
    var observer: ObservingClass!
    
    func checkEmitter() {
        XCTAssertNotEqual(finalEmitterValue, Int.max)
        XCTAssertNotEqual(notifier.emitter, Notifier.defaultInitialValue)
        XCTAssertNotNil(expectedEmitterValue)
        XCTAssertNotEqual(expectedEmitterValue, Notifier.defaultInitialValue)
        XCTAssertEqual(expectedEmitterValue, finalEmitterValue)
    }
    
    func checkOtherEmitter() {
        XCTAssertNotEqual(finalOtherEmitterValue, Int.max)
        XCTAssertNotEqual(notifier.otherEmitter, Notifier.defaultOtherInitialValue)
        XCTAssertNotNil(expectedOtherEmitterValue)
        XCTAssertNotEqual(expectedOtherEmitterValue, Notifier.defaultOtherInitialValue)
        XCTAssertEqual(expectedOtherEmitterValue, finalOtherEmitterValue)
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    var changeExpectation: XCTestExpectation?
    var otherChangeExpectation: XCTestExpectation?
    
    func testObserveEmitterChange() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        observer = ObservingClass(testCase: self)
        XCTAssertEqual(notifier.emitter, Notifier.defaultInitialValue)
        observer.observedObject = notifier
        expectedEmitterValue = 1
        
        changeExpectation = keyValueObservingExpectation(for: self, keyPath: #keyPath(ObserverTestCase.finalEmitterValue)) { (observedObject, changeDict) -> Bool in
            print("change: \(changeDict)")
            guard let oldValue = changeDict[NSKeyValueChangeKey.oldKey] as? Int else {
                XCTFail("There should always be an oldValue in change: \(changeDict.debugDescription)")
                fatalError()
            }
            return oldValue != Int.max
        }
        notifier.emitter = expectedEmitterValue
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(error)
            self.checkEmitter()
        }
    }
    
    func testObserveEmitterChangeInSubclass() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        observer = SubclassObserver(testCase: self)
        XCTAssertEqual(notifier.emitter, Notifier.defaultInitialValue)
        observer.observedObject = notifier
        expectedEmitterValue = 1
        expectedOtherEmitterValue = 2
        
        changeExpectation = keyValueObservingExpectation(for: self, keyPath: #keyPath(ObserverTestCase.finalEmitterValue)) { (observedObject, changeDict) -> Bool in
            print("change: \(changeDict)")
            guard let oldValue = changeDict[NSKeyValueChangeKey.oldKey] as? Int else {
                XCTFail("There should always be an oldValue in change: \(changeDict.debugDescription)")
                fatalError()
            }
            return oldValue != Int.max
        }
        otherChangeExpectation = keyValueObservingExpectation(for: self, keyPath: #keyPath(ObserverTestCase.finalOtherEmitterValue)) { (observedObject, changeDict) -> Bool in
            print("otherChange: \(changeDict)")
            guard let oldValue = changeDict[NSKeyValueChangeKey.oldKey] as? Int else {
                XCTFail("There should always be an oldValue in change: \(changeDict.debugDescription)")
                fatalError()
            }
            return oldValue != Int.max
        }
        notifier.emitter = expectedEmitterValue
        notifier.otherEmitter = expectedOtherEmitterValue
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(error)
            self.checkEmitter()
            self.checkOtherEmitter()
        }
    }
    
}
