//
//  Extensions.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/19/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import Foundation

extension Array {
  func each(block: T -> ()) -> Array<T> {
    for item in self {
      block(item)
    }
    return self
  }
}

extension Double {

    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

extension String {
    
    func doubleValue() -> Double
    {
        let minusAscii: UInt8 = 45
        let dotAscii: UInt8 = 46
        let zeroAscii: UInt8 = 48

        var res = 0.0
        let ascii = self.utf8

        var whole = [Double]()
        var current = ascii.startIndex

        let negative = current != ascii.endIndex && ascii[current] == minusAscii
        if negative {
            current = current.successor()
        }

        while current != ascii.endIndex && ascii[current] != dotAscii {
            whole.append(Double(ascii[current] - zeroAscii))
            current = current.successor()
        }

        //whole number
        var factor: Double = 1
        for var i = count(whole) - 1; i >= 0; i-- {
            res += Double(whole[i]) * factor
            factor *= 10
        }

        //mantissa
        if current != ascii.endIndex {
            factor = 0.1
            current = current.successor()
            while current != ascii.endIndex {
                res += Double(ascii[current] - zeroAscii) * factor
                factor *= 0.1
                current = current.successor()
           }
        }

        if negative {
            res *= -1;
        }

        return res
    }
}