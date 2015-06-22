//
//  ViewController.swift
//  Calculator
//
//  Created by Matthew Gaddes on 07/06/2015.
//  Copyright (c) 2015 Matthew Gaddes. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayHistory: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    
    // This is the "green arrow" that goes from the controller to the model
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        // Declare a constant "digit" and specify its value as the title of the current sender. For this application, the current sender will be 1, 2, 3, 4, 5... etc.
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            
            // Check whether current display contains decimal point
            if display.text?.rangeOfString(".") != nil {
                // If current display contains decimal point, then check whether the current digit entered by user contains decimal point
                if digit == "." {
                    // Nothing happens - a second decimal point will NOT be appended to display
                } else {
                    // If current display does not contain a decimal point, allow user to enter whatever they like, including decimal points
                    display.text = display.text! + digit
                }
            } else {
                // Append the value of "digit" (as string) to current display.text
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func appendSpecial(sender: UIButton) {
        
        var specialDigit = sender.currentTitle!
        displayHistory.text = displayHistory.text! + specialDigit
        
        if userIsInTheMiddleOfTypingANumber {
            // Do nothing
        } else {
            // The switch function allows for the easy addition of special values, if necessary
            switch specialDigit {
            case "π": display.text = "\(M_PI)"
            default: break
            }
            enter()
        }
    }
    
    @IBAction func operate(sender: UIButton) {

        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
        // Update displayHistory each time an operation is performed
        displayHistory.text = brain.updateDisplayHistory()
    }
    
    // Function to perform whatever operation is specified by user (multiplication, etc..)
    // "private" is used to disable inference of @objC. This allows us to implement method overloading, as described on StackOverflow http://stackoverflow.com/questions/29457720/compiler-error-method-with-objective-c-selector-conflicts-with-previous-declara/29457777#29457777
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            // operandStack.removeLast() will reference the last value in the stack -> the operator action will be performed (multiplication, etc..), then the value will be removed from the stack
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            // The use of enter() appends the displayValue to the stack
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    // Function to clear all values when "Clear All" button is clicked
    @IBAction func ClearAll(sender: UIButton) {
        // Clear operandStack
        operandStack = []

        // Clear display
        display.text = ""
        
        // Clear displayHistory
        displayHistory.text = ""
        
        // Reset userIsInTheMiddleOfTypingANumber
        userIsInTheMiddleOfTypingANumber = false
        
        brain.opStack = []
        brain.displayHistory = ""
    }
    
    // Array to hold the "stack" of numbers entered by the user
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        
        // Push operand on to the stack (CalculatorBrain.swift)
        if let result = brain.pushOperand(displayValue) {
            // If result is not nil, update displayValue with result
            displayValue = result
            
        } else {
            displayValue = 0
        }
    }
    
    // We use "get" and "set" since we want this value to always be computed
    var displayValue: Double {
        get {
            // Figure out what goes on here for an "extra credit"
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            // Convert newValue to a string
            // newValue is a variable (built-in to Swift) that takes the last value inputted by the user
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}