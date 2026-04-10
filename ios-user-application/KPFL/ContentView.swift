//
//  ContentView.swift
//  KPFL
//
//  Created by Аяз on 12/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore()
    @StateObject private var settings = AppSettings()

    var body: some View {
        AppRoot()
            .environmentObject(store)
            .environmentObject(settings)
            .preferredColorScheme(settings.colorScheme)
            .statusBarHidden(true)
    }
}

#Preview {
    ContentView()
}
