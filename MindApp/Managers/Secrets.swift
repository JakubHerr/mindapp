//
//  Secrets.swift
//  MindApp
//
//  Created by Jan Gutwirth on 10.02.2025.
//

import Foundation

//as of right now (24.2.2025) all of the duplicate URLs and API keys are the same in the secrets file, but could change in the future

struct Secrets {
    static var supabaseURL: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Supabase"] as? [String: Any],
              let url = serviceDict["URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Supabase"] as? [String: Any],
              let url = serviceDict["URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#endif
        return url
    }
    
    static var supabaseAPIKey: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Supabase"] as? [String: Any],
              let apiKey = serviceDict["API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Supabase"] as? [String: Any],
              let apiKey = serviceDict["API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#endif
        return apiKey
    }
    
    static var reflectionURL: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["REFLECTION_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let url = serviceDict["REFLECTION_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#endif
        return url
    }
    
    static var reflectionAPIKey: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["REFLECTION_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["REFLECTION_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#endif
        return apiKey
    }
    
    static var healthSummaryURL: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_SUMMARY_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_SUMMARY_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#endif
        return url
    }
    
    static var healthSummaryAPIKey: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_SUMMARY_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_SUMMARY_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#endif
        return apiKey
    }
    
    static var healthMotivatorURL: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_MOTIVATOR_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_MOTIVATOR_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#endif
        return url
    }
    
    static var healthMotivatorAPIKey: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_MOTIVATOR_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_MOTIVATOR_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#endif
        return apiKey
    }
    
    static var healthSupporterURL: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_SUPPORTER_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let url = serviceDict["HEALTH_SUPPORTER_URL"] as? String else {
            Logger.log("URL for Supabase not found", .error)
            return ""
        }
#endif
        return url
    }
    
    static var healthSupporterAPIKey: String {
#if DEBUG
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["Debug"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_SUPPORTER_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#else
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let releaseDict = dict["Release"] as? [String: Any],
              let serviceDict = releaseDict["Dify"] as? [String: Any],
              let apiKey = serviceDict["HEALTH_SUPPORTER_API_KEY"] as? String else {
            Logger.log("API Key for Supabase not found", .error)
            return ""
        }
#endif
        return apiKey
    }
    
    static func difyMessageRatingURL(messageId: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["General"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["MESSAGE_FEEDBACK"] as? String else {
            Logger.log("URL for Dify message feedback was not found", .error)
            return ""
        }
        return url.replacing(":message_id", with: messageId)
    }
    
    static var difyCompletionURL: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["General"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["COMPLETION_URL"] as? String else {
            Logger.log("URL for Dify message feedback was not found", .error)
            return ""
        }
        return url
    }
    
    static var difyChatflowURL: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let debugDict = dict["General"] as? [String: Any],
              let serviceDict = debugDict["Dify"] as? [String: Any],
              let url = serviceDict["CHATFLOW_URL"] as? String else {
            Logger.log("URL for Dify message feedback was not found", .error)
            return ""
        }
        return url
    }
    
}
