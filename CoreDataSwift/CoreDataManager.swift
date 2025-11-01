
import Foundation
import CoreData
import UIKit

class CoreDataManager{
 static let shared = CoreDataManager()
    
    let container:NSPersistentContainer
    var context :NSManagedObjectContext{
        container.viewContext
    }
    
    private init(){
        container = NSPersistentContainer(name: "CoreDataSwift")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
         }
      }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
