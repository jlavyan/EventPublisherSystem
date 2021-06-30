//
//  DataRepositoryMock.swift
//  EventPublisherSystemTests
//
//  Created by Grigori on 6/30/21.
//

import Foundation

class DataRepositoryMock: DateStoreRepository {
    func generateEvent() -> Event{
        return createEvent(subject: subjects.randomElement() ?? "", payload: payloads.randomElement() ?? "")
    }
    
    func generateEvent(groupId: String) -> Event{
        let event = createEvent(subject: subjects.randomElement() ?? "", payload: payloads.randomElement() ?? "")
        event.groupId = groupId
        return event
    }

    func saveContext(){
        try! viewContext.save()
    }

    private let subjects = ["Katherine read a book.", "The pasta and salad", "The school", "When will we go to the beach?"]
    private let payloads = ["This sentence is about Katherine reading. It is a simple subject.", "This sentence is about Peter and his class watching. It is a compound subject", "This sentence is an imperative sentence, or a command. The verb is clean, and the understood subject is ", "When Troy threw the ball to "]
}
