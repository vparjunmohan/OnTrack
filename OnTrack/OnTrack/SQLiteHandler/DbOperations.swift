//
//  DbOperations.swift
//  OnTrack
//
//  Created by Arjun Mohan on 27/05/22.
//

import UIKit
import SQLite3

class DbOperations: NSObject {
    var db: OpaquePointer!
    var fileURL :URL!
    var count = 1
    func createTable(tableName :String,tableValues:[String:Any], unique: String) -> Bool
    {
        let filename = "onTrack.sqlite" //UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        var fields = ""
        let primarykey = unique
        for (item) in tableValues.enumerated(){
            let val = item.element.value
            let key = item.element.key
            let typo = String(describing: type(of: val))
            switch typo {
            case "Int":
                if(primarykey == key){
                    fields = fields != "" ? fields+" ," + "\(item.element.key) INTEGER PRIMARY KEY" : "\(item.element.key) INTEGER PRIMARY KEY"
                }else{
                    fields = fields != "" ? fields+" ," + "\(item.element.key) INTEGER" : "\(item.element.key) INTEGER"
                }
            default:
                if(primarykey == key){
                    fields = fields != "" ? fields+" ," + "\(item.element.key) TEXT PRIMARY KEY " : "\(item.element.key) TEXT PRIMARY KEY"
                }
                else{
                    fields = fields != "" ? fields+" ," + "\(item.element.key) TEXT" : "\(item.element.key) TEXT"
                }
            }
        }
        
        let query : String! = "CREATE TABLE IF NOT EXISTS \(tableName) (\(fields)) "
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK && sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK
        {
//            print("db path: \(fileURL)")
            return true
        }
        else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error: \(errmsg)")
            return false
        }
    }
    
    func selectTable(tableName: String) -> [Any]{
        
        let filename = "onTrack.sqlite" //UserDefaults.standard.value(forKey: "current_db_file_name") != nil ? UserDefaults.standard.value(forKey: "current_db_file_name") as! String : ""
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            print("db path: \(fileURL)")
            var arrTableColumn:[String] = []
            var stmtGet : OpaquePointer?
            let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
            if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
            {
                while(sqlite3_step(stmtGet) == SQLITE_ROW)
                {
                    arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                    //do something with colName because it contains the column's name
                }
            }
            
            let queryString = "SELECT * FROM \(tableName)"
            //  print(queryString)
            var stmtsa:OpaquePointer?
            
            var arrays = [Any]()
            
            if sqlite3_prepare(db, queryString, -1, &stmtsa, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return [Any]()
            }
            else{
                while(sqlite3_step(stmtsa) == SQLITE_ROW){
                    var dictionary = [String:Any]()
                    for i in 0..<arrTableColumn.count
                    {
                        if  sqlite3_column_text(stmtsa, Int32(i)) != nil , let values = String(cString: sqlite3_column_text(stmtsa, Int32(i))) as? String{
                            dictionary.updateValue(values, forKey: arrTableColumn[i])
                        }else{
                            dictionary.updateValue("", forKey: arrTableColumn[i])
                        }
                        
                    }
                    arrays.append(dictionary)
                }
                count = count+1
            }
            if sqlite3_finalize(stmtGet) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmtGet))
                print("error finalizing prepared statement1: \(errmsg)")
            }
            if sqlite3_finalize(stmtsa) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmtsa))
                print("error finalizing prepared statement2: \(errmsg)")
            }
            if sqlite3_close(db) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error closing database1: \(errmsg)")
            }
            return arrays
        }else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error1: \(errmsg)")
            return [Any]()
        }
    }
    
    func selectTableWhere(tableName: String,selectKey:String,selectValue:Any) -> [Any]{
        
        let filename = "onTrack.sqlite" // UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            var arrTableColumn:[String] = []
            var stmtGet : OpaquePointer?
            let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
            if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
            {
                while(sqlite3_step(stmtGet) == SQLITE_ROW)
                {
                    arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                    //do something with colName because it contains the column's name
                }
            }
            
            let queryString = "SELECT * FROM \(tableName) WHERE \(selectKey) = ?"
            //  print(queryString)
            var stmtsa:OpaquePointer?
            
            var arrays = [Any]()
            
            if sqlite3_prepare(db, queryString, -1, &stmtsa, nil) == SQLITE_OK{
                let typo = String(describing: type(of: selectValue))
                
                switch typo {
                case "Int" :
                    if sqlite3_bind_int(stmtsa, 1, Int32(selectValue as! Int)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                    }
                case "__NSCFNumber":
                    if sqlite3_bind_int(stmtsa, 1, selectValue as! Int32) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                    }
                case "Int32":
                    if sqlite3_bind_int(stmtsa, 1, selectValue as! Int32) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                    }
                case "NSNull":
                    //                        return
                    break
                default:
                    if sqlite3_bind_text(stmtsa, 1, NSString(string: selectValue as! String).utf8String,-1, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                    }
                }
                
                //            if sqlite3_step(stmtsa) != SQLITE_DONE {
                //                print("Successfully deleted row.")
                //                let errmsg = String(cString: sqlite3_errmsg(db)!)
                //                print("Succes binding name: \(errmsg)")
                //            } else {
                while(sqlite3_step(stmtsa) == SQLITE_ROW){
                    var dictionary = [String:Any]()
                    for i in 0..<arrTableColumn.count
                    {
                        if  sqlite3_column_text(stmtsa, Int32(i)) != nil , let values = String(cString: sqlite3_column_text(stmtsa, Int32(i))) as? String{
                            dictionary.updateValue(values, forKey: arrTableColumn[i])
                        }else{
                            dictionary.updateValue("", forKey: arrTableColumn[i])
                        }
                        
                    }
                    arrays.append(dictionary)
                }
                count = count+1
                //            }
            }
            if sqlite3_finalize(stmtGet) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmtGet))
                print("error finalizing prepared statement3: \(errmsg)")
            }
            if stmtsa != nil,sqlite3_finalize(stmtsa) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmtsa))
                print("error finalizing prepared statement4: \(errmsg)")
            }
            if sqlite3_close(db) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error closing database2: \(errmsg)")
            }
            return arrays
            
        }else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error2: \(errmsg)")
            return [Any]()
        }
    }
    
    func insertTable(insertvalues: [String:Any], tableName: String, uniquekey: String)
    {
        if(createTable(tableName:tableName, tableValues:insertvalues, unique : uniquekey )){
            var arrTableColumn:[String] = []
            var stmtGet : OpaquePointer?
            let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
            if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
            {
                while(sqlite3_step(stmtGet) == SQLITE_ROW)
                {
                    arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                    //do something with colName because it contains the column's name
                }
            }
            var valuesQuestion = ""
            for _ in arrTableColumn{
                valuesQuestion = valuesQuestion == ""    ?      "?" : valuesQuestion+",?"
            }
            
            let queryString = "INSERT INTO \(tableName) (\(arrTableColumn.joined(separator:","))) VALUES (\(valuesQuestion))"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{ // changed v2
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table2: \(errmsg)")
            }
            
            for item in arrTableColumn{
                if let val = insertvalues["\(item)"], val != nil{
                    let index = arrTableColumn.firstIndex(of: item)
                    let typo = String(describing: type(of: val))
                    switch typo {
                    case "Float" :
                        if sqlite3_bind_double(stmt, Int32(index!+1), (val as AnyObject).doubleValue) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name4: \(errmsg)")
                        }
                    case "CGFloat" :
                        if sqlite3_bind_double(stmt, Int32(index!+1), (val as AnyObject).doubleValue) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name4: \(errmsg)")
                        }
                    case "Optional<CGFloat>" :
                        if sqlite3_bind_double(stmt, Int32(index!+1), (val as AnyObject).doubleValue) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name4: \(errmsg)")
                        }
                    case "Int32" :
                        if sqlite3_bind_int(stmt, Int32(index!+1), (val as AnyObject).intValue) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name3: \(errmsg)")
                        }
                    case "Int" :
                        if sqlite3_bind_int(stmt, Int32(index!+1), (val as AnyObject).intValue) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name4: \(errmsg)")
                        }
                    case "__NSCFNumber":
                        if floor((val as AnyObject).doubleValue) == (val as AnyObject).doubleValue{
                            if sqlite3_bind_int(stmt, Int32(index!+1), (val as AnyObject).intValue) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("failure binding name5: \(errmsg)")
                            }
                        }else{
                            if sqlite3_bind_double(stmt, Int32(index!+1), (val as AnyObject).doubleValue) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("failure binding name5: \(errmsg)")
                            }
                        }
