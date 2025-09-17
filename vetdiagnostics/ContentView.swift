//
//  ContentView.swift
//  vetdiagnostics
//
//  Created by Olivia on 9/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                AIDiagnosticView()
            }
            .tabItem {
                Label("AI Diagnostic", systemImage: "stethoscope")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .accentColor(AppColor.accent)
    }
}

#Preview {
    ContentView()
}
