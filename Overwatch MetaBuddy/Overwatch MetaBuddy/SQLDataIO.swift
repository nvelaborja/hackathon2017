//
//  SQLDataIO.swift
//  SQLiteWrapper
//
//  Created by Cindy Oakes on 5/28/16.
//  Copyright © 2016 Cindy Oakes. All rights reserved.
//

//the directory and file url prints, so you can navigate to it and throw the database in the trash between runs while testing
//if you can not find the folders by browing then on the Finder menu at the top click Go=>GoToFolder then type in  Library or
//Developer to help you get to it because apple is hiding them

// be sure and use the readme.txt to get the sql libraries linked up correctly

import UIKit

class SQLDataIO
{
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //static let DBURL = DocumentsDirectory.appendingPathComponent("sqllitetutorial")
    static let DBURL = Bundle.main.url(forResource: "omb", withExtension: "db")
    
    static var items: [String] = []
    
    static var  firstName = ["Cindy", "Jack", "Katherine", "Kyle", "Jared", "Katelyn", "Denye"]
    static var  lastName = ["Oakes", "Oakes", "Delap", "Delap", "Oakes", "Oakes", "Oakes"]
    static var  age = ["55", "66", "33", "28", "22", "20", "8"]
    
    
    static func PerformedSQLCommands() -> [String]
    {
        
        print("\(DocumentsDirectory)")
        print("\(DBURL)")
        
        var dbCommand: String = ""
        
        dbCommand = "CREATE TABLE Family(ID INT PRIMARY KEY NOT NULL, FirstName CHAR(100), LastName CHAR(100), Age INT);"
        updateDatabase(dbCommand)
        
        var databaseRows: [[String]] = [[]]
        
        var id: Int = 0
        
        for i in 0...6
        {
            id = nextID("Family")
            items.append(String(format: "\(id) -> nextID result" ))
            
            dbCommand = "insert into Family(ID, FirstName, LastName, Age) values (\(id), '\(firstName[i])', '\(lastName[i])', '\(age[i])')"
            updateDatabase(dbCommand)
            
        }
        
        dbCommand = "select ID, FirstName, LastName, Age from Family"
        databaseRows = getRows(dbCommand, numColumns: 4)
        printRows(databaseRows)
        
        
        dbCommand = "UPDATE Family SET FirstName = 'Adam' WHERE ID = 1;"
        updateDatabase(dbCommand)
        items.append("ID 1 first name changed ")
        
        
        dbCommand = "select FirstName, LastName, Age from Family where ID = 1"
        databaseRows = getRows(dbCommand, numColumns: 3)
        printRows(databaseRows)
        
        
        dbCommand = "select LastName from Family where ID = 1"
        let lName: String! = dbValue(dbCommand)
        items.append(String(format: "\(lName) -> dbValue result" ))
        
        dbCommand = "select Age from Family where ID = 2"
        let ageInt: Int = dbInt(dbCommand)
        items.append(String(format: "\(ageInt) -> dbInt result" ))
        
        
        dbCommand = "select Age from Family where ID = 2"
        let ageString: String  = dbValue(dbCommand)
        items.append(String(format: "\(ageString) -> dbValue result" ))
        
        
        dbCommand = "DELETE FROM Family WHERE ID = 1;"
        updateDatabase(dbCommand)
        items.append("ID 1 was deleted")
        
        dbCommand = "select FirstName, LastName from Family where LastName = 'Oakes' "
        databaseRows = getRows(dbCommand, numColumns: 2)
        printRows(databaseRows)
        
        
        id = nextID("Family")
        items.append(String(format: "\(id) -> nextID result" ))
        
        dbCommand = String(format: "insert into Family(ID, FirstName, LastName, Age) values (%d, 'Cindy', 'Oakes', '55')", id)
        updateDatabase(dbCommand)
        items.append("Cindy added back in as next record")
        
        dbCommand = "select Age, FirstName, LastName from Family"
        databaseRows = getRows(dbCommand, numColumns: 3)
        printRows(databaseRows)
        
        return items
    }
    
    
    //MARK: Print Rows
    
