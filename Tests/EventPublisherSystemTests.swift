//
//  EventPublisherSystemTests.swift
//  EventPublisherSystemTests
//
//  Created by Grigori on 6/30/21.
//

import XCTest
@testable import EventPublisherSystem
import Combine
class EventPublisherSystem: XCTestCase {

    var cancelable: AnyCancellable?
    let eventViewModel = EventViewMocelMock()

    /// Publish one event
    func testPublishOneEvent() throws {
        // Initialize repositories
        let dataRepository = DataRepositoryMock()
        let eventViewModel = EventViewMocelMock()

        let event = dataRepository.generateEvent()
        let promise = expectation(description: "Status code: 200")

        cancelable = eventViewModel.finishListener.sink { result in
            switch result {
            case .success:
                promise.fulfill()
            case .failure(let error):
                XCTFail("Error: \(String(describing: error))")
                break
            }
        }

        eventViewModel.add(event: event)

        wait(for: [promise], timeout: 5)
    }
    
    /// Test serialize call by group id
    func testPendingEvents() throws {
        // Initialize repositories
        let dataRepository = DataRepositoryMock()
        let promise = expectation(description: "Status code: 200")
        let array = (0..<10).map { $0 }
        var copy = array.map { $0 }
        cancelable = eventViewModel.finishListener.sink { result in
            switch result {
            case .success(let event):
                if event.groupId == "\(copy[0])"{
                    copy.removeFirst()
                }else{
                    XCTAssert(true, "Serialize add error")
                    promise.fulfill()
                }
            case .failure(let error):
                XCTAssert(true, "Error: \(String(describing: error))")
                promise.fulfill()
                break
            }
            
            if copy.count == 0{
                promise.fulfill()
            }
        }
        
        for i in array{
            let event = dataRepository.generateEvent(groupId: "\(i)")
            eventViewModel.add(event: event)
            usleep(1000)
        }



        wait(for: [promise], timeout: 15)
    }

    override func setUpWithError() throws {
        print("Error on setup")
    }

    override func tearDownWithError() throws {
        print("Test finished with fail")
    }
}
