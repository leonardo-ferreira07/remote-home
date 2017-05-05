////
////  DBCommands.swift
////  Remote Home
////
////  Created by Leonardo Vinicius Kaminski Ferreira on 29/02/16.
////  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class DBCommands {
//    
//    var lastEvaluatedKey:[NSObject : AnyObject]!
//    var lock:NSLock?
//    
//    
//    // MARK: Setup Table
//    
//    func setupTable() {
//        //See if the test table exists.
//        DDBDynamoDBManger.describeTable().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            
//            
//            
//            // If the test table doesn't exist, create one.
//            if (task.error != nil && task.error!.domain == AWSDynamoDBErrorDomain) && (task.error!.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
//                
//                
//                return DDBDynamoDBManger.createTable() .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//                    //Handle erros.
//                    if ((task.error) != nil) {
//                        print("Error: \(task.error)")
//                        
//                    } else {
//                        
//                    }
//                    return nil
//                    
//                })
//            } else {
//                //load table contents
//                self.refreshList(true)
//            }
//            
//            return nil
//        })
//    }
//    
//    // MARK: Refresh list
//    func refreshList(startFromBeginning: Bool)  {
//        
//        var tableRows:Array<DDBTableRow>?
//        
//        if (self.lock?.tryLock() != nil) {
//            if startFromBeginning {
//                self.lastEvaluatedKey = nil;
////                self.doneLoading = false
//            }
//        
//            
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//            
//            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//            let queryExpression = AWSDynamoDBScanExpression()
//            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
//            queryExpression.limit = 20;
//            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//                
//                if self.lastEvaluatedKey == nil {
//                    tableRows?.removeAll(keepCapacity: true)
//                }
//                
//                if task.result != nil {
//                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
//                    for item in paginatedOutput.items as! [DDBTableRow] {
//                        tableRows?.append(item)
//                    }
//                    
//                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
//                    if paginatedOutput.lastEvaluatedKey == nil {
////                        self.doneLoading = true
//                    }
//                }
//                
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                
//                if ((task.error) != nil) {
//                    print("Error: \(task.error)")
//                }
//                return nil
//            })
//        }
//    }
//    
//    // MARK: DeleteTableRow
//    func deleteTableRow(row: DDBTableRow) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        dynamoDBObjectMapper.remove(row).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            
//            if ((task.error) != nil) {
//                print("Error: \(task.error)")
//                
//                
//            }
//            return nil
//        })
//        
//    }
//    
//    
//    // MARK: Get Table Row
//    
//    func getTableRow(tableRow: DDBTableRow) {
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        
//        dynamoDBObjectMapper .load(DDBTableRow.self, hashKey: tableRow.UserId, rangeKey: tableRow.GameTitle) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            if (task.error == nil) {
//                if (task.result != nil) {
//                    let tableRowResult = task.result as! DDBTableRow
////                    self.hashKeyTextField.text = tableRow.UserId
////                    self.rangeKeyTextField.text = tableRow.GameTitle
////                    self.attribute1TextField.text = tableRow.TopScore?.stringValue
////                    self.attribute2TextField.text = tableRow.Wins?.stringValue
////                    self.attribute3TextField.text = tableRow.Losses?.stringValue
//                }
//            } else {
//                print("Error: \(task.error)")
//                
//            }
//            return nil
//        })
//    }
//    
//    
//    // MARK: Insert Table Row
//    
//    
//    func insertTableRow(tableRow: DDBTableRow) {
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        
//        dynamoDBObjectMapper.save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            if (task.error == nil) {
//                print("Inserted new table row")
//                
//            } else {
//                print("Error: \(task.error)")
//                
//            }
//            
//            return nil
//        })
//    }
//    
//    
//    // MARK: Update Table Row
//    
//    
//    func updateTableRow(tableRow:DDBTableRow) {
//        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        
//        dynamoDBObjectMapper .save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//            if (task.error == nil) {
//                print("Ok, updated table row")
//                
//            } else {
//                print("Error: \(task.error)")
//            
//            }
//            
//            return nil
//        })
//    }
//    
//    
//}