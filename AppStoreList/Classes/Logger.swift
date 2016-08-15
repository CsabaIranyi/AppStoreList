//
//  Copyright © 2016 Csaba Iranyi. All rights reserved.
//

// PERFORMANCE HACK: Override Swift.print() function in release build (App Store version) at the global scope

/// Writes the textual representations of `items`, separated by
/// `separator` and terminated by `terminator`, into the standard
/// output.
///
/// The textual representations are obtained for each `item` via
/// the expression `String(item)`.
///
/// - Note: To print without a trailing newline, pass `terminator: ""`
public func print(items: Any..., separator: String = "", terminator: String = "\n") {
    
    // Detect debug build
    //  You must set the "DEBUG" symbol fro Debug target.
    //  Set it in the "Swift Compiler - Custom Flags" section, "Other Swift Flags" line.
    //  You add the DEBUG symbol with the -DDEBUG entry.
    #if DEBUG
        
        // Items start index
        var index = items.startIndex
        
        // Items end index
        let endIdx = items.endIndex
        
        // Enumerate items
        repeat {
            // Print item to standard output
            Swift.print(items[index], separator: separator, terminator: index == (endIdx - 1) ? terminator : separator)
            
            // Increment index
            index += 1
            
        } while index < endIdx
        
    #endif
}