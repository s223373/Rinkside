//
//  NHLRoster.swift
//  Rinkside
//
//  Created by Nik Bar on 11/26/24.
//
import SwiftUI

struct NHLRoster: Codable, CustomStringConvertible {
    let forwards: [NHLPerson]
    let defensemen: [NHLPerson]
    let goalies: [NHLPerson]
    
    enum CodingKeys: String, CodingKey {
        case forwards = "forwards"
        case defensemen = "defensemen"
        case goalies = "goalies"
    }
    
    var description: String {
        return "forwards: \(forwards.count), defensemen: \(defensemen.count), goalies: \(goalies.count)"
    }
}

struct NHLPerson: Codable, CustomStringConvertible {
    var id: Int
    var headshot: String
    var firstName: NHLType
    var lastName: NHLType
    var sweaterNumber: Int?
    var positionCode: String
    var shootsCatches: String
    var heightInInches: Int
    var weightInPounds: Int
    var heightInCentimeters: Int
    var weightInKilograms: Int
    var birthDate: String
    var birthCity: NHLType?
    var birthCountry: String?
    var birthStateProvince: NHLType?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case headshot = "headshot"
        case firstName = "firstName"
        case lastName = "lastName"
        case sweaterNumber = "sweaterNumber"
        case positionCode = "positionCode"
        case shootsCatches = "shootsCatches"
        case heightInInches = "heightInInches"
        case weightInPounds = "weightInPounds"
        case heightInCentimeters = "heightInCentimeters"
        case weightInKilograms = "weightInKilograms"
        case birthDate = "birthDate"
        case birthCity = "birthCity"
        case birthCountry = "birthCountry"
        case birthStateProvince = "birthStateProvince"
    }
    
    var description: String {
        return "\(id)"
    }
}

struct NHLType: Codable, CustomStringConvertible {
    var def: String
    var cs: String?
    var fi: String?
    var sk: String?
    
    enum CodingKeys: String, CodingKey {
        case def = "default"
        case cs = "cs"
        case fi = "fi"
        case sk = "sk"
    }
    
    var description: String {
        return def
    }
    
}
