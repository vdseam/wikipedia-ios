import Foundation

extension UITextView {
    func frame(of textRange: NSRange) -> CGRect? {
        
        let oldSelectedRange = selectedRange
        selectedRange = textRange
        
        var rect: CGRect?
        if let uiTextRange = selectedTextRange {
            rect = firstRect(for: uiTextRange)
        }
        
        selectedRange = oldSelectedRange
        
        return rect
    }

    /// Adds formatting characters around selected text or around cursor
    /// - Parameters:
    ///   - formattingString: string used for formatting, will surround selected text or cursor
    func addStringFormattingCharacters(formattingString: String) {
        let cursorOffset = formattingString.count
        if let selectedRange = selectedTextRange {
            let cursorPosition = offset(from: endOfDocument, to: selectedRange.end)
            if selectedRange.isEmpty {
                replace(selectedTextRange ?? UITextRange(), withText: formattingString + formattingString)

                let newPosition = position(from: endOfDocument, offset: cursorPosition - cursorOffset)
                selectedTextRange = textRange(from: newPosition ?? endOfDocument, to: newPosition ?? endOfDocument)
            } else {
                if let selectedSubstring = text(in: selectedRange) {
                    replace(selectedTextRange ?? UITextRange(), withText: formattingString + selectedSubstring + formattingString)

                    let newStartPosition = position(from: selectedRange.start, offset: cursorOffset)
                    let newEndPosition = position(from: selectedRange.end, offset: cursorOffset)
                    selectedTextRange = textRange(from: newStartPosition ?? endOfDocument, to: newEndPosition ?? endOfDocument)
                } else {
                    replace(selectedTextRange ?? UITextRange(), withText: formattingString + formattingString)
                }
            }
        }
    }

    /// Decides if should add or remove formatting characters around selected text or around cursor, based on pre-existing formatting strings
    /// - Parameters:
    ///   - formattingString: string used for formatting, will surround selected text or cursor
    func addOrRemoveStringFormattingCharacters(formattingString: String) {
        let cursorOffset = formattingString.count
        if let selectedRange = selectedTextRange {
            if let start = position(from: selectedRange.start, offset: -cursorOffset),
               let end = position(from: selectedRange.end, offset: cursorOffset),
               let newSelectedRange = textRange(from: start, to: end) {

                if let newText = text(in: newSelectedRange) {
                    if newText.contains(formattingString) {
                        replace(newSelectedRange, withText: text(in: selectedRange) ?? String())

                        let newStartPosition = position(from: selectedRange.start, offset: -cursorOffset)
                        let newEndPosition = position(from: selectedRange.end, offset: -cursorOffset)
                        selectedTextRange = textRange(from: newStartPosition ?? endOfDocument, to: newEndPosition ?? endOfDocument)
                    } else {
                        addStringFormattingCharacters(formattingString: formattingString)
                    }
                }
            } else {
                addStringFormattingCharacters(formattingString: formattingString)
            }
        }
    }
}
