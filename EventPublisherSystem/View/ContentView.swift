//
//  ContentView.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var viewModel = EventViewModel(dataRepository: DateStoreRepository(), eventPublishRepository: EventPublishRepository(baseUrl: Env.baseUrl))

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.createdDate, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Event>

    var body: some View {
        VStack{
            HStack{
                Button("Create", action: onCreateEvents)
                    .padding(.leading, 20)

                Spacer()
                Button("Run", action: restartPublish)
                    .padding(.trailing, 20)
            }.padding()
            
            List {
                ForEach(items) { item in
                    Text(item.subject ?? "")
                }
            }
            .padding(.top, 200)

            Spacer()
        }.background(Color.white)
    }
    
    func onCreateEvents(){
        viewModel.createFewEvents()
    }
    
    func restartPublish(){
        viewModel.restartPublish()
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
