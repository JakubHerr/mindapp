//
//  CoreDataDBManager.swift
//  MindApp
//
//  Created by Jan Gutwirth on 15.01.2025.
//

import Foundation
import CoreData

class CoreDataDBManager {
    
    let activityContainer: NSPersistentContainer
    
    static let shared = CoreDataDBManager()
    
    init() {
        activityContainer = NSPersistentContainer(name: "ActivityContainer")
        activityContainer.loadPersistentStores { ( description, error ) in
            if let error = error {
                Logger.log("Error setting up Activity Container: \(error)", .error)
            }
        }
    }
    
    func fetchMindfulnessTypesSortedByName() -> [Activity.MindfulnessType] {
        let types = fetchMindfulnessTypes()
        return types.sorted(by: { $0.name < $1.name })
    }
    
    func fetchMindfulnessTypes() -> [Activity.MindfulnessType] {
        Logger.log("Fetching mindfulness types from CoreData...")
        let fetchRequest: NSFetchRequest<MindfulnessTypeEntity> = MindfulnessTypeEntity.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.includesPendingChanges = true
        
        do {
            let typeEntities = try activityContainer.viewContext.fetch(fetchRequest)
            
            var tmpTypes: [Activity.MindfulnessType] = []
            
            for te in typeEntities {
                try tmpTypes.append(Activity.MindfulnessType(from: te))
            }
            
            Logger.log("Fetched types: \(tmpTypes.count)")
            
            return Array<Activity.MindfulnessType>(tmpTypes)
            
        } catch {
            Logger.log("Failed to fetch types: \(error)")
            return []
        }
    }
    
    func fetchOrCreateMindfulnessType(from type: Activity.MindfulnessType, context: NSManagedObjectContext) -> MindfulnessTypeEntity {
        let fetchRequest: NSFetchRequest<MindfulnessTypeEntity> = MindfulnessTypeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", type.id)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.includesPendingChanges = true

        if let existingType = try? context.fetch(fetchRequest).first {
            return existingType
        } else {
            let newType = MindfulnessTypeEntity(context: context)
            newType.name = type.name
            newType.id = Int64(type.id)
            newType.iconName = type.iconName
            
            var locs: [MindfulnessLocalizationEntity] = []
            for loc in type.localization {
                let newLoc = MindfulnessLocalizationEntity(context: context)
                newLoc.locale = loc.locale
                newLoc.name = loc.name
                locs.append(newLoc)
            }
            
            newType.mt_loc_rel = NSSet(array: locs)
            
            return newType
        }
    }
    
    func fetchActivitiesSortedByName() -> [Activity] {
        let activities = fetchActivities()
        return activities.sorted(by: { $0.name < $1.name })
    }
    
    func fetchActivities() -> [Activity] {
        Logger.log("Fetching activities from CoreData...")
        let fetchRequest: NSFetchRequest<ActivityEntity> = ActivityEntity.fetchRequest()
        
        do {
            let activityEntities = try activityContainer.viewContext.fetch(fetchRequest)
            
            var tmpActivities: [Activity] = []
            
            for activityEntity in activityEntities {
                try tmpActivities.append(Activity(from: activityEntity))
            }
            
            Logger.log("Fetched \(tmpActivities.count) activities from CoreData", .success)
            
            return tmpActivities
            
        } catch {
            Logger.log("Failed to fetch activities: \(error)", .error)
            return []
        }
    }
    
    func fetchActivitiesSortedById() -> [Activity] {
        return fetchActivities().sorted(by: { $0.id < $1.id })
    }
    
    func saveMindfulnessTypes(types: [Activity.MindfulnessType]) {
        let fetched: [Activity.MindfulnessType] = fetchMindfulnessTypes().sorted(by: { $0.id < $1.id})
        let sorted: [Activity.MindfulnessType] = types.sorted(by: { $0.id < $1.id })
        let context = activityContainer.viewContext
        context.performAndWait {
            if fetched == sorted {
                Logger.log("Mindfulness Types for saving are already saved", .info)
                return
            }
            else {
                self.deleteActivities()
            }
            for type in sorted {
                _ = self.fetchOrCreateMindfulnessType(from: type, context: context)
            }
            do {
                try context.save()
                Logger.log("Saved new types to CoreData", .success)
            }
            catch let error {
                Logger.log("Error saving: \(error)")
            }
        }
        
    }
    
