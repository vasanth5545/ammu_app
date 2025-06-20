import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
<<<<<<< HEAD
    GMSServices.provideAPIKey("AIzaSyChYv4E2Sy2mEbhtDY-EuHVIye0n2mkpts") // Add this line
=======
>>>>>>> 82b12b4 (Initial commit)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
