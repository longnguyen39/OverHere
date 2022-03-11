//
//  Time.swift
//  GoChat
//
//  Created by Long Nguyen on 8/21/21.
//

import UIKit
import Firebase //to enable time

struct Time {
    
    static func configureTimeNow(completionBlock: @escaping([String]) -> Void) {
        
        //construct a timestamp, convert to String and upload to database
        let time = Timestamp(date: Date()) //current date
        let dateValue = time.dateValue()
        
        //time long (idx 1)
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeMark = dateFormatter1.string(from: dateValue)
        let timeLong = "\(timeMark)"
        
        //time short (idx 0)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MMM dd"
        let timeMarkShort = dateFormatter2.string(from: dateValue)
        let timeShort = "\(timeMarkShort)"
        
        //time min (idx 2)
        let dateFormatter3 = DateFormatter()
        dateFormatter3.dateFormat = "hh:mm a"
        let timeMarkMin = dateFormatter3.string(from: dateValue)
        let timeMin = "\(timeMarkMin)"
        
        //final
        print("DEBUG-Time: done configuring time..")
        completionBlock([timeShort, timeLong, timeMin])
    }
    
}
