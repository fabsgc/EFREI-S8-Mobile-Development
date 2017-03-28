//
//  ViewController.swift
//  Calculator
//
//  Created by GroupeEfrei on 28/02/2017.
//  Copyright © 2017 GroupeEfrei. All rights reserved.
//

import UIKit

struct Constants {
    struct Math {
        static let numberOfDigitsAfterDecimalPoint = 6
        static let variableName = "M"
    }
    
    struct Drawing {
        static let pointsPerUnit = 50.0
    }
}

class CalcultorViewController: UIViewController {

    @IBOutlet fileprivate weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var graphicButton: UIButton!
    
    var userIsInTheMiddleOfTyping = false
    var savedProgram: CalculatorBrain.PropertyList?
    
    fileprivate var brain = CalculatorBrain()
    
    fileprivate func updateInterface() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result
        
        graphicButton.isEnabled = !brain.isPartialResult
    }
    
    fileprivate var displayValue: Double? {
        get {
            if let text = display.text, let value = Double(text) {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = Constants.Math.numberOfDigitsAfterDecimalPoint
                display.text = String(value)
                descriptionLabel.text = brain.getDescription()
            } else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsInTheMiddleOfTyping = false
            }
            
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            
            if digit != "." || textCurrentlyInDisplay.range(of: ".") == nil {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            if digit == "." {
                display.text = "0."
            }
            else {
                display.text = digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    
    @IBAction func clear(_ sender: Any) {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
            brain.undo()
            updateInterface()
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.remove(at: number.index(before: number.endIndex))
        
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        display.text = number
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        updateInterface()
    }
    
    @IBAction func saveVariable() {
        brain.variableValues[Constants.Math.variableName] = displayValue
        
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        }
        else {
            brain.undo()
        }

        brain.program = brain.program
        updateInterface()
    }
    
    @IBAction func retrieveVariable() {
        brain.setOperand(Constants.Math.variableName)
        userIsInTheMiddleOfTyping = false
        updateInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Graph":
                var destinationVC = segue.destination
                if let nvc = destinationVC as? UINavigationController {
                    destinationVC = nvc.visibleViewController ?? destinationVC
                }
                
                if let vc = destinationVC as? GraphicViewController {
                    vc.navigationItem.title = brain.description
                    vc.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues[Constants.Math.variableName] = Double(x)
                        self.brain.program = self.brain.program
                        return self.brain.result
                    }
                }
            default: break
            }
        }
    }
}

