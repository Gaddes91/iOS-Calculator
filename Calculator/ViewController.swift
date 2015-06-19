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

        // Update displayHistory to reflect the history of operands together with the operations performed upon them
        
        // String value of the current operator
        let operation = sender.currentTitle!

        // Check whether displayHistory is blank
        if displayHistory.text!.isEmpty {
            /* If displayHistory is empty then two operands must be added to the displayHistory (both the operand before and the operand after the operator symbol itself).
             * To access the operand before the operator, we must take the first value from the operandStack (operandStack[0]).
             * To access the operand after, we simply use displayValue.description.
             * We update displayHistory by inserting this string at the correct position (at the end of displayHistory), using atIndex: displayHistory.text!.endIndex
             * N.B. Xcode suggested use of stringInterpolationSegment - I do not fully understand what this does
             */
            
            /* This additional "if" statement confirms that operandStack is not empty before proceeding.
             * If the operation is performed whilst the operandStack is empty, the program will crash.
             */
            if operandStack != [] {
                displayHistory.text?.splice((String(stringInterpolationSegment: operandStack[0]) + operation + displayValue.description), atIndex: displayHistory.text!.endIndex)
            }
            
        } else {
            // If displayHistory is not empty then our job is easier - we only have to add the operator symbol and the latest value (displayValue.description)
            displayHistory.text?.splice(operation + displayValue.description, atIndex: displayHistory.text!.endIndex)
        }
        
        
        // Ensure that using an operator will have the same effect as pressing "enter"
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        // "$0" is the first number passed to the function, whereas "$1" is the second
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        // sin/cos functions accept a value in radians. This calculator will work with degrees, so we must convert user input (degrees) to radians.
        // Radians = Degrees * (PI / 180)
        case "sin": performOperation { sin($0 * (M_PI / 180)) }
        case "cos": performOperation { cos($0 * (M_PI / 180)) }
        default: break
        }
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
    }
    
    // Array to hold the "stack" of numbers entered by the user
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
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

