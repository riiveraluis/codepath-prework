//
//  ViewController.swift
//  Prework
//
//  Created by Luis Rivera Rivera on 8/18/22.
//

import UIKit

class ViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    
    // Extra Feature IBOutlets
    @IBOutlet weak var peopleStepper: UIStepper!
    
    @IBOutlet weak var peopleLabel: UILabel!
    
    @IBOutlet weak var perPersonLabel: UILabel!
    
    // Values come from UserDefaults
    var currency = Currency(code: "USD", name: "US Dollar", symbol: "$") {
        didSet {
            if let encodedCurrency = try? JSONEncoder().encode(currency) {
                UserDefaults.standard.set(encodedCurrency, forKey: "currency")
            }
        }
    }
    
    var tipPercentages: [Double] = [] {
        didSet {
            if let encodedPercentages = try? JSONEncoder().encode(tipPercentages) {
                UserDefaults.standard.set(encodedPercentages, forKey: "tipPercentages")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefault Loading
        if let savedTipPercentages = UserDefaults.standard.data(forKey: "tipPercentages") {
            if let decodedPercentages = try? JSONDecoder().decode([Double].self, from: savedTipPercentages) {
                tipPercentages = decodedPercentages
            }
        } else {
            tipPercentages = [0.0, 0.15, 0.18, 0.20]
        }
        
        if let savedCurrency = UserDefaults.standard.data(forKey: "currency") {
            if let decodedCurrency = try? JSONDecoder().decode(Currency.self, from: savedCurrency) {
                currency = decodedCurrency
            }
        } else {
            let deviceCurrencyCode = Locale.current.currency?.identifier ?? "USD"
            let deviceCurrencyName = Locale.current.localizedString(forCurrencyCode: deviceCurrencyCode)!
            let deviceSymbol = Locale.current.currencySymbol ?? "$"
            
            currency = Currency(code: deviceCurrencyCode, name: deviceCurrencyName, symbol: deviceSymbol)
        }
        
        // Set the labels of the segmented control
        tipControl.removeAllSegments()
        
        for (index, percentage) in tipPercentages.enumerated() {
            tipControl.insertSegment(withTitle: "\(String(format: "%.0f", percentage * 100))%", at: index, animated: false)
        }
        
        // Reset UI
        billAmountTextField.text = ""
        tipControl.selectedSegmentIndex = 0
        peopleStepper.value = 1.0
        updateUI(tip: 0.0, total: 0.0, perPerson: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prework - Tip Calculator"
        
        // Update the labels with the new currency
        updateUI(tip: 0.0, total: 0.0, perPerson: peopleStepper.value)
        
        billAmountTextField.becomeFirstResponder()
    }
    
    func calculateBill() { // calculateTip method name renamed to better describe what it now does with the new bonus app features
        // Get the value contained on the billAmountTextField
        let bill = Double(billAmountTextField.text!) ?? 0.0
        
        // Get Total tip by multiplying tip * tipPercentage
        let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
        let total = bill + tip
        let perPerson = total / peopleStepper.value
        
        updateUI(tip: tip, total: total, perPerson: perPerson)
    }
    
    func updateUI(tip: Double, total: Double, perPerson: Double) {
        // Updating the labels with the calculated values and currency symbols
        tipAmountLabel.text = String(format: currency.symbol + "%.2f", tip)
        totalLabel.text = String(format: currency.symbol + "%.2f", total)
        peopleLabel.text = "\(Int(peopleStepper.value)) people"
        perPersonLabel.text = String(format: currency.symbol + "%.2f", perPerson)
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        calculateBill()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        calculateBill()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        calculateBill()
    }
    
    // Method to dismiss the number pad when tapping away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
