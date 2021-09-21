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
    
    var UserStufe = Stufe.Zentestufe(.D)
    
    var VertretungsPlanStatus = "Keine Vertretungen Verfügbar"
    
    private func ParseUnit(rawstunde : Element) -> VertretungsStunde? {
        if let rawstundeelements = try? rawstunde.select("td").array() {
            var vertretungsstunde = VertretungsStunde()
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
    
    mutating func UpdateUnits() {
        print("\(KantAppConstans.VertretungsBaseURL)\(UserStufe.URLPath)")
        VertretungsStrunden.removeAll()
        if let html = try? String(contentsOf: URL(string: "\(KantAppConstans.VertretungsBaseURL)\(UserStufe.URLPath)")!, encoding: .windowsCP1250) {
            if let vertretungsstunden = try? SwiftSoup.parse(html).select("tbody").array()[safe : 1]?.select("tr") {
                for rawvertretungsstunde : Element in vertretungsstunden {
                    if rawvertretungsstunde != vertretungsstunden.first(), let vertretungsstunde = ParseUnit(rawstunde: rawvertretungsstunde) {
                        VertretungsStrunden.append(vertretungsstunde)
                    }
                }
            } else {
                VertretungsPlanStatus = "Keine Vertretungen Verfügbar"
            }
        } else {
            VertretungsPlanStatus = "Eine verbindung zu der Kant Webseite konnte nicht hergestellt werden"
        }
    }
    
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
    
    static private func GetKlasse(_ stufe : Stufe) -> Substring {
        let temp: String = "\(stufe)"
        let klasse = temp.split(separator: ".")[3].split(separator: ")")[0]
        return klasse
    }
    
    enum Stufe : Hashable {
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
    }
    
    enum Klasse : String, CaseIterable {
        case A,B,C,D,E,F
    }
}

class VertretungsPlanApp: ObservableObject {
    @Published private var model : VertretungsPlanDataModel = CreateDataModel()
    
    var VertretungsStunden : Array<VertretungsPlanDataModel.VertretungsStunde> {
        model.VertretungsStrunden
    }
    
    var stufe : VertretungsPlanDataModel.Stufe {
        model.UserStufe
    }
    static func CreateDataModel() -> VertretungsPlanDataModel {
        return VertretungsPlanDataModel()
    }
    
    func UpdateUnits() {
        model.UpdateUnits()
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
