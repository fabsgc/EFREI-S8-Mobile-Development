//
//  ViewController.swift
//  Calculator
//
//  Created by GroupeEfrei on 28/02/2017.
//  Copyright © 2017 GroupeEfrei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit: String = sender.currentTitle!
        
        if (userIsInTheMiddleOfTyping) {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay+digit
        } else {
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        userIsInTheMiddleOfTyping = false
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            displayValue = brain.result
        }
        
        displayValue = brain.result
    }
}

