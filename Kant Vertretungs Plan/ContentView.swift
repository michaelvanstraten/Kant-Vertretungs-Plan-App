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
    @State var stufe : VertretungsPlanDataModel.Stufe?
    var body: some View {
        NavigationView{
            if stufe == nil {
                KantAppSettings()
            } else {
                VertretungsPlan(App: KantApp).navigationTitle("Kant App").navigationBarItems(leading: NavigationLink(destination : KantAppSettings()) {
                    Text("Einstellungen")
                })
            }
        }
    }
}

struct VertretungsPlan: View {
    @ObservedObject var App: VertretungsPlanApp
    var body: some View {
        VStack{
            List{
                ForEach(App.VertretungsStunden) { Vertretungsstunde in
                        VertretungPlanItem(VertretungsStunde: Vertretungsstunde)
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
            if let _ = VertretungsStunde.Text1 {
                Text(VertretungsStunde.Text1!)
            }
            if let _ = VertretungsStunde.Text2 {
                Text(VertretungsStunde.Text2!)
            }
        }.padding(.vertical)
    }
}


struct KantAppSettings : View {
    @State private var ausgewähltestufe : VertretungsPlanDataModel.Stufe {
        get {
            return VertretungsPlanDataModel.Stufe.Zwölftestufe
        }
    }
    
    var body: some View {
        Form{
            Section(header : Text("Klassen")) {
                Picker(selection: $ausgewähltestufe, label : Text("Wähle deine Klasse")) {
                    ForEach(VertretungsPlanDataModel.Klasse.allCases, id : \.self){ klasse in
                        Text("7\(klasse.rawValue)").tag(VertretungsPlanDataModel.Stufe.Siebtestufe(klasse))
                    }
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
        ContentView(KantApp: kantapp, stufe: VertretungsPlanDataModel.Stufe.Elftestufe)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
