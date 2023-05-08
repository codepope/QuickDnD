//
//  ContentView.swift
//  QuickDnD
//
//  Created by Dj Walker-Morgan on 02/05/2023.
//
import CocoaMQTT
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var connectivityManager = QuickDnDConnectionManager.shared

    let mqttClient = CocoaMQTT(clientID: "dndbuttonswift-" + String(ProcessInfo().processIdentifier), host: "jonah.local", port: 1883)
        
    @State public var connected:Bool=false
    @State public var status:Int = -1
    
    var body: some View {
        VStack(alignment: .center) {
            Group {
                Button {
                    send(v:"off")
                } label: {
                    if status==0 {
                        Label("Off",systemImage:"power.circle.fill")
                    } else {
                        Label("Off",systemImage:"power.circle")
                    }
                }.buttonStyle(StateButtonStyle())
                
                Button {
                    send(v:"clear")
                } label: {
                    if status==1 {
                        Label("Clear",systemImage:"clear.fill")
                    } else {
                        Label("Clear",systemImage:"clear")

                    }
                }.buttonStyle(StateButtonStyle())
                
                Button {
                    send(v:"enter")
                } label: {
                    if status==2 {
                        Label("Enter",systemImage:"door.right.hand.open")
                    } else {
                        Label("Enter",systemImage:"door.right.hand.closed")
                    }
                }.buttonStyle(StateButtonStyle())
                
                Button {
                    send(v:"dnd")
                } label: {
                    if status==3 {
                        Label("Do Not Disturb",systemImage:"triangle.inset.filled")
                    } else {
                        Label("Do Not Disturb",systemImage:"triangle.fill")
                    }
                }.buttonStyle(StateButtonStyle())
                
            }.onAppear(perform: {
                self.connect()
            }).onReceive(connectivityManager.$statusMessage) { message in
                if let newstatus=message?.status {
                    send(v:newstatus)
                    }
                }
        }
    }
                       
    func connect() {
                self.mqttClient.username = "dnd"
                self.mqttClient.password = "dnd"
                self.mqttClient.autoReconnect=true
                self.mqttClient.keepAlive = 60
                _ = self.mqttClient.connect()
                self.mqttClient.didConnectAck = { _, _ in
                    print("Connected")
                    self.connected=true
                    self.mqttClient.subscribe("dnd/0001/status")
                    self.mqttClient.didReceiveMessage = {
                        _, message, _ in
                        print(message.payload)
                        let newstatus=String(bytes:message.payload,encoding:.utf8)
                        switch (newstatus) {
                        case "off":
                            self.status = 0
                        case "clear":
                            self.status = 1
                        case "enter":
                            self.status = 2
                        case "dnd":
                            self.status = 3
                        default:
                            self.status = -1
                        }
                    }
                    self.mqttClient.didDisconnect = {
                        _, error in
                            connected=false
                    }
                }
            }
    
    
    func send(v:String) {
        if !connected {
            self.connect()
        }
        self.mqttClient.publish("dnd/0001/status", withString:v, qos: .qos1, retained: true)
        QuickDnDConnectionManager.shared.send(v)
    }
}

struct StateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.padding(40)
            .frame(maxWidth:.infinity)
            .background(Color(red:0,green:0,blue:0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .font(.largeTitle)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
