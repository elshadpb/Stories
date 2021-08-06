//
//  UIView+Extension.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 08/03/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    var width: CGFloat {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.layoutFrame.width
        }
        return frame.width
    }
    var height: CGFloat {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.layoutFrame.height
        }
        return frame.height
    }
}