    static func printRows(_ rows: [[String]])
    {
        for i in 0..<rows.count
        {
            var rowValue = "";
            
            var row: [String] = rows[i]
            
            for j in 0..<row.count
            {
                rowValue += String(format: " %@", row[j])
            }
            
            if (rowValue != "")
            {
                items.append(rowValue)
            }
        }
        
    }
    
    
    //MARK:  Open Database
    
    static func openDatabase() -> OpaquePointer {
//        var db: OpaquePointer? = nil
//        if sqlite3_open(DBURL!.absoluteString, &db) == SQLITE_OK {
//            //do nothing
//        } else {
//            print("Unable to open database. ")
//        }
//        return db!
        
        //
        
        var db : OpaquePointer? = nil
        
        do {
            let manager = FileManager.default
            
            //let documentsURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("asd.db")
            let documentsURL = Bundle.main.path(forResource: "omb", ofType: "db")
            
            var rc = sqlite3_open_v2(documentsURL, &db, SQLITE_OPEN_READWRITE, nil)
            if rc == SQLITE_CANTOPEN {
                let bundleURL = Bundle.main.url(forResource: "asd", withExtension: "db")!
                //try manager.copyItem(at: bundleURL, to: documentsURL)
                //rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
            }
            
            if rc != SQLITE_OK {
                print("Error: \(rc)")
                return db!
            }
            
            return db!
        } catch {
            print(error)
            return db!
        }
        
    }
    
    
    //MARK:  Update Database
    
    static func updateDatabase(_ dbCommand: String)
    {
        var updateStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = SQLDataIO.openDatabase()
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                //do nothing
            } else {
                print("Could not updateDatabase")
            }
        } else {
            print("updateDatabase dbCommand could not be prepared")
        }
        
        sqlite3_finalize(updateStatement)
        
        sqlite3_close(db)
        
    }
    
    //MARK:  Get DBValue
    
    static func dbValue(_ dbCommand: String) -> String
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = SQLDataIO.openDatabase()
        
        var value: String? = nil
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                var getResultCol = sqlite3_column_text(getStatement, 0)
                // value = String(cString: UnsafePointer<CChar>(getResultCol!))
                value = String(cString:getResultCol!)
            }
            
        } else {
            print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        if (value == nil)
        {
            value = ""
        }
        
        return value!
    }
    
    
    
    //MARK: Get Next ID
    
    static func nextID(_ tableName: String!) -> Int
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = SQLDataIO.openDatabase()
        
        let dbCommand = String(format: "select ID from %@ order by ID desc limit 1", tableName)
        
        var value: Int32? = 0
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                value = sqlite3_column_int(getStatement, 0)
            }
            
        } else {
            print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        var id: Int = 1
        if (value != nil)
        {
            id = Int(value!) + 1
        }
        
        return id
    }
    
    
    //MARK: Get DB Int
    
    static func dbInt(_ dbCommand: String!) -> Int
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = SQLDataIO.openDatabase()
        
        var value: Int32? = 0
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                value = sqlite3_column_int(getStatement, 0)
            }
            
        } else {
            print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        var int: Int = 1
        if (value != nil)
        {
            int = Int(value!)
        }
        
        
        return int
    }
    
    
    //MARK:  Get Rows
    
    static func getRows(_ dbCommand: String, numColumns: Int) -> [[String]]
    {
        var outputArray: [[String]] = [[]]
        
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = SQLDataIO.openDatabase()
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            while sqlite3_step(getStatement) == SQLITE_ROW {
                
                var rowArray: [String] = []
                
                for i in  0..<numColumns
                {
                    let val = sqlite3_column_text(getStatement, Int32(i))
                    //let valStr = String(cString: UnsafePointer<CChar>(val!))
                    
                    let valStr = String(cString: val!)
                    
                    
                    rowArray.append(valStr)
                    //print("col: \(i) | value:\(valStr)")
                }
                
                outputArray.append(rowArray)
                
            }
            
        } else {
            print("getRows statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        return outputArray
    }
    
    
    
    
}
