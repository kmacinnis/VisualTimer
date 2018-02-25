//
//  SubclassingUILabelExample.swift
//  TimeDrip
//
//  Copied From https://stackoverflow.com/questions/39066348/how-to-subclass-a-uilabel-in-swift-with-letter-spacing-set-to-1-5-using-nskernat
//
//

//TODO: - Remove this file

import UIKit

class CustomLabel: UILabel {
    static var kerning: CGFloat = 1.5

    override func awakeFromNib() {
        super.awakeFromNib()
        setKerning(kern: CustomLabel.kerning)
    }

    func setKerning(kern: CGFloat) {
        let text = self.text ?? ""
        let range = NSRange(location: 0, length: text.count)
        let mutableString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString())
        mutableString.addAttribute(NSAttributedStringKey.kern, value: kern, range: range)
        attributedText = mutableString
    }
}
