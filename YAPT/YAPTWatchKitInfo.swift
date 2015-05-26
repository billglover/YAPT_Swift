//
//  YAPTWatchKitInfo.swift
//  YAPT
//
//  Created by Bill Glover on 25/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import Foundation

class YAPTWatchKitInfo: NSObject {
    
    let action: String?
    let replyBlock: ([NSObject : AnyObject]!) -> Void
    
    init(userInfo: [NSObject : AnyObject]?, reply: ([NSObject : AnyObject]!) -> Void) {

        // capture the action in a property
        if let userInfoDictionary = userInfo as? [String : AnyObject] {
            action = userInfoDictionary["action"] as? String
        } else {
            action = nil
        }
        
        // capture the reply block for future use
        replyBlock = reply
    }
    
}