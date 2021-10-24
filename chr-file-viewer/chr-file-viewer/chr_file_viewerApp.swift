//
//  chr_file_viewerApp.swift
//  chr-file-viewer
//
//  Created by Denise Nepraunig on 24.10.21.
//

import SwiftUI

@main
struct chr_file_viewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(vm: ContentViewModel())
        }
    }
}
