//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Matthew Gaddes on 20/06/2015.
//  Copyright (c) 2015 Matthew Gaddes. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    /* We have to state ": Printable" in order for the description variable below to work
     * Here we are stating that enum IMPLEMENTS whatever is in the Printable PROTOCOL
     */
    enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, () -> Double)
        
        /* Add a computed property to this type.
         * Since we want this to be a read-only property, we use "get" but not "set"
         */
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    // This array will hold all our "Ops" (both operations and operands)
    var opStack = [Op]()
    
    // Used within func updateDisplayHistory - This array holds operands only
    var opStackOperand = [Op]()
    
    // Used within func updateDisplayHistory - This array holds operations only
    var opStackOperation = [Op]()
    
    
    /* This instance variable is required for use with performOperation()
     * It holds keys of type String and values of type Op
     */
    private var knownOps = [String: Op]()
    
    // Initialiser to be called when CalculatorBrain is first used (N.B. init has no arguments)
    init() {
        // Add knownOps to the knownOps dictionary
        knownOps["×"] = Op.BinaryOperation("×", *)
        // "$0" is the first number passed to the function, whereas "$1" is the second
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        // We cannot simplify divide or minus any further, since these functions accept arguments in reverse order
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        // sin/cos functions accept a value in radians. This calculator will work with degrees, so we must convert user input (degrees) to radians.
        knownOps["sin"] = Op.UnaryOperation("sin") { sin($0 * (M_PI / 180)) }
        knownOps["cos"] = Op.UnaryOperation("cos") { cos($0 * (M_PI / 180)) }
        knownOps["π"] = Op.Constant("π") { M_PI }
    }
    
    /* The first time we call evaluate we want the whole stack.
     * Each time afterwards, we want to return the evaluated value (or operator), and also the remainder of the stack.
     * To do this, we use tuples.
     * N.B. in front of "ops: [Op]" there is an implicit "let", i.e. ops is read-only!
     */
    func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        // Check that ops is not empty
        if !ops.isEmpty {
            /* We must create a copy of "ops" that is mutable (able to be mutated), since we want to remove items.
             * The local variable "remainingOps" does what is says on the tin - it holds all the ops that remain after one has been popped off the top of the stack.
             */
            var remainingOps = ops
            // This removes and returns the last thing added to the array
            let op = remainingOps.removeLast()
            
            switch op {
            // Swift is using type inference to know that we really mean "Op.Operand", or "Op.UnaryOperation", etc.
                
            // When we encounter an operand, we want to assign it to a new constant named "operand"
            case .Operand(let operand):
                // We want to return both the operand value and the remaining ops
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                
                /* This is where recursion comes into play
                 * Create a local variable "operandEvaluation" which calls the function evaluate() with the remainingOps
                 */
                let operandEvaluation = evaluate(remainingOps)
                // operandEvaluation returns a tuple. We must access the result by using dot (.) notation, and unwrap the optional using "if let"
                if let operand = operandEvaluation.result {
                    // This must return the remainingOps AFTER we have recursed.
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                // We run the same process as for .UnaryOperation but we must do it twice.
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    // Evaluate the remainingOps after op1Evaluation
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let operation):
                // Return a tuple containing the result of the function (as a Double) together with the remaining ops
                return (operation(), remainingOps)
            }
        }
        // This will return nil if the evaluation fails
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        
        /* This is a different way to call a function that returns a tuple.
         * We let a tuple equal the result (the result is assigned to a tuple), rather than assigning it to a single variable and using dot notation to access each individual value.
         */
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    // Push operand on to opStack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        
        // Append operand to the "operand-only" array
        opStackOperand.append(Op.Operand(operand))
        
        // Every time we push an operand this will return the evaluation
        return evaluate()
    }
    
    // Push operation symbol on to opStack
    func performOperation(symbol: String) -> Double? {
        /* The constant "operation" is of type optional Op, since we may be looking up something that is not in the array knownOps
         * As such, we must use the syntax "if let" to check whether the Op exists.
         * N.B. whenever we look something up in a dictionary, it ALWAYS returns an optional (either "nil", or the type of the thing we are looking for).
         */
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            
            // Append operation to the "operation-only" array
            opStackOperation.append(operation)
        }
        return evaluate()
    }
    
    // Must be defined outside of the following function to prevent the displayHistory from resetting to "" each time the function is called
    var displayHistory = ""
    
    // Update display history to reflect the history of operands together with the operations performed upon them
    func updateDisplayHistory() -> String {
        
        /* This "if" statement confirms that opStackOperand is not empty before proceeding.
        * If the operation is performed whilst the opStackOperand is empty, the program will crash.
        */
        if !opStackOperand.isEmpty {
            
            /* If displayHistory is empty then two operands must be added to the displayHistory (both the operand before and the operand after the operator symbol itself)
            * To access the operand before the operator, we must take the penultimate value from the operand-only stack (opStackOperand.removeAtIndex(opStackOperand.count - 2))
            * To access the operand after, we simply use opStackOperand.removeLast()
            * We update displayHistory by appending each op, as a string, to the end of the existing displayHistory (displayHistory += "\(...)")
            */
            if displayHistory.isEmpty {
                // Append the operand before the operation, the operation itself and, finally, the second operand
                displayHistory += "\(opStackOperand.removeAtIndex(opStackOperand.count - 2))"
                displayHistory += "\(opStackOperation.removeLast())"
                displayHistory += "\(opStackOperand.removeLast())"
            } else {
                // If displayHistory is not empty then our job is easier - we only have to add the operation symbol and the latest operand
                displayHistory += "\(opStackOperation.removeLast())"
                displayHistory += "\(opStackOperand.removeLast())"
            }
        }
        return displayHistory
    }
}