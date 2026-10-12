//
//  URL.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import Foundation

extension URL {
    static func makeShareUrl(for path: String) -> URL? {
        URL(string: "mindapp://vse.cz/")
    }
    
    func valueOf(queryParameter: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        return url.queryItems?
            .first { $0.name == queryParameter }?
            .value
    }
}
