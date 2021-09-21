//
//  Truth.swift
//  Truth
//
//  Created by Michael Van straten on 21.09.21.
//

import Foundation
import SwiftSoup

class VertretungsplanApp: ObservableObject {
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
