//
//  OMBDatabaseManager.swift
//  Overwatch MetaBuddy
//
//  Created by Nathan VelaBorja on 2/4/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class OMBDatabaseManager: NSObject {
    var results : [[String]] = []
    var commandString : String = "select * from hero;"

    func doTest () {
        results = SQLDataIO.getRows(commandString, numColumns: 6)
        
        var nothing = "something";
    }
    
}
