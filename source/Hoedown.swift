//
//  Markdown.swift
//  MarkPub
//
//  Created by Niels de Hoog on 17/04/15.
//  Copyright (c) 2015 Invisible Pixel. All rights reserved.
//

import Foundation
import hoedown

public class Hoedown {
    public class func renderHTMLForMarkdown(string: String, flags: HoedownHTMLFlags = .None, extensions: HoedownExtensions = .None) -> String? {
        let renderer = HoedownHTMLRenderer(flags: flags)
        let document = HoedownDocument(renderer: renderer, extensions: extensions)
        return document.renderMarkdown(string)
    }
}

public protocol HoedownRenderer {
    var internalRenderer: UnsafeMutablePointer<hoedown_renderer> { get }
}

public class HoedownHTMLRenderer: HoedownRenderer  {
    public let internalRenderer: UnsafeMutablePointer<hoedown_renderer>
    
    public init(flags: HoedownHTMLFlags = .None, nestingLevel: Int = 0) {
        self.internalRenderer = hoedown_html_renderer_new(hoedown_html_flags(UInt32(flags.rawValue)), CInt(nestingLevel))
    }
    
    deinit {
        hoedown_html_renderer_free(self.internalRenderer)
    }
}

public class HoedownDocument {
    let internalDocument: COpaquePointer
    
    public init(renderer: HoedownRenderer, extensions: HoedownExtensions = .None, maxNesting: UInt = 16) {
        self.internalDocument = hoedown_document_new(renderer.internalRenderer, hoedown_extensions(UInt32(extensions.rawValue)), Int(maxNesting))
    }
    
    public func renderMarkdown(string: String, bufferSize: UInt = 16) -> String? {
        let buffer = hoedown_buffer_new(Int(bufferSize))
        hoedown_document_render(self.internalDocument, buffer, string, count(string));
        
        let htmlOutput = hoedown_buffer_cstr(buffer)
        let output = String.fromCString(htmlOutput)
        
        hoedown_buffer_free(buffer)
        
        return output
    }
    
    deinit {
        hoedown_document_free(self.internalDocument)
    }
}

public struct HoedownExtensions : RawOptionSetType {
    public var rawValue: UInt = 0
    
    public init(nilLiteral: ()) { self.rawValue = 0 }
    public init(_ value: UInt = 0) { self.rawValue = value }
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    public static var allZeros: HoedownExtensions { return self(0) }
    
    public static var None: HoedownExtensions      { return self(0) }
    
    // Block-level extensions
    public static var Tables: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_TABLES.value)) }
    public static var FencedCodeBlocks: HoedownExtensions    { return self(UInt(HOEDOWN_EXT_FENCED_CODE.value)) }
    public static var FootNotes: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_FOOTNOTES.value)) }
    
    // Span-level extensions
    public static var AutoLinkURLs: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_AUTOLINK.value)) }
    public static var StrikeThrough: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_STRIKETHROUGH.value)) }
    public static var Underline: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_UNDERLINE.value)) }
    public static var Highlight: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_HIGHLIGHT.value)) }
    public static var Quote: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_QUOTE.value)) }
    public static var Superscript: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_SUPERSCRIPT.value)) }
    public static var Math: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_MATH.value)) }
    
    // Other flags
    public static var NoIntraEmphasis: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_NO_INTRA_EMPHASIS.value)) }
    public static var SpaceHeaders: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_SPACE_HEADERS.value)) }
    public static var MathExplicit: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_MATH_EXPLICIT.value)) }
    
    // Negative flags
    public static var DisableIndentedCode: HoedownExtensions  { return self(UInt(HOEDOWN_EXT_DISABLE_INDENTED_CODE.value)) }
}

public struct HoedownHTMLFlags : RawOptionSetType {
    public var rawValue: UInt = 0
    
    public init(nilLiteral: ()) { self.rawValue = 0 }
    public init(_ value: UInt = 0) { self.rawValue = value  }
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    public static var allZeros: HoedownHTMLFlags { return self(0) }
    
    public static var None: HoedownHTMLFlags      { return self(0) }
    public static var SkipHTML: HoedownHTMLFlags  { return self(UInt(HOEDOWN_HTML_SKIP_HTML.value)) }
    public static var Escape: HoedownHTMLFlags    { return self(UInt(HOEDOWN_HTML_ESCAPE.value)) }
    public static var HardWrap: HoedownHTMLFlags  { return self(UInt(HOEDOWN_HTML_HARD_WRAP.value)) }
    public static var UseXHTML: HoedownHTMLFlags  { return self(UInt(HOEDOWN_HTML_USE_XHTML.value)) }
}
