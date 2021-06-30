//
//  QueueOrder.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import Foundation
import Combine

/// This classe should order events by group id
class QueueOrder{
    init(global: DispatchQueue = DispatchQueue.global()){
        self.global = global
    }
    
    /// Listen ordered eventins from this queue
    let queue = PassthroughSubject<Event, Never>()
    
    /// In this parameter  grouped queue items
    final private var map = [String: QueueItem]()
    
    /// Stored all listeners
    final private var listeners = [AnyCancellable]()
    
    /// For make safe concurrency
    private let safeThread = DispatchQueue(label: "queueOrder")
    private let global: DispatchQueue
    
    // MARK: Public methods
    /// This methid will sort event by thread for publish
    func add(event: Event){
        global.async {
            self.addInSafe(event: event)
        }
    }
    
    /// Add  event in safe thread
    func addInSafe(event: Event){
        safeThread.sync {
            addImpl(event: event)
        }
    }
    
    deinit {
        // Cancel all listeners
        listeners.forEach{
            $0.cancel()
        }
    }
    
    // MARK: Private methods
    private func addImpl(event: Event){
       let queueItem = itemBy(id: event.groupId ?? "")
       listenQueue(item: queueItem)
        
       queueItem.add(event: event)
    }
    
    private func listenQueue(item: QueueItem){
        if map[item.id] == nil{
            map[item.id] = item
            
            let listener = item.queue.sink(receiveValue: listen)
            listeners.append(listener)
        }
    }
    
    private func listen(event: Event){
        queue.send(event)
    }
    
    /// Get stored QueueItem or create new one
    private func itemBy(id: String) -> QueueItem{
        let item = map[id]
        
        if let itemRequied = item{
            return itemRequied
        }else{
            return createItemBy(id: id)
        }
    }
    
    private func createItemBy(id: String) -> QueueItem{
        let queueItem = QueueItem(id: id)
        return queueItem
    }
}


private class QueueItem{
    init(id: String){
        self.id = id
    }
    
    let id: String
    let queue = PassthroughSubject<Event, Never>()
    
    func add(event: Event){
        queue.send(event)
    }
}
