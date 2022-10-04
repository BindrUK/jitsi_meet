import Flutter
import UIKit
import JitsiMeetSDK

class JitsiViewFactory: NSObject, FlutterPlatformViewFactory {
    
    private var messenger: FlutterBinaryMessenger
    
    init(messenger:FlutterBinaryMessenger){
        
        self.messenger = messenger
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return JitsiView(frame: frame, viewId: viewId, args: args, binaryMessenger: messenger)
    }
}

class JitsiView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    var eventSink : FlutterEventSink?
    var passArgs : Any?
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        
        self.frame = frame
        self.viewId = viewId
        self.passArgs = args
    }
    
    func view() -> UIView {
        
        let jitsiMeetView = JitsiMeetView()
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            if let jitsiOptions = self.passArgs as? [String:Any]   {
                
                // set options which is received from flutter
                let audioMuted = jitsiOptions["audioMuted"] as? Bool
                let videoMuted = jitsiOptions["videoMuted"] as? Bool
                let room = jitsiOptions["room"] as? String
                let serverURL = jitsiOptions["serverURL"] as? String
                let subject = jitsiOptions["subject"] as? String
                let userDisplayName = jitsiOptions["userDisplayName"] as? String
                let userEmail = jitsiOptions["userEmail"] as? String
                
                // UserInfo Update param from flutter
                let userInfo = JitsiMeetUserInfo()
                userInfo.displayName = userDisplayName
                userInfo.email = userEmail
                
                builder.room = room
                builder.audioMuted = audioMuted ?? true
                builder.videoMuted = videoMuted ?? true
                builder.subject = subject
                builder.serverURL = URL.init(string: serverURL ?? "https://meet.jit.si")
                builder.userInfo = userInfo
                
                if let featureFlag = jitsiOptions["featureFlags"] as? [String:Any] {
                    for (key, value) in featureFlag {
                        builder.setFeatureFlag(key, withValue: value)
                    }
                }
            }
        }
        
        jitsiMeetView.delegate = self
        jitsiMeetView.join(options)
        return jitsiMeetView
    }
}


extension JitsiView: JitsiMeetViewDelegate {
    
    func conferenceWillJoin(_ data: [AnyHashable : Any]!) {
        
        var mutatedData = data
        mutatedData?.updateValue("onConferenceWillJoin", forKey: "event")
        EventManager.shared.eventSink?(mutatedData)
    }
    
    func conferenceJoined(_ data: [AnyHashable : Any]!) {
        
        var mutatedData = data
        mutatedData?.updateValue("onConferenceJoined", forKey: "event")
        EventManager.shared.eventSink?(mutatedData)
    }
    
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        
        var mutatedData = data
        mutatedData?.updateValue("onConferenceTerminated", forKey: "event")
        EventManager.shared.eventSink?(mutatedData)
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        
        var mutatedData = data
        mutatedData?.updateValue("onPictureInPictureWillEnter", forKey: "event")
        EventManager.shared.eventSink?(mutatedData)
    }
    
    func exitPictureInPicture() {
        
        var mutatedData : [AnyHashable : Any]
        mutatedData = ["event":"onPictureInPictureTerminated"]
        EventManager.shared.eventSink?(mutatedData)
    }
}