    func saveActivities(activities: [Activity]) {
        let context = activityContainer.viewContext
        context.performAndWait {
            let fetchedActivities = self.fetchActivitiesSortedById()
            let sortedActivities = activities.sorted(by: { $0.id < $1.id })
            
            if fetchedActivities == sortedActivities {
                Logger.log("Activities already saved, skipping...", .info)
                return
            } else {
                self.deleteActivities()
            }
            
            for activity in activities {
                let activityEntity = ActivityEntity(context: context)
                activityEntity.id = Int64(activity.id)
                activityEntity.name = activity.name
                activityEntity.category = activity.category.rawValue
                activityEntity.imageUrl = activity.imageUrl
                
                if let breathing = activity.breathing {
                    activityEntity.ac_bre_rel = BreathingEntity(from: breathing, context: context)
                }
                
                if let meditation = activity.meditation {
                    activityEntity.ac_med_rel = MeditationEntity(from: meditation, context: context)
                }
                
                var locs: [LocalizationEntity] = []
                for loc in activity.localization {
                    locs.append(LocalizationEntity(from: loc, context: context))
                }
                activityEntity.ac_loc_rel = NSSet(array: locs)
                
                var mindfulnessEntities: Set<MindfulnessTypeEntity> = []
                //                    var mindfulnessEntities: [MindfulnessTypeEntity] = []
                for type in activity.types {
                    let typeEntity = self.fetchOrCreateMindfulnessType(from: type, context: context)
                    mindfulnessEntities.insert(typeEntity) // just to be sure there are no duplicates
                    //                        mindfulnessEntities.append(typeEntity)
                }
                
                activityEntity.ac_type_rel = NSSet(set: mindfulnessEntities)
                //                    activityEntity.ac_type_rel = NSSet(array: mindfulnessEntities)
            }
            
            do {
                try context.save()
                Logger.log("Successfully saved new activities to CoreData.", .success)
            } catch {
                Logger.log("Error saving activities: \(error)", .error)
            }
        }
    }
    
    func deleteAll() {
        deleteActivities()
        deleteTypes()
    }
    
    func deleteActivities() {
        let fetchRequest: NSFetchRequest<ActivityEntity> = ActivityEntity.fetchRequest()
        let context = activityContainer.viewContext
        context.performAndWait {
            do {
                let activities = try context.fetch(fetchRequest)
                for activity in activities {
                    context.delete(activity)
                }
                try context.save()
                Logger.log("Deleted all activities")
            } catch {
                Logger.log("Error deleting objects: \(error)", .error)
            }
        }
    }
    
    func deleteTypes() {
        let fetchRequest: NSFetchRequest<MindfulnessTypeEntity> = MindfulnessTypeEntity.fetchRequest()
        let context = activityContainer.viewContext
        context.performAndWait {
            do {
                let types = try context.fetch(fetchRequest)
                
                for type in types {
                    context.delete(type)
                }
                try context.save()
                Logger.log("Deleted all types")
            } catch {
                Logger.log("Error deleting objects: \(error)", .error)
            }
        }
    }
}

extension BreathingEntity {
    convenience init(from b: Activity.Breathing, context: NSManagedObjectContext) {
        self.init(context: context)
        self.cycleCount = Int64(b.cycleCount)
        self.exhaleDuration = Int64(b.exhaleDuration)
        if let holdDuration = b.holdDuration {
            self.holdDuration = Int64(holdDuration)
        }
        else {
            self.holdDuration = -1
        }
        if let secondHoldDuration = b.secondHoldDuration {
            self.secondHoldDuration = Int64(secondHoldDuration)
        }
        else {
            self.secondHoldDuration = -1
        }
        self.inhaleDuration = Int64(b.inhaleDuration)
    }
}

extension LocalizationEntity {
    convenience init(from l: Activity.Localization, context: NSManagedObjectContext) {
        self.init(context: context)
        self.l_description = l.description
        self.locale = l.locale
        self.overview = l.overview
        self.scienceDesc = l.scienceDesc
        self.title = l.title
        
        if let tips = l.tips {
            self.tips = try? JSONEncoder().encode(tips)
        }
    }
}

extension MeditationEntity {
    convenience init(from m: Activity.Meditation, context: NSManagedObjectContext) {
        self.init(context: context)
        self.downloadUrl = m.downloadUrl
        if let minutesDuration = m.minutesDuration {
            self.minutesDuration = Int64(minutesDuration)
        }
        else {
            self.minutesDuration = -1
        }
        if let secondsDuration = m.secondsDuration {
            self.secondsDuration = Int64(secondsDuration)
        }
        else {
            self.secondsDuration = -1
        }
    }
}

extension NSManagedObject {
    // Override default init to ensure entities are inserted into the correct context:
    // https://stackoverflow.com/questions/51851485/multiple-nsentitydescriptions-claim-nsmanagedobject-subclass/
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
