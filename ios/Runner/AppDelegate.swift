import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

let channel = FlutterMethodChannel(
  name: "com.your.app/config",
  binaryMessenger: controller.binaryMessenger
)
channel.setMethodCallHandler { call, result in
  switch call.method {
    case "SENDGRID_KEY": result("$(SENDGRID_KEY)")
    case "SRC_MAIL": result("$(SRC_MAIL)")
    case "DEST_MAIL": result("$(DEST_MAIL)")
    default: result(FlutterMethodNotImplemented)
  }
}
