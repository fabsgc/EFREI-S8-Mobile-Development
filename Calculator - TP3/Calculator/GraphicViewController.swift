//
//  GraphicViewController.swift
//  Calculator
//
//  Created by Supinfo on 28/03/2017.
//  Copyright © 2017 GroupeEfrei. All rights reserved.
//

import UIKit

class GraphicViewController: UIViewController, GraphicViewDataSource {
    @IBOutlet weak var graphicView: GraphicView! {
        didSet {
            graphicView.dataSource = self

            let pinch = UIPinchGestureRecognizer(target: graphicView, action: #selector(graphicView.zoom(recognizer:)))
            graphicView.addGestureRecognizer(pinch)
            
            let pan = UIPanGestureRecognizer(target: graphicView, action: #selector(graphicView.move(recognizer:)))
            graphicView.addGestureRecognizer(pan)
            
            let recognizer = UITapGestureRecognizer(target: graphicView, action: #selector(graphicView.doubleTap(recognizer:)))
            recognizer.numberOfTapsRequired = 2
            graphicView.addGestureRecognizer(recognizer)
            
            graphicView.setNeedsDisplay()
        }
    }

    func getBounds() -> CGRect {
        return navigationController?.view.bounds ?? view.bounds
    }
    
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)?}
