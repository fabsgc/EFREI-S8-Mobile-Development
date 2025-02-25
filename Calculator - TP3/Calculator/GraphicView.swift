//
//  GraphicView.swift
//  Calculator
//
//  Created by Supinfo on 28/03/2017.
//  Copyright © 2017 GroupeEfrei. All rights reserved.
//

import UIKit

protocol GraphicViewDataSource {
    func getBounds() -> CGRect
    func getYCoordinate(x: CGFloat) -> CGFloat?
}
class GraphicView: UIView {

    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale = CGFloat(Constants.Drawing.pointsPerUnit) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var dataSource: GraphicViewDataSource?
    private let drawer = AxesDrawer(color: UIColor.blue)

    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        drawFunction().stroke()
        drawer.drawAxesInRect(bounds: dataSource?.getBounds() ?? bounds, origin: origin, pointsPerUnit: scale)
    }
 
    private func drawFunction() -> UIBezierPath {
        let path = UIBezierPath()
        
        guard let data = dataSource else {
            return path
        }
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        let width = Int(bounds.size.width * scale)

        for pixel in stride(from: 0, to: width, by: 10) {
            point.x = CGFloat(pixel) / scale
            
            if let y = data.getYCoordinate(x: (point.x - origin.x) / scale) {
                
                if !y.isNormal && !y.isZero {
                    pathIsEmpty = true
                    continue
                }
                
                point.y = origin.y - y * scale
                
                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    func doubleTap(recognizer: UITapGestureRecognizer) {
        print("doubleTap")
        if recognizer.state == .ended {
            origin = recognizer.location(in: self)
        }
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        print("zoom")
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func move(recognizer: UIPanGestureRecognizer) {
        print("move")
        switch recognizer.state {
        case .changed: fallthrough
        case .ended:
            let translation = recognizer.translation(in: self)
            
            origin.x += translation.x
            origin.y += translation.y
            
            recognizer.setTranslation(CGPoint(), in: self)
        default: break
        }
    }
}
