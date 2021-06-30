//
//  NetworkRepository.swift
//  EventPublisherSystem
//
//  Created by Grigori on 6/30/21.
//

import Foundation

protocol NetworkRepository {
    
}

class RestRepository: NetworkRepository {
    init(baseUrl: String){
        self.baseUrl = baseUrl
    }
    private var baseUrl: String
    
    
    func post(path: String, body: Data?, then handler: @escaping (Result<Data>) -> Void){
        let url = URL(string: "\(baseUrl)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard let response = response as? HTTPURLResponse,
                error == nil else {
                self?.logError(error)
                handler(.failure(error))
                return
            }

            guard 200 == response.statusCode else {
                self?.logError(error)
                handler(.failure(error))
                return
            }
            
            handler(.success)
        }

        task.resume()
    }
}

private extension RestRepository{
    func logError(_ error: Error?){
        print("error", error ?? "Unknown error")
    }
    
    func logError(_ response: HTTPURLResponse){
        print("statusCode should be 200, but is \(response.statusCode)")
        print("response = \(response)")
    }

}

enum Result<Value> {
    case success
    case failure(Error?)
}
