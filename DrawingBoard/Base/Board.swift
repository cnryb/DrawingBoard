//
//  Board.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-15.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

enum DrawingState {
    case began, moved, ended
}

class Board: UIImageView {
    
    var beginPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    
    var color: UIColor = UIColor.black
    
    
    var drawingStateChangedBlock: ((_ state: DrawingState) -> ())?
    
    fileprivate var realImage: UIImage?
    
    fileprivate var drawingState: DrawingState!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public methods
    
    // MARK: - touches methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = nil
        beginPoint = touches.first!.location(in: self)
        endPoint = beginPoint
        self.drawingState = .began
        self.drawingImage()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        endPoint = touches.first!.location(in: self)
        self.drawingState = .moved
        self.drawingImage()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endPoint = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endPoint = touches.first!.location(in: self)
        self.drawingState = .ended
        self.drawingImage()
    }
    
    // MARK: - drawing
    
    fileprivate func drawingImage() {
        
        // hook
        if let drawingStateChangedBlock = self.drawingStateChangedBlock {
            drawingStateChangedBlock(self.drawingState)
        }
        
        UIGraphicsBeginImageContext(self.bounds.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.clear.setFill()
        UIRectFill(self.bounds)
        
        context?.setStrokeColor(self.color.cgColor)
        
        if let realImage = self.realImage {
            realImage.draw(in: self.bounds)
        }
        
        let point = CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y));
        let size = CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y));
        let rect = CGRect(origin: point, size: size);
        context?.addRect(rect)
        context?.setFillColor(self.color.cgColor)
        context?.fill(rect)
        
        let previewImage = UIGraphicsGetImageFromCurrentImageContext()
        
        if self.drawingState == .ended  {
            self.realImage = previewImage
        }
        UIGraphicsEndImageContext()
        
        // 用 Ended 事件代替原先的 Began 事件
        if self.drawingState == .ended {
            // self.boardUndoManager.addImage(self.image!)
        }
        
        self.image = previewImage
        
        lastPoint = endPoint
        
    }
}
