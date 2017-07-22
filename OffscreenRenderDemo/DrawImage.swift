//
//  DrawMaskImage.swift
//  OffscreenRenderDemo
//
//  Created by seedante on 16/4/23.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

func drawImage(image originImage: UIImage, rectSize: CGSize, roundedRadius radius: CGFloat) -> UIImage? {

    UIGraphicsBeginImageContextWithOptions(rectSize, false, UIScreen.main.scale)
    if let currentContext = UIGraphicsGetCurrentContext() {
        let rect = CGRect(origin: .zero, size: rectSize)
        currentContext.addPath(UIBezierPath(roundedRect: rect,
                                            byRoundingCorners: .allCorners,
                                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        currentContext.clip()

        //Don't use CGContextDrawImage, coordinate system origin in UIKit and Core Graphics are vertical oppsite.
        originImage.draw(in: rect)
        currentContext.drawPath(using: .fillStroke)
        let roundedCornerImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedCornerImage
    }
    return nil
}

func UIGraphicsDrawAntiRoundedCornerImageWithRadius(_ radius: CGFloat, outerSize: CGSize, innerSize: CGSize, fillColor: UIColor) -> UIImage? {

    UIGraphicsBeginImageContextWithOptions(outerSize, false, UIScreen.main.scale)
    if let currentContext = UIGraphicsGetCurrentContext() {
        let xOffset = (outerSize.width - innerSize.width) / 2
        let yOffset = (outerSize.height - innerSize.height) / 2

        let hLeftUpPoint = CGPoint(x: xOffset + radius, y: yOffset)
        let hRightUpPoint = CGPoint(x: outerSize.width - xOffset - radius, y: yOffset)
        let hLeftDownPoint = CGPoint(x: xOffset + radius, y: outerSize.height - yOffset)

        let vLeftUpPoint = CGPoint(x: xOffset, y: yOffset + radius)
        let vRightDownPoint = CGPoint(x: outerSize.width - xOffset, y: outerSize.height - yOffset - radius)

        let centerLeftUp = CGPoint(x: xOffset + radius, y: yOffset + radius)
        let centerRightUp = CGPoint(x: outerSize.width - xOffset - radius, y: yOffset + radius)
        let centerLeftDown = CGPoint(x: xOffset + radius, y: outerSize.height - yOffset - radius)
        let centerRightDown = CGPoint(x: outerSize.width - xOffset - radius, y: outerSize.height - yOffset - radius)
        let bezierPath = UIBezierPath()

        bezierPath.move(to: hLeftUpPoint)
        bezierPath.addLine(to: hRightUpPoint)
        bezierPath.addArc(withCenter: centerRightUp, radius: radius, startAngle: CGFloat(M_PI * 3 / 2), endAngle: CGFloat(M_PI * 2), clockwise: true)
        bezierPath.addLine(to: vRightDownPoint)
        bezierPath.addArc(withCenter: centerRightDown, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI / 2), clockwise: true)
        bezierPath.addLine(to: hLeftDownPoint)
        bezierPath.addArc(withCenter: centerLeftDown, radius: radius, startAngle: CGFloat(M_PI / 2), endAngle: CGFloat(M_PI), clockwise: true)
        bezierPath.addLine(to: vLeftUpPoint)
        bezierPath.addArc(withCenter: centerLeftUp, radius: radius, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI * 3 / 2), clockwise: true)
        bezierPath.addLine(to: hLeftUpPoint)
        bezierPath.close()

        //There is a strange bug: if draw drection of outer path is same with inner path, final result is just outer path.
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: 0, y: outerSize.height))
        bezierPath.addLine(to: CGPoint(x: outerSize.width, y: outerSize.height))
        bezierPath.addLine(to: CGPoint(x: outerSize.width, y: 0))
        bezierPath.addLine(to: CGPoint.zero)
        bezierPath.close()

        fillColor.setFill()
        bezierPath.fill()

        currentContext.drawPath(using: .fillStroke)
        let antiRoundedCornerImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return antiRoundedCornerImage
    }
    return nil
}

func UIGraphicsDrawAntiRoundedCornerImageWithRadius(_ radius: CGFloat, rectSize: CGSize, fillColor: UIColor) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(rectSize, false, UIScreen.main.scale)
    if let currentContext = UIGraphicsGetCurrentContext() {

        let bezierPath = UIBezierPath()

        let hLeftUpPoint = CGPoint(x: radius, y: 0)
        let hRightUpPoint = CGPoint(x: rectSize.width - radius, y: 0)
        let hLeftDownPoint = CGPoint(x: radius, y: rectSize.height)

        let vLeftUpPoint = CGPoint(x: 0, y: radius)
        let vRightDownPoint = CGPoint(x: rectSize.width, y: rectSize.height - radius)

        let centerLeftUp = CGPoint(x: radius, y: radius)
        let centerRightUp = CGPoint(x: rectSize.width - radius, y: radius)
        let centerLeftDown = CGPoint(x: radius, y: rectSize.height - radius)
        let centerRightDown = CGPoint(x: rectSize.width - radius, y: rectSize.height - radius)

        bezierPath.move(to: hLeftUpPoint)
        bezierPath.addLine(to: hRightUpPoint)
        bezierPath.addArc(withCenter: centerRightUp, radius: radius, startAngle: CGFloat(M_PI * 3 / 2), endAngle: CGFloat(M_PI * 2), clockwise: true)
        bezierPath.addLine(to: vRightDownPoint)
        bezierPath.addArc(withCenter: centerRightDown, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI / 2), clockwise: true)
        bezierPath.addLine(to: hLeftDownPoint)
        bezierPath.addArc(withCenter: centerLeftDown, radius: radius, startAngle: CGFloat(M_PI / 2), endAngle: CGFloat(M_PI), clockwise: true)
        bezierPath.addLine(to: vLeftUpPoint)
        bezierPath.addArc(withCenter: centerLeftUp, radius: radius, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI * 3 / 2), clockwise: true)
        bezierPath.addLine(to: hLeftUpPoint)
        bezierPath.close()

        //If draw drection of outer path is same with inner path, final result is just outer path.
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: 0, y: rectSize.height))
        bezierPath.addLine(to: CGPoint(x: rectSize.width, y: rectSize.height))
        bezierPath.addLine(to: CGPoint(x: rectSize.width, y: 0))
        bezierPath.addLine(to: CGPoint.zero)
        bezierPath.close()

        fillColor.setFill()
        bezierPath.fill()
        
        currentContext.drawPath(using: .fillStroke)
        let antiRoundedCornerImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return antiRoundedCornerImage
    }
    return nil
}

