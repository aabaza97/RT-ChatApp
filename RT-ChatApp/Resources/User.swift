//
//  User.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/13/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation



struct User: Codable {
    let userId: String
    let username: String
    let email: String
    
    //file path: directory/email.png
    var profilePictureFilePath: String {
        return "profile_pirctures/\(email).png"
    }
}
