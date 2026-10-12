//
//  AIAppDBManager.swift
//  MindApp
//
//  Created by Jan Gutwirth on 05.03.2025.
//

import Foundation

enum AIAppFetchResult: Codable {
    case success(AIApp)
    case failure
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(AIApp.self))
        } catch {
            self = .failure
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success(let aiApp):
            try container.encode(aiApp)
        case .failure:
            Logger.log("Encoding failure", .error)
        }
    }
}

class AIAppDBManager {
    static let shared = AIAppDBManager()
    private let locale = String(Locale.current.identifier.prefix(2))
    
    
    /// Function that fetches all AI apps
    /// - Returns: Array of ``AIApp`` containing all the fetched AI apps  available
    func fetchAIApps() async throws -> [AIApp] {
        do {
            let result: [AIApp] = try await supabase.database
                .from("ai_app")
                .select("""
                    id,
                    api_key,
                    parameters,
                    icon_name,
                    ai_app_localization (
                        title,
                        description,
                        locale
                    ),
                    ai_app_url!left (
                        id,
                        url,
                        description
                    )
                """)
                .execute()
                .value

            return result.isEmpty ? [] : result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }
    
    func fetchOwnAIApps() async throws -> [AIApp] {
        do {
            let permissionResult: [[String: Int]] = try await supabase.database
                        .from("user_app_permission")
                        .select("app_id")
                        .execute()
                        .value
            
            let aiAppIDs = permissionResult.compactMap{ $0["app_id"] }
            
            let rawResult: [AIAppFetchResult] = (try? await supabase.database
                .from("ai_app")
                .select("""
                            id,
                            api_key,
                            parameters,
                            icon_name,
                            ai_app_localization (
                                title,
                                description,
                                locale
                            ),
                            ai_app_url!left (
                                id,
                                url,
                                description
                            )
                        """)
                    .in("id", value: aiAppIDs)
                    .execute()
                    .value) ?? []
            
            // Filtering out failures and keeping valid AIApp instances
            let validApps = rawResult.compactMap { result in
                switch result {
                case .success(let aiApp):
                    return aiApp
                case .failure:
                    Logger.log("Skipping failed AIApp", .error)
                    return nil
                }
            }
            
            return validApps
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }
}
