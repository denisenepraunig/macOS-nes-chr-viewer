//
//  SpriteView.swift
//  chr-file-viewer
//
//  Created by Denise Nepraunig on 24.10.21.
//

import SwiftUI

struct SpriteView: View {
    var data: [[UInt8]] = ExampleData.spriteColorCoded
    var colors = ["#000000", "#B6BC0A", "#118026", "#05313C"]

    var size: CGFloat = 4
    var padding: CGFloat = 2
    var spacing: CGFloat = 0

    var body: some View {
        VStack(spacing: spacing) {
            ForEach((0...7), id: \.self) { outer in
                HStack(spacing: spacing) {
                    ForEach((0...7), id: \.self ) { inner in
                        Rectangle()
                            .frame(width: size, height: size)
                            .foregroundColor(Color(hex: colors[Int(data[outer][inner])]))
                    }
                }
            }
        }
        .padding(padding)
        .drawingGroup()
//        .border(Color.white)
    }
}

struct SpriteView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteView()
    }
}
