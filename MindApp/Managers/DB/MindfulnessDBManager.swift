//
//  MindfulnessDBManager.swift
//  MindApp
//
//  Created by Daniel Davidík on 28.04.2024.
//

import Foundation

/// Manager class for the Mindfulness data with regards to Supabase - includes functions for fetching specifically e.g. activities that the user can practice
class MindfulnessDBManager {
    static let shared = MindfulnessDBManager()
    private let locale = String(Locale.current.identifier.prefix(2))
    
    
    /// Function that fetches all activities tied to the current user
    /// - Returns: Array of ``Activity`` containing all the fetched activities available
    func fetchActivities() async throws -> [Activity] {
        do {
            let result: [Activity] = try await supabase.database
                .from("activity")
                .select("""
                    id,
                    category,
                    image_url,
                    name,
                    activity_breathing (
                        inhale_duration,
                        exhale_duration,
                        hold_duration,
                        second_hold_duration,
                        cycle_count
                    ),
                    activity_localization!inner (
                        locale,
                        title,
                        description,
                        overview,
                        tips,
                        science_desc
                    ),
                    activity_meditation (
                        minutes_duration,
                        seconds_duration,
                        download_url
                    ),
                    mindfulness_type (
                        id,
                        name,
                        icon_name,
                        mindfulness_type_localization (
                            locale,
                            name
                        )
                    )
                """)
                .eq("activity_localization.locale", value: locale)
                .eq("mindfulness_type.mindfulness_type_localization.locale", value: locale)
                .execute()
                .value

            return result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }
    
    /// Function for loading ``Activity.MindfulnessType`` from Supabase
    /// - Returns: Array of ``Activity.MindfulnessType`` fetched
    func fetchMindfulnessTypes() async throws -> [Activity.MindfulnessType] {
        do {
            let result: [Activity.MindfulnessType] = try await supabase.database
                .from("mindfulness_type")
                .select("""
                    id,
                    name,
                    icon_name,
                    mindfulness_type_localization (
                        locale,
                        name
                    )
                """)
                .eq("mindfulness_type_localization.locale", value: locale)
                .order("name")
                .execute()
                .value

            return result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }

    func fetchPartialActivities() async throws -> [PartialActivity] {
        do {
            let result: [PartialActivity] = try await supabase.database
                .from("activity")
                .select("""
                    id,
                    category,
                    image_url,
                    name,
                    activity_localization!inner (
                        locale,
                        title
                    )
                """)
                .eq("activity_localization.locale", value: locale)
                .execute()
                .value

            return result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }

    func fetchPartialActivitiesAllLocales() async throws -> [PartialActivity] {
        do {
            let result: [PartialActivity] = try await supabase.database
                .from("activity")
                .select("""
                    id,
                    category,
                    image_url,
                    name,
                    activity_localization!inner (
                        locale,
                        title
                    )
                """)
                .execute()
                .value

            return result
        } catch {
            Logger.log(error.localizedDescription, .error)
            throw error
        }
    }
}
