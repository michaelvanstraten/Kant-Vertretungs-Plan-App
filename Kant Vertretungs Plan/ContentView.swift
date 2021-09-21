//
//  ContentView.swift
//  Kant Vertretungs Plan
//
//  Created by Michael Van straten on 15.09.21.
//

import SwiftUI
import SwiftSoup
import Foundation

struct ContentView: View {
    @ObservedObject var KantApp : VertretungsPlanApp
    var body: some View {
        NavigationView{
            if KantApp.UserStufe != nil {
                VertretungsPlan(App: KantApp).navigationTitle("Kant App").navigationBarItems(leading: NavigationLink(destination : KantAppSettings(userstufe: $KantApp.UserStufe)) {
                    Text("Einstellungen")
                })
            } else {
                KantAppSettings(userstufe: $KantApp.UserStufe).navigationBarHidden(true)
            }
        }
    }
}


struct VertretungsPlan: View {
    @ObservedObject var App: VertretungsPlanApp
    var body: some View {
        VStack{
            List{
                switch App.Status {
                case .Loading :
                    ProgressView()
                case .NoUnits:
                    Text("Es wurden keine Daten Gefunden")
                case .NoConnection:
                    Text("Es konnte keine verbindung mit der Kantwebseite aufgebaut werden")
                default:
                    ForEach(App.VertretungsStunden) { Vertretungsstunde in
                            VertretungPlanItem(VertretungsStunde: Vertretungsstunde)
                    }
                }
            }
            Button("Update") {
                App.UpdateUnits()
            }
        }
    }
}

struct VertretungPlanItem: View {
    var VertretungsStunde : VertretungsPlanDataModel.VertretungsStunde
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StatusLabel(Ausfall: VertretungsStunde.Ausfall)
                if let _ = VertretungsStunde.Zeitspan! {
                    Divider()
                    Text(VertretungsStunde.Zeitspan!)
                }
                if let _ = VertretungsStunde.Fach! {
                    Divider()
                    Text(VertretungsStunde.Fach!)
                }
                if let _ = VertretungsStunde.Raum! {
                    Divider()
                    Text(VertretungsStunde.Raum!)
                }
                if let _ = VertretungsStunde.Lehrer! {
                    Divider()
                    Text(VertretungsStunde.Lehrer!)
                }
            }
            if let text = VertretungsStunde.Text1! {
                Text(text)
            }
            if let text2 = VertretungsStunde.Text2! {
                Text(text2)
            }
        }.padding(.vertical)
    }
}


struct KantAppSettings : View {
    @Binding var userstufe : VertretungsPlanDataModel.Stufe?
    var body: some View {
        Form{
            Section(header : Text("Klassen")) {
                Picker(selection: $userstufe, label : Text("Wähle deine Klasse")) {
                    Text("Elftestufe").tag(VertretungsPlanDataModel.Stufe.Elftestufe as VertretungsPlanDataModel.Stufe?)
                    Text("Zwölfte Klasse").tag(VertretungsPlanDataModel.Stufe.Zwölftestufe as VertretungsPlanDataModel.Stufe?)
                    Text("Dreizehnte Klasse").tag(VertretungsPlanDataModel.Stufe.Dreizehntestufe as VertretungsPlanDataModel.Stufe?)
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
    static var kantapp = VertretungsPlanApp()
    static var previews: some View {
        ContentView(KantApp: kantapp)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
