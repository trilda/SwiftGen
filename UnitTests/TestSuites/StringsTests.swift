//
//  L10nTests.swift
//  SwiftGen
//
//  Created by Olivier Halligon on 01/08/2015.
//  Copyright © 2015 AliSoftware. All rights reserved.
//

import XCTest
import GenumKit

/**
* Important: In order for the "*.strings" files in fixtures/ to be copied as-is in the test bundle
* (as opposed to being compiled when the test bundle is compiled), a custom "Build Rule" has been added to the target.
* See Project -> Target "UnitTests" -> Build Rules -> « Files "*.strings" using PBXCp »
*/

class StringsTests: XCTestCase {

    func testEntriesWithDefaults() {
        let enumBuilder = StringEnumBuilder()
        enumBuilder.addEntry(StringEnumBuilder.Entry(key: "Title"))
        enumBuilder.addEntry(StringEnumBuilder.Entry(key: "Greetings", types: .Object, .Int))
        let result = enumBuilder.build()
        
        let expected = self.fixtureString("Strings-Entries-Defaults.swift.out")
        XCTDiffStrings(result, expected)
    }

    func testLinesWithDefaults() {
        let enumBuilder = StringEnumBuilder()
        if let e = StringEnumBuilder.Entry(line: "\"AppTitle\"    =   \"My awesome title\"  ; // Yeah") {
            enumBuilder.addEntry(e)
        }
        if let e = StringEnumBuilder.Entry(line: "\"GreetingsAndAge\"=\"My name is %@, I am %d\";/* hello */") {
            enumBuilder.addEntry(e)
        }
        let result = enumBuilder.build()
        
        let expected = self.fixtureString("Strings-Lines-Defaults.swift.out")
        XCTDiffStrings(result, expected)
    }
    
    func testFileWithDefaults() {
        let enumBuilder = StringEnumBuilder()
        try! enumBuilder.parseLocalizableStringsFile(fixturePath("Localizable.strings"))
        let result = enumBuilder.build()
        
        let expected = self.fixtureString("Strings-File-Defaults.swift.out")
        XCTDiffStrings(result, expected)
    }

    func testFileWithCustomName() {
        let enumBuilder = StringEnumBuilder()
        try! enumBuilder.parseLocalizableStringsFile(fixturePath("Localizable.strings"))
        let result = enumBuilder.build(enumName: "XCTLoc")
        
        let expected = self.fixtureString("Strings-File-CustomName.swift.out")
        XCTDiffStrings(result, expected)
    }

    func testFileWithCustomIndentation() {
        let enumBuilder = StringEnumBuilder()
        try! enumBuilder.parseLocalizableStringsFile(fixturePath("Localizable.strings"))
        let result = enumBuilder.build(indentation: .Spaces(3))
        
        let expected = self.fixtureString("Strings-File-CustomIndentation.swift.out")
        XCTDiffStrings(result, expected)
    }
    
    
    ////////////////////////////////////////////////////////////////////////
    
    
    
    func testParseStringPlaceholder() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%@")
        XCTAssertEqual(placeholders, [.Object])
    }
    
    func testParseFloatPlaceholder() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%f")
        XCTAssertEqual(placeholders, [.Float])
    }
    
    func testParseDoublePlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%g-%e")
        XCTAssertEqual(placeholders, [.Float, .Float])
    }
    
    func testParseFloatWithPrecisionPlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%1.2f : %.3f : %+3f : %-6.2f")
        XCTAssertEqual(placeholders, [.Float, .Float, .Float, .Float])
    }

    func testParseIntPlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%d-%i-%o-%u-%x")
        XCTAssertEqual(placeholders, [.Int, .Int, .Int, .Int, .Int])
    }

    func testParseCCharAndStringPlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%c-%s")
        XCTAssertEqual(placeholders, [.Char, .CString])
    }

    func testParsePositionalPlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%2$d-%4$f-%3$@-%c")
        XCTAssertEqual(placeholders, [.Char, .Int, .Object, .Float])
    }

    func testParseComplexFormatPlaceholders() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%2$1.3d - %4$-.7f - %3$@ - %% - %5$+3c - %%")
        // positions 2, 4, 3, 5 set to Int, Float, Object, Char, and position 1 not matched, defaulting to Unknown
        XCTAssertEqual(placeholders, [.Unknown, .Int, .Object, .Float, .Char])
    }

    func testParseEscapePercentSign() {
        let placeholders = StringEnumBuilder.PlaceholderType.fromFormatString("%%foo")
        // Must NOT map to [.Float]
        XCTAssertEqual(placeholders, [])
    }

}