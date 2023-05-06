//
//  QuickDnDConnectionManager.swift
//  QuickDnD
//
//  Created by Dj Walker-Morgan on 06/05/2023.
//

import Foundation
import WatchConnectivity

struct StatusMessage: Identifiable {
    let id = UUID()
    let status: String
}

final class QuickDnDConnectionManager: NSObject, ObservableObject  {
    static let shared = QuickDnDConnectionManager()
    @Published var statusMessage: StatusMessage? = nil

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private let kMessageKey = "status"
    
    func send(_ status: String) {
        guard WCSession.default.activationState == .activated else {
            return
        }
#if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
#else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
#endif
        
        WCSession.default.sendMessage([kMessageKey : status], replyHandler: nil) { error in
            print("Cannot send status: \(String(describing: error))")
        }
    }
    

}

extension QuickDnDConnectionManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
          if let statusText = message[kMessageKey] as? String {
              DispatchQueue.main.async { [weak self] in
                  self?.statusMessage = StatusMessage(status: statusText)
              }
          }
      }
    
    func session(_ session: WCSession,
                     activationDidCompleteWith activationState: WCSessionActivationState,
                     error: Error?) {}
    
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
}

   
  
