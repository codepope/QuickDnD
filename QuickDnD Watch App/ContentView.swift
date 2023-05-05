//
//  ContentView.swift
//  QuickDnD Watch App
//
//  Created by Dj Walker-Morgan on 02/05/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Off") {}
            Button("Clear") {}
            Button("Enter") {}
            Button("Do Not Disturb") {}
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