//                        if sqlite3_bind_int(stmt, Int32(index!+1), Int32(round((val as AnyObject).doubleValue))) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name5: \(errmsg)")
//                        }
                    case "Bool":
                        let value = (val as! Bool) == true ? "true" : "false"
                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name6: \(errmsg)")
                        }
                    case "__NSCFBoolean":
                        let value = (val as! Bool) == true ? "true" : "false"
                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name6: \(errmsg)")
                        }
//                    case "Array<Dictionary<String, Any>>":
//                        let value = IDSUtils().getJSONFromArray(dict: (val as! Array<Dictionary<String, Any>>))
//                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name6: \(errmsg)")
//                        }
//                    case "Array<Any>":
//                        let value = IDSUtils().getJSONFromArray(dict: (val as! Array<Dictionary<String, Any>>))
//                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name6: \(errmsg)")
//                        }
//                    case "__NSArrayI":
//                        let value = IDSUtils().getJSONFromArray(dict: (val as! Array<Dictionary<String, Any>>))
//                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name6: \(errmsg)")
//                        }
//                    case "__NSSingleObjectArrayI":
//                        let value = IDSUtils().getJSONFromArray(dict: (val as! Array<Dictionary<String, Any>>))
//                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name6: \(errmsg)")
//                        }
                    case "NSNull":
                        //                        return
                        break
                    case "__NSArray0":
                        if sqlite3_bind_text(stmt, Int32(index!+1), NSString("").utf8String, -1, nil) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name6: \(errmsg)")
                        }
                        break
