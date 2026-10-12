//
//  Activity.swift
//  MindApp
//
//  Created by Daniel Davidík on 28.04.2024.
//

import Foundation

/// Self-explanatory, holds information about activities, can be encoded / decoded to / from JSON
struct Activity: Codable, Equatable {
    let id: Int
    let category: MindfulnessCategory
    let name: String
    let imageUrl: String
    let localization: [Localization]
    let breathing: Breathing?
    let meditation: Meditation?
    let types: [Activity.MindfulnessType]
    
    init(id: Int, category: MindfulnessCategory, name: String, imageUrl: String, localization: [Localization], breathing: Breathing?, meditation: Meditation?, types: [Activity.MindfulnessType]) {
        self.id = id
        self.category = category
        self.name = name
        self.imageUrl = imageUrl
        self.localization = localization
        self.breathing = breathing
        self.meditation = meditation
        self.types = types
    }
    
    init(from ae: ActivityEntity) throws {
        self.id = Int(ae.id)
        
        guard let category = ae.category else {
            Logger.log("No category was found for activity")
            throw NSError(domain: "init.activity", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize activity due to missing category", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
        }
        
        guard let mc = MindfulnessCategory(rawValue: category) else {
            Logger.log("Category found is invalid")
            throw NSError(domain: "init.activity", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize activity due to invalid category", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
        }
        
        self.category = mc
        
        guard let name = ae.name else {
            Logger.log("No name was found for activity")
            throw NSError(domain: "init.activity", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize activity due to missing name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
        }
        
        self.name = name
        
        guard let imageUrl = ae.imageUrl else {
            Logger.log("No imageUrl was found for activity")
            throw NSError(domain: "init.activity", code: 6, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize activity due to missing imageUrl", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
        }
        
        self.imageUrl = imageUrl
        
        var tmpLocalization: [Localization] = []
        
        for loc in ae.ac_loc_rel ?? [] {
            if let l = loc as? LocalizationEntity {
                var tips: [String] = []
                
//                for tip in l.loc_tip_rel ?? [] {
//                    if let t = tip as? TipEntity {
//                        if let tipString = t.tip {
//                            tips.append(tipString)
//                        }
//                    }
//                }
                
                if let goodTips = l.tips {
                    tips = try JSONDecoder().decode([String].self, from: goodTips)
                }
                
                guard let locale = l.locale else {
                    Logger.log("No locale was found for localization")
                    throw NSError(domain: "init.activity", code: 7, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize localization due to missing locale", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                }
                
                guard let title = l.title else {
                    Logger.log("No title was found for localization")
                    throw NSError(domain: "init.activity", code: 8, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize localization due to missing title", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                }
                
                guard let description = l.l_description else {
                    Logger.log("No description was found for localization")
                    throw NSError(domain: "init.activity", code: 9, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize localization due to missing description", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                }
                
                let currLoc = Localization(locale: locale, title: title, description: description, overview: l.overview, tips: tips, scienceDesc: l.scienceDesc)
                tmpLocalization.append(currLoc)
            }
        }
        
        self.localization = tmpLocalization
        
        if let br = ae.ac_bre_rel {
            self.breathing = Breathing(inhaleDuration: Int(br.inhaleDuration),
                                       exhaleDuration: Int(br.exhaleDuration),
                                       holdDuration: br.holdDuration == -1 ? nil : Int(br.holdDuration),
                                       cycleCount: Int(br.cycleCount),
                                       secondHoldDuration: br.secondHoldDuration == -1 ? nil : Int(br.secondHoldDuration))
        }
        else {
            self.breathing = nil
        }
        
        if let me = ae.ac_med_rel {
            self.meditation = Meditation(minutesDuration: me.minutesDuration == -1 ? nil : Int(me.minutesDuration),
                                         secondsDuration: me.secondsDuration == -1 ? nil : Int(me.secondsDuration),
                                         downloadUrl: me.downloadUrl)
        }
        else {
            self.meditation = nil
        }
        
        var tmpTypes: [MindfulnessType] = []
        
        for type in ae.ac_type_rel ?? [] {
            if let t = type as? MindfulnessTypeEntity {
                                
                guard let tname = t.name else {
                    Logger.log("No name was found for Mindfulness Type")
                    throw NSError(domain: "init.activity", code: 11, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Type due to missing name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                }
                

                guard let tIconName = t.iconName else {
                    Logger.log("No icon name was found for Mindfulness Type")
                    throw NSError(domain: "init.activity", code: 11, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Type due to missing icon name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                }
                
                var tmpTypeLocs: [MindfulnessType.MindfulnessLocalization] = []
                
                for mindLoc in t.mt_loc_rel ?? [] {
                    if let ml = mindLoc as? MindfulnessLocalizationEntity {
                        
                        guard let locale = ml.locale else {
                            Logger.log("No locale was found for Mindfulness Localization")
                            throw NSError(domain: "init.activity", code: 10, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize MindfulnessLocalization due to missing locale", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                        }
                        
                        guard let name = ml.name else {
                            Logger.log("No name was found for Mindfulness Localization")
                            throw NSError(domain: "init.activity", code: 11, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Localization due to missing name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the ActivityEntity is correctly populated"])
                        }
                        
                        
                        tmpTypeLocs.append(MindfulnessType.MindfulnessLocalization(locale: locale, name: name))
                        
                    }
                }
                                
                tmpTypes.append(MindfulnessType(id: Int(t.id), name: tname, iconName: tIconName, localization: tmpTypeLocs))
                
            }
        }
        
        self.types = tmpTypes.sorted(by: { $0.id < $1.id })
    }
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.name != rhs.name {
            return false
        }
        if lhs.imageUrl != rhs.imageUrl {
            return false
        }
        if lhs.localization != rhs.localization {
            return false
        }
        return true
    }

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case imageUrl = "image_url"
        case localization = "activity_localization"
        case breathing = "activity_breathing"
        case meditation = "activity_meditation"
        case types = "mindfulness_type"
    }

    struct Localization: Codable, Equatable {
        let locale: String
        let title: String
        let description: String
        let overview: String?
        let tips: [String]?
        let scienceDesc: String?

        enum CodingKeys: String, CodingKey {
            case locale
            case title
            case description
            case overview
            case tips
            case scienceDesc = "science_desc"
        }
        
        static func mock() -> Localization {
            return Localization(locale: "en", title: "Unguided session", description: "Tailor your journey...", overview: "Explore your inner thoughts...", tips: [ "Find a quiet and comfortable place...", "Sit or lie down in a position...", "Use your breath as an anchor...", "As thoughts and emotions arise, observe them...", "If it helps, use a simple mantra...", "Consistency is key. Try to meditate..."] , scienceDesc: "Meditation has been shown to have a profound impact on the brain...")
        }
        
        static func == (lhs: Localization, rhs: Localization) -> Bool {
            if lhs.locale != rhs.locale {
                return false
            }
            if lhs.title != rhs.title {
                return false
            }
            if lhs.description != rhs.description {
                return false
            }
            if lhs.overview != rhs.overview {
                return false
            }
            if lhs.tips?.sorted(by: { $0 < $1 }) != rhs.tips?.sorted(by: { $0 < $1 }) {
                return false
            }
            if lhs.scienceDesc != rhs.scienceDesc {
                return false
            }
            return true
        }
    }

    struct Breathing: Codable, Equatable {
        let inhaleDuration: Int
        let exhaleDuration: Int
        let holdDuration: Int?
        let cycleCount: Int
        let secondHoldDuration: Int?

        enum CodingKeys: String, CodingKey {
            case inhaleDuration = "inhale_duration"
            case exhaleDuration = "exhale_duration"
            case cycleCount = "cycle_count"
            case holdDuration = "hold_duration"
            case secondHoldDuration = "second_hold_duration"
        }
        
        static func mock() -> Breathing {
            return Breathing(inhaleDuration: 4, exhaleDuration: 4, holdDuration: 4, cycleCount: 4, secondHoldDuration: 4)
        }
    }

    struct Meditation: Codable, Equatable {
        let minutesDuration: Int?
        let secondsDuration: Int?
        let downloadUrl: String?

        enum CodingKeys: String, CodingKey {
            case minutesDuration = "minutes_duration"
            case secondsDuration = "seconds_duration"
            case downloadUrl = "download_url"
        }
        
        static func mock() -> Meditation {
            return Meditation(minutesDuration: nil, secondsDuration: nil, downloadUrl: nil)
        }
    }

    struct MindfulnessType: Codable, Equatable, Hashable {
        let id: Int
        let name: String
        let iconName: String
        let localization: [MindfulnessLocalization]

        init(id: Int, name: String, iconName: String, localization: [MindfulnessLocalization]) {
            self.id = id
            self.name = name
            self.iconName = iconName
            self.localization = localization
        }
        
        init(from mt: MindfulnessTypeEntity) throws {
                        
            guard let name = mt.name else {
                Logger.log("No name was found for Mindfulness Type")
                throw NSError(domain: "init.mindfulnessType", code: 12, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Type due to missing name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the MindfulnessTypeEntity is correctly populated"])
            }
            
            guard let iconName = mt.iconName else {
                Logger.log("No iconName was found for Mindfulness Type")
                throw NSError(domain: "init.mindfulnessType", code: 12, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Type due to missing iconName", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the MindfulnessTypeEntity is correctly populated"])
            }
            
            self.id = Int(mt.id)
            self.name = name
            self.iconName = iconName
            
            var tmpLocalization: [MindfulnessLocalization] = []
            
            for loc in mt.mt_loc_rel ?? [] {
                if let locEntity = loc as? MindfulnessLocalizationEntity {
                    
                    guard let locName = locEntity.name else {
                        Logger.log("No name was found for Mindfulness Localization")
                        throw NSError(domain: "init.mindfulnessType", code: 14, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Localization due to missing name", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the MindfulnessTypeEntity is correctly populated"])
                    }
                    
                    guard let locLocale = locEntity.locale else {
                        Logger.log("No locale was found for Mindfulness Localization")
                        throw NSError(domain: "init.mindfulnessType", code: 15, userInfo: [NSLocalizedDescriptionKey: "Unable to initialize Mindfulness Localization due to missing locale", NSLocalizedRecoverySuggestionErrorKey: "Please make sure the MindfulnessTypeEntity is correctly populated"])
                    }
                    
                    tmpLocalization.append(MindfulnessLocalization(locale: locLocale, name: locName))
                }
            }
            
            self.localization = tmpLocalization
            
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case iconName = "icon_name"
            case localization = "mindfulness_type_localization"
        }

        struct MindfulnessLocalization: Codable, Equatable, Hashable {
            let locale: String
            let name: String

            enum CodingKeys: String, CodingKey {
                case locale
                case name
            }
            
            static func == (lhs: MindfulnessLocalization, rhs: MindfulnessLocalization) -> Bool {
                if lhs.locale != rhs.locale {
                    return false
                }
                if lhs.name != rhs.name {
                    return false
                }
                return true
            }
            
            static func mock() -> MindfulnessLocalization {
                return MindfulnessLocalization(locale: "en", name: "Calm")
            }
        }
        
        static func == (lhs: MindfulnessType, rhs: MindfulnessType) -> Bool {
            if lhs.id != rhs.id {
                return false
            }
            if lhs.name != rhs.name {
                return false
            }
            if lhs.iconName != rhs.iconName {
                return false
            }
            if lhs.localization != rhs.localization {
                return false
            }
            return true
        }
        
        static func mock() -> MindfulnessType {
            return MindfulnessType(id: 1, name: "calm", iconName: "leaf", localization: [MindfulnessLocalization.mock()])
        }
        
        static func mock(id: Int) -> MindfulnessType {
            let names: [String] = ["calm", "sleep", "relax", "focus", "stress"]
            let iconNames: [String] = ["leaf", "moon.stars", "figure.yoga", "target", "brain.filled.head.profile", "laptopcomputer"]
            return MindfulnessType(id: id, name: names[id-1], iconName: iconNames[id-1], localization: [MindfulnessLocalization.mock()])
        }
        
        static var mockArray: [MindfulnessType] {
            return [.mock(id: 1), .mock(id: 2), .mock(id: 3), .mock(id: 4), .mock(id: 5)]
        }
    }
    
    static func mock() -> Activity {
        return Activity(id: 1, category: .meditation, name: "unguided-meditation", imageUrl: "figure.mind.and.body", localization: [Localization.mock()], breathing: nil, meditation: Meditation.mock(), types: [MindfulnessType.mock()])
        //[1, 3, 4, 5, 7]
    }
    
    static func mock(id: Int) -> Activity {
        if id > 5 {
            Logger.log("Bad ID for Activity mock", .error)
            fatalError()
        }
        let names: [String] = ["unguided-meditation", "box-breathing", "4-7-8-breathing", "equal-breathing", "coherent-breathing"]
        let imageUrls: [String] = ["figure.mind.and.body", "shippingbox", "wind", "equal.square", "water.waves"]
        return Activity(id: id, category: id % 2 == 0 ? .breathing : .meditation, name: names[id-1], imageUrl: imageUrls[id-1], localization: [Localization.mock(), Localization.mock()], breathing: id % 2 == 0 ? Breathing.mock() : nil, meditation: id % 2 == 0 ? nil : Meditation.mock(), types: Activity.MindfulnessType.mockArray)
    }
    
    static var mockArray: [Activity] {
        return [.mock(id: 1), .mock(id: 2), .mock(id: 3), .mock(id: 4), .mock(id: 5)]
    }
}

struct PartialActivity: Codable {
    let id: Int
    let category: MindfulnessCategory
    let name: String
    let imageUrl: String
    let localization: [PartialLocalization]

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case imageUrl = "image_url"
        case localization = "activity_localization"
    }

    struct PartialLocalization: Codable {
        let locale: String
        let title: String
    }
}
