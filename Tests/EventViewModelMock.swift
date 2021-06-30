//
//  EventViewModelMock.swift
//  EventPublisherSystemTests
//
//  Created by Grigori on 6/30/21.
//

import Foundation

class EventViewMocelMock: EventViewModel {
    init() {
        super.init(dataRepository: DataRepositoryMock(), eventPublishRepository: EventPublishRepository(baseUrl: Env.baseUrl))
    }
}
