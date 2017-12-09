//
//  CsvExporterTest.swift
//  StopwatchTests
//
//  Created by Břetislav Štěpán on 30.11.17.
//  Copyright © 2017 Břetislav Štěpán. All rights reserved.
//

import XCTest
import CoreData

class XCTestCaseWithMemoryManagedObjectContext: XCTestCase {
    
    var context: NSManagedObjectContext? = nil

    override func setUp() {
        super.setUp()
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        context!.persistentStoreCoordinator = persistentStoreCoordinator
    }

}
