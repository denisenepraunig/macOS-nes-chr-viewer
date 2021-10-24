//
//  ContentViewModel.swift
//  chr-file-viewer
//
//  Created by Denise Nepraunig on 24.10.21.
//

import Foundation
import AppKit
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var chrSpriteString = "0c03 0000 0007 0f0f 0f03 0000 0708 1010"
    @Published var chrSpriteColorCoded = [
        [0,0,0,0,3,3,2,2],
        [0,0,0,0,0,0,3,3],
        [0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0],
        [0,0,0,0,0,2,2,2],
        [0,0,0,0,2,1,1,1],
        [0,0,0,2,1,1,1,1],
        [0,0,0,2,1,1,1,1]
    ]
    var patternTable1 = ExampleData.chrColorCoded
    var patternTable2 = ExampleData.chrColorCoded

    var chrString = ExampleData.chrString

    @Published var tableSize1 = 2
    @Published var tableSize2 = 2

    @Published var image1 = Image("")
    @Published var image2 = Image("")
//    var tableSize: Int {
//        Int(Float(patternTable1.count).squareRoot())
//    }

    let dispatchQueue =  DispatchQueue(
        label: "com.nepraunig.chrcalculation",
        attributes: .concurrent
    )

    // RGBA
    let colorDataRGBA = [
        0: [0, 0, 0, 255],
        1: [182, 188, 10, 255],
        2: [17, 128, 38, 255],
        3: [5, 49, 60, 255]
    ]

    let colorDataABGR: [UInt8: [UInt8]] = [
        0: [255, 0, 0, 0],
        1: [255, 10, 188, 182],
        2: [255, 38, 128, 17],
        3: [255, 60, 49, 5]
    ]

    var patternTable1Pixel: Array<UInt8> = Array(repeating: 0, count: 65536)
    var patternTable2Pixel: Array<UInt8> = Array(repeating: 0, count: 65536)

    func generateImage() {
//        generatePixelData(resultArray: &patternTable1Pixel)
//        generatePixelData(resultArray: &patternTable2Pixel)
//
//        let patternImage1 = makeImage(from: &patternTable1Pixel)
//        let patternImage2 = makeImage(from: &patternTable2Pixel)
//
//        if let image = patternImage1 {
//            image1 = image
//        }
//
//        if let image = patternImage2 {
//            image2 = image
//        }

        // do nothing

    }

    func makeImage(from pixels: inout [UInt8]) -> Image? {
        let width = 128
        let height = 128

        guard width > 0 && height > 0 else { return nil }
        var data = pixels

        let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let cgImage = context?.makeImage() else {
            return nil
        }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
        
        let image = Image(nsImage: nsImage)

//        self.image1 = image
        return image
    }

    func generatePixelData(resultArray: inout [UInt8], patternTable: inout [[[UInt8]]]) {
        var row_idx = 0
        var column_idx = 0

        // overall data inside 1 BIG_ROW = 16 blocks * 8 pixel w  * 8 pixel h * 4 data = 4096
        // overall data inside 1 BIG_COLUMN = 8 pixel w * 8 pixel h * 4 data = 256

        // data inside 1 row inside sprite = 8 pixel w * 4 data = 32
        // data inside 1 column = 4 data
        // data offset 1 column sprite = 16 blocks * 8 pixel w * 4 data =

        let BIG_ROW = 4096
        let BIG_COLUMN = 32
        let DATA_ROW = 512
        let SMALL_COLUMN = 4

        var counter = 0

        for (i, entry) in patternTable.enumerated() {
            row_idx = i > 0 ? i / 16 : 0
            column_idx = i > 0 ? i % 16 : 0

//            print(i, row_idx, column_idx)

            // j and k run from 0..<8
            for (j, row) in entry.enumerated() {
                for (k, element) in row.enumerated() {
                    counter += 1

                    let offset = row_idx * BIG_ROW + column_idx * BIG_COLUMN
                    let color = colorDataABGR[element] ?? [255, 0, 0, 0]

                    let index = offset + j * DATA_ROW + k * SMALL_COLUMN
//
//                    let index = row * 128 + column * 128 + j * 8 + k * 8
                    resultArray[index + 0] = color[0]
                    resultArray[index + 1] = color[1]
                    resultArray[index + 2] = color[2]
                    resultArray[index + 3] = color[3]
//
//                    newData.append(color[0])
//                    newData.append(color[1])
//                    newData.append(color[2])
//                    newData.append(color[3])

//                    patternTable1Pixel[index + 0] = UInt8.random(in: 0...255)
//                    patternTable1Pixel[index + 1] = UInt8.random(in: 0...255)
//                    patternTable1Pixel[index + 2] = UInt8.random(in: 0...255)
//                    patternTable1Pixel[index + 3] = UInt8.random(in: 0...255)
                }
            }
        }

//        patternTable1Pixel = newData
        print(counter)
    }

    func generatePatternTables() {

//        let pasteboard = NSPasteboard.general
//        chrString = pasteboard.string(forType: NSPasteboard.PasteboardType.string) ?? ExampleData.chrString

        chrString = ExampleData.chrString

        var lineArray = chrString.components(separatedBy: "\n")

        // add zero values for missing lines
        if lineArray.count < 512 {
            let difference = 512 - lineArray.count
            lineArray.append(contentsOf: repeatElement("0000 0000 0000 0000 0000 0000 0000 0000", count: difference))
        }

        let channel1 = Array(lineArray[0...255])
        let channel2 = Array(lineArray[256...511])

        var channel1Data = [[[UInt8]]]()
        var channel2Data = [[[UInt8]]]()

        dispatchQueue.async { [self] in
            for element in channel1 {
                let channels = self.chrStringtoChrColorChannels(chrLineString: element)
                let combinedChannel = self.combineChannels(
                    channel1: channels.channel1,
                    channel2: channels.channel2
                )

                channel1Data.append(combinedChannel)
            }

            print("done calculating table 1")

            self.patternTable1 = channel1Data
            self.generatePixelData(resultArray: &self.patternTable1Pixel, patternTable: &self.patternTable1)

            let patternImage1 = makeImage(from: &self.patternTable1Pixel)


            DispatchQueue.main.async {
                if let image = patternImage1 {
                    self.image1 = image
                }
                
                print("entering drawing table 1")
                self.tableSize1 = 16
//                self.patternTable1 = channel1Data
                print("done updating drawing data 1")

                self.generateImage()
            }
        }


        dispatchQueue.async {
            for element in channel2 {
                let channels = self.chrStringtoChrColorChannels(chrLineString: element)
                let combinedChannel = self.combineChannels(
                    channel1: channels.channel1,
                    channel2: channels.channel2
                )

                channel2Data.append(combinedChannel)
            }

            print("done calculating table 2")

            self.patternTable2 = channel2Data

            self.generatePixelData(resultArray: &self.patternTable2Pixel, patternTable: &self.patternTable2)
            let patternImage2 = self.makeImage(from: &self.patternTable2Pixel)



            DispatchQueue.main.async {
                if let image = patternImage2 {
                    self.image2 = image
                }

                print("entering drawing table 2")
                self.tableSize2 = 16
//                self.patternTable2 = channel2Data
                print("done updating drawing data 2")
            }
        }
    }

    /// [ [3, 3, 3, 3, 3, 0, 2, 1] ...] -> channel1, channel2
    /// (channel 2 is weighted with 2)
    /// - Parameter chrArray: [ [3, 3, 3, 3, 3, 0, 2, 1] ...]
    /// - Returns: channel 1: [ [1, 1, 1, 1, 1, 1, 0, 0, 1], ...],
    /// channel 2: [ [1, 1, 1, 1, 1, 0, 0, 1, 0] ...]
    private func chrColorsToChannel(chrArray: [[UInt8]]) -> (channel1: [[UInt8]], channel2: [[UInt8]]) {
        var channel1 = [[UInt8]]()
        var channel2 = [[UInt8]]()

        var channel1Row = [UInt8]()
        var channel2Row = [UInt8]()

        for row in chrArray {
            channel1Row = [UInt8]()
            channel2Row = [UInt8]()

            for element in row {
                var result1: UInt8 = 0
                var result2: UInt8 = 0

                // 1 is: 1 in channel1 and 0 in channel2
                // 2 is: 0 in channel1 and 1 in channel2
                // 3 is: 1 in channel1 and 1 in channel2
                switch element {
                case 1:
                    result1 = 1
                case 2:
                    result2 = 1
                case 3:
                    result1 = 1
                    result2 = 1
                default:
                    break
                }

                channel1Row.append(result1)
                channel2Row.append(result2)
            }
            channel1.append(channel1Row)
            channel2.append(channel2Row)
        }

        return (channel1: channel1, channel2: channel2)
    }

    /// [1, 1, 1, 1, 1, 0, 1, 0] -> "FA"
    /// - Parameter binaryArray: [1, 1, 1, 1, 1, 0, 1, 0]
    /// - Returns: "FA"
    private func binaryNumbersArrayToHexNumber(binaryArray: [UInt8]) -> String {

        // [1, 1, 1, 1, 1, 0, 1, 0] -> ["1", "1", "1", "1", "1", "0", "1", "0"]
        let numberStringArray = binaryArray.map { "\($0)" }

        // ["1", "1", "1", "1", "1", "0", "1", "0"] -> "11111010"
        let numberString = numberStringArray.reduce("", +)

        guard numberString != "00000000" else {
            return "00"
        }

        // "11111010" -> 250
        let int = Int(numberString, radix: 2) ?? 0

        // 250 -> "FA"
        var hex = String(int, radix: 16)

        // pad: "A" -> "0A", "FA" -> "FA"
        if hex.count == 1 {
            hex = "0\(hex)"
        }
        return hex
    }

    /// "1010" -> "00001010"
    /// - Parameters:
    ///   - string: "1010"
    ///   - toSize: 8
    /// - Returns: "00001010"
    private func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = "0" + padded
        }
        return padded
    }

    /// "0000 0000 0000..." -> ["0000", "0000", "0000",... ]
    /// - Parameter chr: "0000 0000 0000..."
    /// - Returns: ["0000", "0000", "0000",... ]
    private func splitChrToArray(chr: String) -> [String] {
        return chr.components(separatedBy: " ")
    }

    /// "FACA" -> ["FA", "CA"]
    /// - Parameter string: "FACA"
    /// - Returns: ["FA", "CA"]
    private func split4into2Strings(string: String) -> [String] {
        var newString = string
        let halfLength = newString.count / 2

        // "FACA" -> "FA-CA" -> ["FA", "CA"]
        // the "-" is a little helper, so that I don't need to deal with substring APIs :'D
        let index = newString.index(newString.startIndex, offsetBy: halfLength)
        newString.insert("-", at: index)
        return newString.components(separatedBy: "-")
    }

    /// "FA" -> "11111010"
    /// - Parameter hexString: "FA"
    /// - Returns: "11111010"
    private func hexToBinary(hexString: String) -> String {
        let int = Int(hexString, radix: 16) ?? 0 // FA -> 250
        let binary = String(int, radix: 2) // 250 -> 11111010
        let padded = pad(string: binary, toSize: 8) // 1010 -> 00001010
        return padded
    }

    /// "11111010" -> [1, 1, 1, 1, 1, 0, 1, 0]
    /// - Parameter string: "11111010"
    /// - Returns: [1, 1, 1, 1, 1, 0, 1, 0]
    private func binaryStringToIntArray(string: String) -> [UInt8] {
        guard string != "00000000" else {
            return [0,0,0,0,0,0,0,0]
        }

        // "11111010" -> ["1", "1", "1", "1", "1", "0", "1", "0"]
        let binaryStringArray = string.map { String($0) }

        // ["1", "1", "1", "1", "1", "0", "1", "0"] -> [1, 1, 1, 1, 1, 0, 1, 0]
        let intArray = binaryStringArray.map {
            UInt8($0) ?? 0
        }

        return intArray
    }

    /// "0000 0000 0000..." -> channel1: [ [1, 1, 1, 1,...], ...], channel2: [ [1, 1, 1, 1, 1,...] ...]
    /// - Returns: channel1: [ [1, 1, 1, 1,...], ...], channel2: [ [1, 1, 1, 1, 1,...] ...]
    private func chrStringtoChrColorChannels(chrLineString: String) -> (channel1: [[UInt8]], channel2: [[UInt8]]) {

        // "0000 0000 0000..." -> ["0000", "0000", "0000",... ]
        let chrArray = splitChrToArray(chr: chrLineString)

        // channel1 are the first 4 entries, channel two are the last 4 entries
        let channel1StringArray = Array(chrArray[0...3])
        let channel2StringArray = Array(chrArray[4...7])

        // ["0000", "0000", "0000",... ] -> [ [0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0], ... ]
        let channel1Numbers = numberStringToGraphicsArray(stringArray: channel1StringArray)
        let channel2Numbers = numberStringToGraphicsArray(stringArray: channel2StringArray)

        return (channel1: channel1Numbers, channel2: channel2Numbers)
    }

    /// [ [1, 1, 1, 1,...], ...] + [ [1, 1, 1, 1, 1,...] ...] ->
    /// [ [3, 3, 3, 3,...] ...]
    /// channel 2 is weighted with 2
    /// - Parameters:
    ///   - channel1: [ [1, 1, 1, 1, 1, 1, 0, 0, 1], ...]
    ///   - channel2: [ [1, 1, 1, 1, 1, 0, 0, 1, 0] ...]
    /// - Returns: [ [3, 3, 3, 3, 3, 0, 2, 1] ...]
    private func combineChannels(channel1: [[UInt8]], channel2: [[UInt8]]) -> [[UInt8]] {
        var result = [[UInt8]]()
        var resultRow = [UInt8]()

        for (i, row) in channel1.enumerated() {
            resultRow = [UInt8]()

            for (g, element1) in row.enumerated() {
                let element2 = 2 * channel2[i][g]
                let calculation = element1 + element2
                resultRow.append(calculation)
            }
            result.append(resultRow)
        }
        return result
    }

    /// ["11111010",... ] -> [ [1, 1, 1, 1, 1, 1, 0, 1, 0],... ]
    /// - Parameter stringArray: ["11111010",... ]
    /// - Returns: [ [1, 1, 1, 1, 1, 1, 0, 1, 0], ... ]
    private func numberStringToGraphicsArray(stringArray: [String]) -> [[UInt8]] {
        var newStringArray = [String]()
        var newNumberArray = [[UInt8]]()

        // "FA72" -> "FA 72"
        for element in stringArray {
            let subString = split4into2Strings(string: element)
            newStringArray.append(contentsOf: subString)
        }

        // "FA" -> "11111010" -> [1, 1, 1, 1, 1, 1, 0, 1, 0]
        for element in newStringArray {
            let binaryString = hexToBinary(hexString: element)
            let intArray = binaryStringToIntArray(string: binaryString)
            newNumberArray.append(intArray)
        }

        // [ [1, 1, 1, 1, 1, 1, 0, 1, 0], [0, 0, 1, 1, 1, 0, 0, 1, 0], ... ]
        return newNumberArray
    }

    /// [[1, 1, 1, 1, 1, 0, 1, 0], ...] -> "FACA 0010 080F..."
    /// - Parameter graphicsArray: [[1, 1, 1, 1, 1, 0, 1, 0], ...]
    /// - Returns: "FACA 0010 080F..."
    private func graphicsArrayToNumberString(graphicsArray: [[UInt8]]) -> String {
        let channels = chrColorsToChannel(chrArray: graphicsArray)

        var channel1String = ""
        var channel2String = ""

        // [1, 1, 1, 1, 1, 0, 1, 0] -> "FA"
        for row in channels.channel1 {
            let string = binaryNumbersArrayToHexNumber(binaryArray: row)
            channel1String += string
        }

        for row in channels.channel2 {
            let string = binaryNumbersArrayToHexNumber(binaryArray: row)
            channel2String += string
        }

        // "0000000000000000" -> "0000 0000 0000 0000"
        channel1String.insert(" ", at: channel1String.index(channel1String.startIndex, offsetBy: 12))
        channel1String.insert(" ", at: channel1String.index(channel1String.startIndex, offsetBy: 8))
        channel1String.insert(" ", at: channel1String.index(channel1String.startIndex, offsetBy: 4))

        channel2String.insert(" ", at: channel2String.index(channel2String.startIndex, offsetBy: 12))
        channel2String.insert(" ", at: channel2String.index(channel2String.startIndex, offsetBy: 8))
        channel2String.insert(" ", at: channel2String.index(channel2String.startIndex, offsetBy: 4))

        // "0000 0000 0000 0000" + "0000 0000 0000 0000"
        // -> "0000 0000 0000 0000 0000 0000 0000 0000"
        let resultString = channel1String + " " + channel2String
        return resultString
    }

    func buttonTapGraphicToString() {
        // output = walkReverse(array: chrColors)
    }

    func buttonConvertStringToGraphic() {
//        let result = chrStringtoChrColors()
//        let combined = combineChannels(channel1: result.channel1, channel2: result.channel2)
//
//        chrColors = combined
    }
}
