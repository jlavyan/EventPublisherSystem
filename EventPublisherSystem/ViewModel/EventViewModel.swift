//
//  EventViewModel.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import Foundation
import Combine

class EventViewModel: ObservableObject {
    init(dataRepository: DateStoreRepository, eventPublishRepository: EventPublishRepository) {
        self.dataRepository = dataRepository
        self.eventPublishRepository = eventPublishRepository
        
        /// Listen ordered events
        cancelable = queueOrder.queue.sink(receiveValue: onNewEvent)
        
        /// Run pending events
        publishPendings()
    }

    // MARK: Listeners
    let finishListener = PassthroughSubject<EventResult<Event>, Never>()
    private let queue = PassthroughSubject<Event, Never>()
    private var cancelable: AnyCancellable?

    // MARK: Repositories
    private let dataRepository: DateStoreRepository
    private let eventPublishRepository: EventPublishRepository
    
    /// For order events
    private var queueOrder = QueueOrder()

    deinit {
        cancelable?.cancel()
    }
    
    // MARK: Public methods
    func add(event: Event){
        queueOrder.add(event: event)
    }
    
    func createFewEvents(){
        (0...100).forEach{ i in
            _ = self.dataRepository.createEvent(subject: "Event index \(i)", payload: "test")
        }
    }
    
    func restartPublish(){
        reInitQueue()
        
        publishPendings()
    }

    
    // MARK: Private methods
    /// Create event for given subject, payload
    func createEvent(subject: String, payload: String) -> Event{
        dataRepository.createEvent(subject: subject, payload: payload)
    }
    
    /// Called when event ready to publish
    private func onNewEvent(event: Event) {
        self.publishEvent(event)
    }
    
    /// This method will post event to server
    private func publishEvent(_ event: Event){
        eventPublishRepository.publishSynchronized(event: event) {  [weak self] result in
            switch result {
            case .success:
                self?.onSuccess(event: event)
            case .failure(let error):
                self?.onError(error: error)
            }
        }

    }
    
    /// Called on success publish
    private func onSuccess(event: Event){
        dataRepository.delete(event: event)
        finishListener.send(.success(event))
    }
    
    /// Called on error publish
    private func onError(error: Error?){
        finishListener.send(.failure(error))
        
        // Reset Queue Order
        reInitQueue()
        
        // Try publish after few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.publishPendings()
        }
    }

    private func publishPendings(){
        dataRepository.events().forEach { event in
            add(event: event)
        }
    }
    
    private func reInitQueue(){
        cancelable?.cancel()

        queueOrder = QueueOrder()

        cancelable = queueOrder.queue.sink(receiveValue: onNewEvent)
    }
}


enum EventResult<Value> {
    case success(Event)
    case failure(Error?)
}
