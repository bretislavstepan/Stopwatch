//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Cocoa
import CoreData

class Sessions {
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(date: Date, duration: Float, label: String) -> SessionMO {
        let entity =  NSEntityDescription.entity(forEntityName: "Session", in:context)
        let newItem = NSManagedObject(entity: entity!, insertInto:context) as! SessionMO
        
        newItem.date = date
        newItem.label = label
        newItem.duration = duration
        
        return newItem
    }
    
    func getById(_ id: NSManagedObjectID) -> SessionMO? {
        return context.object(with: id) as? SessionMO
    }
    
    func getAll() -> [SessionMO] {
        return get(withPredicate: NSPredicate(value:true))
    }
    
    // Gets all that fulfill the specified predicate.
    // Predicates examples:
    // - NSPredicate(format: "name == %@", "Juan Carlos")
    // - NSPredicate(format: "name contains %@", "Juan")
    func get(withPredicate queryPredicate: NSPredicate) -> [SessionMO] {
        let fetchRequest = NSFetchRequest<SessionMO>(entityName: "Session")
        
        fetchRequest.predicate = queryPredicate
        
        do {
            let response = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            return response as! [SessionMO]
            
        } catch let error as NSError {
            // failure
            print(error)
            return [SessionMO]()
        }
    }
    
    func update(updatedPerson: SessionMO) {
        if let session = getById(updatedPerson.objectID) {
            session.label = updatedPerson.label
            session.date = updatedPerson.date
            session.duration = updatedPerson.duration
        }
    }
    
    func delete(id: NSManagedObjectID) {
        if let personToDelete = getById(id) {
            context.delete(personToDelete)
        }
    }
    
    func saveChanges() {
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
}
