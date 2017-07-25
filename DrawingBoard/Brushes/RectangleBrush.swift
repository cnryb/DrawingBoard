//
//  RectangleBrush.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-16.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

class RectangleBrush: BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        let point = CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y));
        let size = CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y));
        let rect = CGRect(origin: point, size: size);
        context.addRect(rect)
        context.setFillColor(self.color.cgColor)
        context.fill(rect)
    }
}
