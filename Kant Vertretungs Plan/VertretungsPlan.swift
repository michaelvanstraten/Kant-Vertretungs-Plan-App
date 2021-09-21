//
//  VertretungsPlan.swift
//  VertretungsPlan
//
//  Created by Michael Van straten on 16.09.21.
//

import Foundation
import SwiftSoup

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

class VertretungsPlanApp: ObservableObject {
    @Published private var model : VertretungsPlanDataModel = VertretungsPlanDataModel()
    
    var VertretungsStunden : Array<VertretungsPlanDataModel.VertretungsStunde> {
        model.VertretungsStrunden
    }
    
    var UserStufe : VertretungsPlanDataModel.Stufe? {
        get {
            model.UserStufe
        }
        set (Value) {
            model.UserStufe = Value
            SaveUserStufe()
            UpdateUnits()
        }
        
    }
    
    var Status : VertretungsPlanDataModel.VertretungsPlanAppStatus {
        model.VertretungsPlanStatus
    }
    
    init () {
        GetDefaults()
    }
    
    func SaveUserStufe() {
        let userdefaults = UserDefaults.standard
        if let data = try? model.UserStufe?.json() {
            userdefaults.set(data,forKey: "UserStufe")
        }
    }
    
    private func ParseUnit(rawstunde : Element) -> VertretungsPlanDataModel.VertretungsStunde? {
        if let rawstundeelements = try? rawstunde.select("td").array() {
            var vertretungsstunde = VertretungsPlanDataModel.VertretungsStunde()
            for (index, rawstundeelement) in rawstundeelements.enumerated() {
                switch index {
                case 0:
                    if let hinweiß = try? rawstundeelement.text(), hinweiß.count >= 5 {
                        vertretungsstunde.Text1 = hinweiß
                    }
                case 1:
                    vertretungsstunde.Zeitspan = try? rawstundeelement.text()
                case 2:
                    vertretungsstunde.Fach = try? rawstundeelement.text()
                    if let ausfall = try? rawstundeelement.select("s").array(), !ausfall.isEmpty {
                        vertretungsstunde.Ausfall = true
                    } else if let ausfall = try? rawstundeelement.select("font").array(), !ausfall.isEmpty {
                        vertretungsstunde.Ausfall = false
                    }
                case 3:
                    vertretungsstunde.Raum = try? rawstundeelement.text()
                case 4:
                    vertretungsstunde.Lehrer = try? rawstundeelement.text()
                case 5:
                    vertretungsstunde.Text1 = try? rawstundeelement.text()
                case 6:
                    vertretungsstunde.Text2 = try? rawstundeelement.text()
                default:
                    continue
                }
            }
            return vertretungsstunde
        }
        return nil
    }
    
    func UpdateUnits() {
        model.UpdateStatus(AppStatus: .Loading)
        DispatchQueue.global(qos : .userInitiated).async { [weak self] in
            if let urlpath = self?.UserStufe?.URLPath {
                DispatchQueue.main.async { [weak self] in
                    self?.model.RemoveAllUnits()
                }
                if let html = try? String(contentsOf: URL(string: "\(KantAppConstans.VertretungsBaseURL)\(urlpath)")!, encoding: .windowsCP1250) {
                    if let vertretungsstunden = try? SwiftSoup.parse(html).select("tbody").array()[safe : 1]?.select("tr") {
                        for rawvertretungsstunde : Element in vertretungsstunden {
                            if rawvertretungsstunde != vertretungsstunden.first(), let vertretungsstunde = self?.ParseUnit(rawstunde: rawvertretungsstunde) {
                                DispatchQueue.main.async { [weak self] in
                                    self?.model.AddUnit(Unit : vertretungsstunde)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.model.UpdateStatus(AppStatus: .NoUnits)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.model.UpdateStatus(AppStatus: .NoConnection)
                    }
                }
                DispatchQueue.main.async {
                    self?.model.UpdateStatus(AppStatus: .Idal)
                }
            }
        }
    }
    
    func GetDefaults() {
        let userdefaults = UserDefaults.standard
        if let data = userdefaults.data(forKey: "UserStufe") {
            model.UserStufe = try? JSONDecoder().decode(VertretungsPlanDataModel.Stufe.self, from: data)
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
