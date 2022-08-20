//
//  SettingsViewController.swift
//  Prework
//
//  Created by Luis Rivera Rivera on 8/18/22.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var tipOneTextField: UITextField!
    @IBOutlet weak var tipTwoTextField: UITextField!
    @IBOutlet weak var tipThreeTextField: UITextField!
    @IBOutlet weak var tipFourTextField: UITextField!
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var tipPercentages: [Double] = [] {
        didSet {
            if let encodedPercentages = try? JSONEncoder().encode(tipPercentages) {
                UserDefaults.standard.set(encodedPercentages, forKey: "tipPercentages")
            }
        }
    }
    
    var currency = Currency(code: "USD", name: "US Dollar", symbol: "$") {
        didSet {
            if let encodedCurrency = try? JSONEncoder().encode(currency) {
                UserDefaults.standard.set(encodedCurrency, forKey: "currency")
            }
        }
    }
    
    var currencies: [Currency] = []
    
    var textFields: [UITextField] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedPercentages = UserDefaults.standard.data(forKey: "tipPercentages") {
            if let decodedPercentages = try? JSONDecoder().decode([Double].self, from: savedPercentages) {
                tipPercentages = decodedPercentages
            } else {
                fatalError("Percentages not found on user defaults.")
            }
        }
        
        textFields = [tipOneTextField, tipTwoTextField, tipThreeTextField, tipFourTextField]
        
        for (index, tip) in tipPercentages.enumerated() {
            textFields[index].text = String(tip * 100)
        }
        
        if let savedCurrency = UserDefaults.standard.data(forKey: "currency") {
            if let decodedCurrency = try? JSONDecoder().decode(Currency.self, from: savedCurrency) {
                currency = decodedCurrency
            }
        } else {
            fatalError("Currency not found on user defaults.")
        }
        
        currencies = Locale.availableIdentifiers.compactMap {
            guard let currencyCode = Locale(identifier: $0).currencyCode,
                  let name = Locale.autoupdatingCurrent.localizedString(forCurrencyCode: currencyCode),
                  let symbol = Locale(identifier: $0).currencySymbol  else { return nil }
            return Currency(code: $0, name: name, symbol: symbol)
        }
        
        let indexOfPreviousCurrencySelected = currencies.firstIndex(of: currency)!
        
        currencyPicker.selectRow(indexOfPreviousCurrencySelected, inComponent: 0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        save()
    
    }
    
    func save() {
        // Get the value of all textFields to saved it into user defaults
        var percentagesFromTextFields: [Double] = []
        
        for textField in textFields {
            let percentage = Double(textField.text ?? "0.0")! / 100.0
            percentagesFromTextFields.append(percentage)
        }
        
        tipPercentages = percentagesFromTextFields
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }
    
    // Method to dismiss the number pad when tapping away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - UIPicker Methods Conformance
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(currencies[row].name) - \(currencies[row].symbol)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currency = currencies[row]
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
