//
//  Extensions.swift
//  RT-ChatApp
//
//  Created by Ahmed Abaza on 8/9/20.
//  Copyright © 2020 eyecorps. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.width
    }
    
    public var height: CGFloat {
        return self.frame.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return top + height
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return left + width
    }
}
