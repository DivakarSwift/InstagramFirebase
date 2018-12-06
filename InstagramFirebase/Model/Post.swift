//
//  Post.swift
//  InstagramFirebase
//
//  Created by Will Wang on 12/3/18.
//  Copyright © 2018 Will Wang. All rights reserved.
//

import Foundation

struct Post {

    let imageURL: String
    let user: User
    let caption: String
    
    init(user: User, dictionary: [String: Any]) {
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
    }
}