//                    case "__NSDictionaryI":
//                        let value = IDSUtils().getJSONFromDict(dict: (val as! NSDictionary) as! [String : Any])
//                        if sqlite3_bind_text(stmt, Int32(index!+1), (value as NSString).utf8String, -1, nil) != SQLITE_OK{
//                            let errmsg = String(cString: sqlite3_errmsg(db)!)
//                            print("failure binding name6: \(errmsg)")
//                        }
//                        break
                    case "Optional<Any>":
                        if val is Int{
                            if sqlite3_bind_int(stmt, Int32(index!+1), (val as AnyObject).intValue) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("failure binding name4: \(errmsg)")
                            }
                        }else if val is CGFloat{
                            if sqlite3_bind_double(stmt, Int32(index!+1), (val as AnyObject).doubleValue) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("failure binding name4: \(errmsg)")
                            }
                        }else{
                            if sqlite3_bind_text(stmt, Int32(index!+1), (val as! NSString).utf8String, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("failure binding name6: \(errmsg)")
                            }
                        }
                    default:
                        if sqlite3_bind_text(stmt, Int32(index!+1), (val as! NSString).utf8String, -1, nil) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                            print("failure binding name6: \(errmsg)")
                        }
                    }
                }
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(stmt)!)
                print("failure inserting hero7: \(errmsg)\(tableName)")
            }
            if sqlite3_finalize(stmtGet) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmtGet))
                print("error finalizing prepared statement6: \(errmsg)")
            }
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(stmt))
                print("error finalizing prepared statement3: \(errmsg)")
            }
            if sqlite3_close(db) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error closing database3: \(errmsg)")
            }
        }
    }
    
    func updateTable(valuesToChange:[String:Any],whereKey:String,whereValue:Any,tableName: String){
        let filename = "onTrack.sqlite" //UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error8: \(errmsg)")
            return
        }
        var arrTableColumn:[String] = []
        var stmtGet : OpaquePointer?
        let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
        if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
        {
            while(sqlite3_step(stmtGet) == SQLITE_ROW)
            {
                arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                //do something with colName because it contains the column's name
            }
        }
        var setValues = ""
        for items in arrTableColumn{
            if let data = valuesToChange[items]{
                let typo = String(describing: type(of: data))
                if data is [[String:Any]]{
                    var value = AppUtils().getJSONFromArray(dict: (data as! Array<Dictionary<String, Any>>))
                    value = value.replacingOccurrences(of: "'", with: "''")
                    setValues = setValues != "" ? setValues + ", \(items) = '\(value)'" : "\(items) = '\(value)'"
                }else if data is String {
                    setValues = setValues != "" ? setValues + ", \(items) = '\(data as! String)'" : "\(items) = '\(data as! String)'"
                }else if data is Int {
                    setValues = setValues != "" ? setValues + ", \(items) = '\(data as! Int)'" : "\(items) = '\(data as! Int)'"
                }else if data is CGFloat {
                    setValues = setValues != "" ? setValues + ", \(items) = '\(data as! CGFloat)'" : "\(items) = '\(data as! CGFloat)'"
                }else if data is Float {
                    setValues = setValues != "" ? setValues + ", \(items) = '\(data as! Float)'" : "\(items) = '\(data as! Float)'"
                }else if(typo == "String" || typo == "__NSCFString" || typo == "NSTaggedPointerString"){
                    setValues = setValues != "" ? setValues + ", \(items) = '\(data)'" : "\(items) = '\(data)'"
                }else if(typo == "NSNull"){
                }else if(typo == "Array<Dictionary<String, Any>>" || typo == "Array<Any>"){
                    var value = AppUtils().getJSONFromArray(dict: (data as! Array<Dictionary<String, Any>>))
                    value = value.replacingOccurrences(of: "'", with: "''")
                    setValues = setValues != "" ? setValues + ", \(items) = '\(value)'" : "\(items) = '\(value)'"
                }else{
                    setValues = setValues != "" ? setValues + ", \(items) = \(data)" : "\(items) = \(data)"
                }
                
            }
        }
        
        let queryString = "UPDATE \(tableName) SET \(setValues) WHERE \(whereKey)=?"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table9: \(errmsg)")
        }
        
        let typo = String(describing: type(of: whereValue))
        
        switch typo {
        case "Int" :
            if sqlite3_bind_int(stmt, 1, Int32(whereValue as! Int)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name10: \(errmsg)")
            }
        case "__NSCFNumber":
            if sqlite3_bind_int(stmt, 1, whereValue as! Int32) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name11: \(errmsg)")
            }
        case "Int32":
            if sqlite3_bind_int(stmt, 1, whereValue as! Int32) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name12: \(errmsg)")
            }
        case "NSNull":
            //                        return
            break
        default:
            if sqlite3_bind_text(stmt, 1, NSString(string: whereValue as! String).utf8String,-1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name13: \(errmsg)")
            }
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(stmt)!)
            print("failure inserting hero14: \(errmsg)")
        }
        if sqlite3_finalize(stmtGet) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmtGet))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_finalize(stmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmt))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error closing database: \(errmsg)")
        }
    }
    
    func deleteTable(deleteKey:String,deleteValue:Any,tableName: String){
        let filename = "onTrack.sqlite"  //UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error15: \(errmsg)")
            return
        }
        
        var arrTableColumn:[String] = []
        var stmtGet : OpaquePointer?
        let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
        if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
        {
            while(sqlite3_step(stmtGet) == SQLITE_ROW)
            {
                arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                //do something with colName because it contains the column's name
            }
        }
        
        let queryString = "DELETE FROM \(tableName) WHERE \(deleteKey) = ?"
        //  print(queryString)
        var stmtsa:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmtsa, nil) == SQLITE_OK {
            
            let typo = String(describing: type(of: deleteValue))
            
            switch typo {
            case "Int" :
                if sqlite3_bind_int(stmtsa, 1, deleteValue as! Int32) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name16: \(errmsg)")
                }
            case "__NSCFNumber":
                if sqlite3_bind_int(stmtsa, 1, deleteValue as! Int32) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name17: \(errmsg)")
                }
            case "Int32":
                if sqlite3_bind_int(stmtsa, 1, deleteValue as! Int32) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name18: \(errmsg)")
                }
            case "NSNull":
                //                        return
                break
            default:
                if sqlite3_bind_text(stmtsa, 1, NSString(string: deleteValue as! String).utf8String,-1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name19: \(errmsg)")
                }
            }
            
            if sqlite3_step(stmtsa) == SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Succes binding name: \(errmsg)")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name21: \(errmsg)")
            }
        } else {
            print("DELETE statement could not be prepared22")
        }
        if sqlite3_finalize(stmtGet) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmtGet))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_finalize(stmtsa) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmtsa))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error closing database: \(errmsg)")
        }
    }
    
    func deleteAllFromTable(tableName: String){
        let filename = "onTrack.sqlite"  // UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("table create error23: \(errmsg)")
            return
        }
        
        var arrTableColumn:[String] = []
        var stmtGet : OpaquePointer?
        let getQuery = "PRAGMA table_info(\(tableName))" // its contain the column name
        if sqlite3_prepare(db, getQuery, -1, &stmtGet, nil) == SQLITE_OK
        {
            while(sqlite3_step(stmtGet) == SQLITE_ROW)
            {
                arrTableColumn.append( String(cString: sqlite3_column_text(stmtGet, 1)))
                //do something with colName because it contains the column's name
            }
        }
        
        let queryString = "DELETE FROM \(tableName)"
        //  print(queryString)
        var stmtsa:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmtsa, nil) == SQLITE_OK {
            
            if sqlite3_step(stmtsa) != SQLITE_DONE {
                print("Successfully deleted row.")
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Succes binding name24: \(errmsg)")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name25: \(errmsg)")
            }
        } else {
            print("DELETE statement could not be prepared26")
        }
        if sqlite3_finalize(stmtGet) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmtGet))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_finalize(stmtsa) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(stmtsa))
            print("error finalizing prepared statement: \(errmsg)")
        }
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error closing database: \(errmsg)")
        }
    }
    
    func deleteDatabase()
    {
        DbOperations().deleteAllFromTable(tableName: "user_info")

    }
    func clearLocalDBForUser(){
        let filename = "onTrack.sqlite"  //UserDefaults.standard.value(forKey: "current_db_file_name") as! String
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Database Deleted!27")
        } catch {
            print("Error on Delete Database!!!28")
        }
        
        
    }

}
