import Flutter
import UIKit

public class SwiftUpdateCheckerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "update_checker", binaryMessenger: registrar.messenger())
    let instance = SwiftUpdateCheckerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "getCurrentVersion"){
        result(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
  }
}
