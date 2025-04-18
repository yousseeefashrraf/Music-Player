//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 12/04/2025.
//

import SwiftUI

struct MainView: View {
    @AppStorage("newUser") var isNew: Bool = true

    var body: some View {
        if isNew{
            StartView(isNew: $isNew)
        } else {
            TabBarView()
        }
    }
}

#Preview {
    MainView()
}
