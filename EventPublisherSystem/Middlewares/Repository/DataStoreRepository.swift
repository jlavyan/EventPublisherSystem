//
//  DataStoreRepository.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import Foundation
import CoreData

class DateStoreRepository {
    private let controller = PersistenceController.shared
    
    var viewContext: NSManagedObjectContext {
        controller.container.viewContext
    }
    
    func createEvent(subject: String, payload: String) -> Event{
        let item = Event(context: viewContext)
        item.subject = subject
        item.payload = payload
        item.createdDate = Date()
        item.groupId = "\(Thread.current)"

        return item
    }
    

    func events() -> [Event]{
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Event.createdDate, ascending: true)]
        
        let events = try? viewContext.fetch(fetchRequest)

        let evs =  events as? [Event] ?? []
        print(evs.count)
        return evs
    }
    
    func delete(event: Event){
        viewContext.delete(event)
        
        try? viewContext.save()
    }

}
