//
//  UIColor+FoundSounds.swift
//  Found Sounds
//
//  Created by David Jensenius on 2016-04-02.
//  Copyright © 2016 David Jensenius. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    class func primaryColor() -> UIColor {
        return UIColor(red: 235.0/255.0, green: 96.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    }

    class func contrastingComplementColor() -> UIColor {
        return UIColor(red: 170.0/255.0, green: 69.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    }

    class func backgroundColor() -> UIColor {
        return UIColor(red: 229.0/255.0, green: 224.0/255.0, blue: 220.0/255.0, alpha: 1.0)
    }

    class func primaryText() -> UIColor {
        return UIColor(red: 87.0/255.0, green: 87.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    }

    class func secondaryText() -> UIColor {
        return UIColor(red: 162.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
    }
}
