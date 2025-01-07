//
//  Button.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

struct Button : Codable, Hashable {
    enum `Type` : String, Codable, Hashable {
        case a = "a"
        case b = "b"
        case x = "x"
        case y = "y"
        
        case dpadUp = "dpadUp"
        case dpadDown = "dpadDown"
        case dpadLeft = "dpadLeft"
        case dpadRight = "dpadRight"
        
        case l = "l"
        case r = "r"
        
        case zl = "zl"
        case zr = "zr"
        
        case home = "home"
        case minus = "minus"
        case plus = "plus"
        
        case fastForward = "fastForward"
        case settings = "settings"
        
        enum CodingKeys : String, CodingKey {
            case a = "circle"
            case b = "cross"
            case x = "triangle"
            case y = "square"
            
            case l = "l1"
            case r = "r1"
            
            case zl = "l2"
            case zr = "r2"
            
            case minus = "select"
            case plus = "start"
        }
    }
    
    var alpha: Double? = 1
    let x, y: Double
    let width, height: Double
    let type: `Type`
    
    var backgroundImageName: String? = nil
    var buttonClassName: String? = "defaultButton"
    var transparent: Bool? = false
    var vibrateOnTap: Bool? = true
    
    struct BorderedStyle : Codable, Hashable {
        let borderColor: String // hex
        let borderWidth: CGFloat
    }
    
    struct DefaultStyle : Codable, Hashable {
        let backgroundImageName: String
    }
    
    var borderedStyle: BorderedStyle? = nil
    var defaultStyle: DefaultStyle? = nil
    
    func letter(for core: Core) -> String? {
        switch type {
        
        default:
            nil
        }
    }
    
    func image(for core: Core) -> UIImage? {
        switch type {
            
        case .dpadUp:
                return UIImage(systemName: "arrowtriangle.up.circle.fill")
            case .dpadDown:
                return UIImage(systemName: "arrowtriangle.down.circle.fill")
            case .dpadLeft:
                return UIImage(systemName: "arrowtriangle.left.circle.fill")
            case .dpadRight:
                return UIImage(systemName: "arrowtriangle.right.circle.fill")
            
        case .l:
            return UIImage(systemName: "l.button.default.fill")
        case .r:
            return UIImage(systemName: "r.button.default.fill")
            
        case .zl:
            return UIImage(systemName: "zl.rectangle.roundedtop.fill")
               
        case .zr:
            return UIImage(systemName: "zr.rectangle.roundedtop.fill")
            
        case .home:
            return UIImage(systemName: "house.circle.fill")
        case .minus:
            return UIImage(systemName: "minus.circle.fill")
        case .plus:
            return UIImage(systemName: "plus.circle.fill")
            
        case .fastForward:
            return UIImage(systemName: "forward.fill")
        case .settings:
            return UIImage(systemName: "gearshape.fill")
        default:
                return nil
        }
    }
}
