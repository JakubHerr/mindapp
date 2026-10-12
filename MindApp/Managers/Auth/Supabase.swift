//
//  SupabaseClient.swift
//  MindApp
//
//  Created by Michael Slavev on 13.04.2024.
//

import Foundation
import Supabase

/// An instance of a supabase client to be used to fetch data from supabase database
let supabase = SupabaseClient(
    supabaseURL: URL(string: Secrets.supabaseURL)!,
    supabaseKey: Secrets.supabaseAPIKey
)
