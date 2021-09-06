//
//  User.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 06/09/2021.
//

import Foundation

class User {
    private struct Keys {
        static let pseudonym = "pseudonym"
    }
    static var pseudonym: String {
        get {
            UserDefaults.standard.string(forKey: Keys.pseudonym) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.pseudonym)
        }
    }
}
