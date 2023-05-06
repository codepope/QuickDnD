//
//  ContentView.swift
//  QuickDnD Watch App
//
//  Created by Dj Walker-Morgan on 02/05/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var connectivityManager = QuickDnDConnectionManager.shared
    @State private var status = -1
    
    var body: some View {
        VStack {
            Button("Off") {}.foregroundColor(status == 0 ? Color.red:Color.black)
                    Button("Clear") {}.foregroundColor(status == 1 ? Color.red:Color.black)
                    Button("Enter") {}.foregroundColor(status == 2 ? Color.red:Color.black)
                    Button("Do Not Disturb") {}.foregroundColor(status == 3 ? Color.red:Color.black)
            }
        .padding()
        .onReceive(connectivityManager.$statusMessage) { message in
            if let newstatus=message?.status {
                switch(newstatus) {
                case "off": status=0
                case "clear": status=1
                case "enter": status=2
                case "dnd": status=3
                default: status = -1
                }
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
