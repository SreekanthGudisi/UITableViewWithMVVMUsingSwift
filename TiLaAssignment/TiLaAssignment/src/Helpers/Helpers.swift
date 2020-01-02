//
//  Helpers.swift
//  TiLaAssignment
//
//  Created by Gudisi, Sreekanth on 15/12/19.
//  Copyright © 2019 Gudisi, Sreekanth. All rights reserved.
//

import Foundation

extension String {
    
    func getCurrentDate() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        return result
    }
}

extension String {

    /// Converts a string to a percent-encoded URL, including Unicode characters.
    ///
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    func encodedUrl() -> URL? {
        // Remove preexisting encoding,
        guard let decodedString = self.removingPercentEncoding,
            // encode any Unicode characters so URLComponents doesn't choke,
            let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            // break into components to use proper encoding for each part,
            let components = URLComponents(string: unicodeEncodedString),
            // and reencode, to revert decoding while encoding missed characters.
            let percentEncodedUrl = components.url else {
            // Encoding failed
            return URL(string: self)
        }
        return percentEncodedUrl
    }
}
