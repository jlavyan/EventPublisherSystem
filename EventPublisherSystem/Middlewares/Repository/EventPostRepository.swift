//
//  DataStoreRepository.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import Foundation
import Combine

class EventPublishRepository: RestRepository {
    override init(baseUrl: String){
        super.init(baseUrl: baseUrl)
    }
    
    func publishSynchronized(event: Event, then handler: @escaping (Result<Data>) -> Void){
        let semaphore = DispatchSemaphore(value: 0)

        publish(event: event) { result in
            handler(result)
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
    }

    func publish(event: Event, then handler: @escaping (Result<Data>) -> Void){
        let path = "publish/\(event.subject?.urlPercentage ?? "")"
        let body = event.payload?.data(using: .utf8)
        
        post(path: path, body: body, then: handler)
    }
}


private extension String{
    var urlPercentage: String{
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
