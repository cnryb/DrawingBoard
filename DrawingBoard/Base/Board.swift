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
    
    var brush: BaseBrush?
    
    var strokeWidth: CGFloat
    var strokeColor: UIColor
    
    var drawingStateChangedBlock: ((_ state: DrawingState) -> ())?
    
    fileprivate var realImage: UIImage?
    
    fileprivate var drawingState: DrawingState!
    
    override init(frame: CGRect) {
        self.strokeColor = UIColor.black
        self.strokeWidth = 1
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.strokeColor = UIColor.black
        self.strokeWidth = 1
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public methods
    
    func takeImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        self.image?.draw(in: self.bounds)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // MARK: - touches methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.location(in: self)
            brush.endPoint = brush.beginPoint
			
            self.drawingState = .began
            
            self.drawingImage()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .moved
            
            self.drawingImage()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .ended
            
            self.drawingImage()
        }
    }
    
    // MARK: - drawing
    
    fileprivate func drawingImage() {
        if let brush = self.brush {
            // hook
            if let drawingStateChangedBlock = self.drawingStateChangedBlock {
                drawingStateChangedBlock(self.drawingState)
            }

            UIGraphicsBeginImageContext(self.bounds.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
            
            if let realImage = self.realImage {
                realImage.draw(in: self.bounds)
            }
            
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context!)
            context?.strokePath()
            
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawingState == .ended || brush.supportedContinuousDrawing() {
                self.realImage = previewImage
            }
            
            UIGraphicsEndImageContext()
            
            // 用 Ended 事件代替原先的 Began 事件
            if self.drawingState == .ended {
               // self.boardUndoManager.addImage(self.image!)
            }
            
            self.image = previewImage
            
            brush.lastPoint = brush.endPoint
        }
    }
}
