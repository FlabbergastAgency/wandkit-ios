import SwiftUI
import WandKit

@main
struct wandkit_ios_exampleApp: App {
    init() {
        WandKit.configure(apiKey: "YOUR_API_KEY", environment: .test)
        WandKit.identify("demo_user_42")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
