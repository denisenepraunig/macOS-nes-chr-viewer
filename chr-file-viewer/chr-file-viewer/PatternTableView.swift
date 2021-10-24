//
//  PatternTableView.swift
//  chr-file-viewer
//
//  Created by Denise Nepraunig on 24.10.21.
//

import SwiftUI

struct PatternTableView: View {
    var title = "Pattern Table"
    var data: [[[UInt8]]] = ExampleData.chrColorCoded
    var width = 0

    var colors = ["#000000", "#B6BC0A", "#118026", "#05313C"]

    var spacing: CGFloat = 0
    var size: CGFloat = 4

    var body: some View {
        
        VStack(spacing: spacing) {
            Text(title)
                .font(.title)
                .padding()
            
            ForEach((0..<width), id: \.self) { outer in
                HStack(spacing: spacing) {
                    ForEach((0..<width), id: \.self) { inner in
                        SpriteView(data: data[outer * width + inner], size: size)
                    }
                }
            }
        }
        .drawingGroup()
        
    }
}

struct PatternTableView_Previews: PreviewProvider {
    static var previews: some View {
        PatternTableView()
    }
}
