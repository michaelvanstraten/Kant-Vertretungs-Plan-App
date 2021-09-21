//
//  ContentView.swift
//  Kant Vertretungs Plan
//
//  Created by Michael Van straten on 15.09.21.
//

import SwiftUI
import SwiftSoup
import Foundation

struct AppView: View {
    @ObservedObject var KantApp : VertretungsplanApp
    var body: some View {
        NavigationView{
            if KantApp.UserStufe != nil {
                VertretungsPlan(App: KantApp).navigationTitle("Kant Vertretungsplan").navigationBarItems(leading: NavigationLink(destination : Settings(userstufe: $KantApp.UserStufe)) {
                    Text("Einstellungen")
                })
            } else {
                Settings(userstufe: $KantApp.UserStufe).navigationBarHidden(true)
            }
        }
    }
}


struct VertretungsPlan: View {
    @ObservedObject var App: VertretungsplanApp
    var body: some View {
        VStack{
            List{
                switch App.Status {
                case .Loading :
                    Text("Wird Geladen ...")
                case .NoUnits:
                    Text("Keine Vertretungsstunden gefunden")
                case .NoConnection:
                    Text("Es konnte keine verbindung mit der Kantwebseite aufgebaut werden")
                default:
                    ForEach(App.VertretungsStunden) { Vertretungsstunde in
                            VertretungPlanItem(VertretungsStunde: Vertretungsstunde)
                    }
                }
            }
            Button("Aktualisieren") {
                App.UpdateUnits()
            }.scaleEffect(1.2).padding(15)
        }
    }
}

struct VertretungPlanItem: View {
    var VertretungsStunde : VertretungsPlanDataModel.VertretungsStunde
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StatusLabel(Ausfall: VertretungsStunde.Ausfall)
                if let _ = VertretungsStunde.Zeitspan {
                    Divider()
                    Text(VertretungsStunde.Zeitspan!)
                }
                if let _ = VertretungsStunde.Fach {
                    Divider()
                    Text(VertretungsStunde.Fach!)
                }
                if let _ = VertretungsStunde.Raum {
                    Divider()
                    Text(VertretungsStunde.Raum!)
                }
                if let _ = VertretungsStunde.Lehrer {
                    Divider()
                    Text(VertretungsStunde.Lehrer!)
                }
            }
            if let text = VertretungsStunde.Text1 {
                Text(text)
            }
            if let text2 = VertretungsStunde.Text2 {
                Text(text2)
            }
        }.padding(10)
    }
}


struct Settings : View {
    @Binding var userstufe : VertretungsPlanDataModel.Stufe?
    var body: some View {
        Form{
            Section(header : Text("Klasse")) {
                Picker(selection: $userstufe, label : Text("Wähle deine Stufe")) {
//                    Text("7.F").tag(VertretungsPlanDataModel.Stufe.Siebtestufe(.F) as VertretungsPlanDataModel.Stufe?)
                    Text("11. Klasse").tag(VertretungsPlanDataModel.Stufe.Elftestufe as VertretungsPlanDataModel.Stufe?)
                    Text("12. Klasse").tag(VertretungsPlanDataModel.Stufe.Zwölftestufe as VertretungsPlanDataModel.Stufe?)
                    Text("13. Klasse").tag(VertretungsPlanDataModel.Stufe.Dreizehntestufe as VertretungsPlanDataModel.Stufe?)
                }
            }
        }
    }
}

struct StatusLabel: View {
    var Ausfall : Bool?
    var body: some View {
        if let ausfall = Ausfall {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(ausfall ? .red : .green)
                Text(ausfall ? "Ausfall" : "Vertretung")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var kantapp = VertretungsplanApp()
    static var previews: some View {
        AppView(KantApp: kantapp)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
