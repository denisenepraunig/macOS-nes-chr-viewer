//
//  ContentView.swift
//  chr-file-viewer
//
//  Created by Denise Nepraunig on 24.10.21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm: ContentViewModel

    @State private var spacing: CGFloat = 2
    @State private var size: CGFloat = 3
    
    var body: some View {
        VStack {

            HStack {
                vm.image1
                    .resizable()
                    .antialiased(false)
                    .interpolation(.none)
                    .frame(width: 512, height: 512)

                vm.image2
                    .resizable()
                    .antialiased(false)
                    .interpolation(.none)
                    .frame(width: 512, height: 512)
            }
            
            HStack {
                Button("Get Data") {
                    vm.generatePatternTables()
                }

                Button("Generate Image") {
                    vm.generateImage()
                }
            }
            HStack(spacing: 20) {
//                PatternTableView(
//                    title: "Pattern Table 1",
//                    data: vm.patternTable1,
//                    width: vm.tableSize1
//                )
//
//                PatternTableView(
//                    title: "Pattern Table 2",
//                    data: vm.patternTable2,
//                    width: vm.tableSize2
//                )
            }
            .drawingGroup()
        }
        .frame(width: 1300, height: 850)
        .onAppear {
            vm.generatePatternTables()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vm: ContentViewModel())
    }
}
