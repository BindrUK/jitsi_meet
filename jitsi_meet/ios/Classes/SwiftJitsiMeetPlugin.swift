import Flutter
import UIKit
import JitsiMeetSDK

public class SwiftJitsiMeetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var window: UIWindow?
    var uiVC : UIViewController?
    var jitsiView : JitsiView?
    var eventSink : FlutterEventSink?
    var jitsiViewController: JitsiViewController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let factory = JitsiViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "jitsi_ios_meet_view")
        
        let channel = FlutterMethodChannel(name: "jitsi_meet", binaryMessenger: registrar.messenger())
        let instance = SwiftJitsiMeetPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Set up event channel for conference events
        let eventChannelName = "jitsi_meet_events"
        
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if (call.method == "joinMeeting") {
            result(nil)
            
        }else if (call.method == "closeMeeting") {
        }
        
    }
    
    /**
     # FlutterStreamHandler methods
     */
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        EventManager.shared.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        EventManager.shared.eventSink = eventSink
        return nil
    }
}


class EventManager{
    static let shared = EventManager()
    var eventSink : FlutterEventSink?
    init(){}
}
