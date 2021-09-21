//
//  VertretungsPlan.swift
//  VertretungsPlan
//
//  Created by Michael Van straten on 16.09.21.
//

import Foundation

struct KantAppConstans {
    static var VertretungsBaseURL: String = "https://kantschule-falkensee.de/uploads/dmiadgspahw/vertretung/Druck_Kla_"
}

struct VertretungsPlanDataModel {
    
    private(set) var VertretungsStrunden = Array<VertretungsStunde>()
    
    var UserStufe : Stufe?
    var VertretungsPlanStatus : VertretungsPlanAppStatus = .NoUnits
    
    struct VertretungsStunde : Identifiable {
        let id : UUID = UUID()
        var Ausfall : Bool? = nil
        var Zeitspan : String? = nil
        var Raum : String? = nil
        var Lehrer : String? = nil
        var Fach : String? = nil
        var Text1 : String? = nil
        var Text2 : String? = nil
    }
    
    enum Stufe : Hashable, Codable {
        case Siebtestufe (Klasse)
        case Achtestufe (Klasse)
        case Neuntestufe (Klasse)
        case Zentestufe (Klasse)
        case Elftestufe
        case Zwölftestufe
        case Dreizehntestufe
        
        var URLPath: String {
            switch self {
            case .Siebtestufe:
                return "7\(GetKlasse(self)).htm"
            case .Achtestufe:
                return "8\(GetKlasse(self)).htm"
            case .Neuntestufe:
                return "9\(GetKlasse(self)).htm"
            case .Zentestufe:
                return "10\(GetKlasse(self)).htm"
            case .Elftestufe:
                return "11.htm"
            case .Zwölftestufe:
                return "12.htm"
            case .Dreizehntestufe:
                return "13.htm"
            }
        }
        
        func json() throws -> Data {
            return try JSONEncoder().encode(self)
        }
        func GetKlasse(_ stufe : Stufe) -> Substring {
            let temp: String = "\(stufe)"
            let klasse = temp.split(separator: ".")[3].split(separator: ")")[0]
            return klasse
        }
    }
    enum Klasse : String, CaseIterable, Codable {
        case A,B,C,D,E,F
    }
    enum VertretungsPlanAppStatus {
        case Loading
        case NoConnection
        case NoUnits
        case Idal
    }
    
    mutating func RemoveAllUnits() {
        VertretungsStrunden.removeAll()
    }
    mutating func AddUnit(Unit : VertretungsStunde) {
        VertretungsStrunden.append(Unit)
    }
    mutating func UpdateStatus(AppStatus : VertretungsPlanAppStatus) {
        VertretungsPlanStatus = AppStatus
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
