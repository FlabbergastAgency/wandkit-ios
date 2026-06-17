//
//  ContentView.swift
//  wandkit-ios-example
//
//  Created by Juraj Pavlek on 17.06.2026..
//

import SwiftUI
import WandKit

struct ContentView: View {
    @State private var lastEvent: String = "No events fired yet"
    @State private var purchaseCount: Int = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    Text(lastEvent)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section("Onboarding") {
                    Button("Complete onboarding") {
                        fire("onboarding_completed", properties: [
                            "steps_seen": "4",
                            "skipped": "false"
                        ])
                    }
                }

                Section("Auth") {
                    Button("Sign in") {
                        WandKit.identify("demo_user_42")
                        fire("sign_in_completed", properties: [
                            "method": "email"
                        ])
                    }
                }

                Section("Purchases") {
                    Button("Buy Pro subscription") {
                        purchaseCount += 1
                        fire("purchase_completed", properties: [
                            "plan": "pro_yearly",
                            "price_usd": "49.99",
                            "count": "\(purchaseCount)"
                        ])
                    }
                }

                Section("Content") {
                    Button("Publish post") {
                        fire("post_published", properties: [
                            "length": "short",
                            "has_media": "true"
                        ])
                    }
                    Button("Share to friend") {
                        fire("content_shared", properties: [
                            "channel": "messages"
                        ])
                    }
                }

                Section("Support") {
                    Button("Report an error", role: .destructive) {
                        fire("error_encountered", properties: [
                            "screen": "settings",
                            "code": "network_timeout"
                        ])
                    }
                }
            }
            .navigationTitle("WandKit Demo")
        }
    }

    private func fire(_ name: String, properties: [String: String]) {
        WandKit.event(name, properties: properties)
        lastEvent = "Fired: \(name)"
    }
}

#Preview {
    ContentView()
}
