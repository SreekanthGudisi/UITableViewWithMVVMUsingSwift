//
//  ListViewModel.swift
//  TiLaAssignment
//
//  Created by Gudisi, Sreekanth on 15/12/19.
//  Copyright © 2019 Gudisi, Sreekanth. All rights reserved.
//

import UIKit
import Foundation

class ViewModel {
    
    // Closure use for notifi
    var reloadList = {() -> () in }
    var errorMessage = {(message : String) -> () in }
    
    let date = Date()
    let formatter = DateFormatter()

    
    ///Array of List Model class
    var articlesArray : [Articles] = []{
        ///Reload data when data set
        didSet{
            reloadList()
        }
    }
    
    // Get data from API
    func getServicecall() {
        
        let urlString: String = "https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=\(GlobalVariableInformation.instance().apiKeyString)&pageSize=\(GlobalVariableInformation.instance().pageSize)&page=\(GlobalVariableInformation.instance().page)"
        
        let encodedUrl = urlString.encodedUrl()
        print(encodedUrl as Any)
        // Create the Request with URLRequest
        var request = URLRequest(url: encodedUrl!)
        request.httpMethod = "GET"
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("authorization", forHTTPHeaderField: "x-api-key")
        //create the session object
        let session = URLSession.shared
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            // Error
            if let error = error {
                print("error:", error)
                return
            }
            // Response Status with HTTPURLResponse
            let responseStatus = response as? HTTPURLResponse
            print("responseStatus Code", responseStatus as Any)
            do {
                guard let data = data else {
                    return
                }
                // Using Decoder
                let decode = JSONDecoder()
                let response = try decode.decode(ServiceResponseModel.self, from: data)
            //    print(response)
                // Creating DispatchGroup
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    GlobalVariableInformation.instance().totalItems = response.totalResults!
                    self.articlesArray.append(contentsOf: response.articles!)
                    group.leave()
                }
                group.enter()
                DispatchQueue.main.async {
                    GlobalVariableInformation.instance().totalItems = response.totalResults!
                    self.articlesArray.append(contentsOf: response.articles!)
                    group.leave()
                }
                group.enter()
                DispatchQueue.main.async {
                    GlobalVariableInformation.instance().totalItems = response.totalResults!
                    self.articlesArray.append(contentsOf: response.articles!)
                    group.leave()
                }
                group.notify(queue: .main) {
                    // Alert
                }
            } catch {
                print("Error ->\(error.localizedDescription)")
                self.errorMessage(error.localizedDescription)
            }
        })
        task.resume()
    }
}

