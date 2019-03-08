//
//  FiltersViewController.swift
//  GetGoingClass
//
//  Created by Alla Bondarenko on 2019-02-04.
//  Copyright © 2019 SMU. All rights reserved.
//

import UIKit

enum RankBy {
    case prominence, distance

    func description() -> String {
        switch self {
        case .distance:
            return String(describing: self).capitalized
        case .prominence:
            return String(describing: self).capitalized
        }
    }
}


class FiltersViewController: UIViewController {
    

    // MARK: - IBOutlets

    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var isOpenNow: UISwitch!
    @IBOutlet weak var rankByLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var rankBySelectedLabel: UILabel!

    
    weak var delegate: FilterViewControllerDelegates?

    // MARK: - Properties

    var rankByDictionary: [RankBy] = [.prominence, .distance]
    
    var radiusValue: Double = 0.0
    var openByValue: Bool = true
    var rankByValue: String? = "prominence"
    var defaultValue: Bool = true
    
    // MARK: - View Controller Lifecycle
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        rankByLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rankByLabelTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        rankByLabel.addGestureRecognizer(tapGestureRecognizer)
        rankBySelectedLabel.text = rankByDictionary.first?.description()
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44.0)
        let toolBar = UIToolbar(frame: frame)
        toolBar.sizeToFit()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.hidePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneItem], animated: true)
        pickerView.addSubview(toolBar)
        pickerView.bringSubviewToFront(toolBar)
        pickerView.isUserInteractionEnabled = true
        
        
        loadSavedFilterValue()
    }

    // MARK: - IBActions

    @objc func rankByLabelTapped() {
        print("label was tapped")
        pickerView.isHidden = !pickerView.isHidden
    }

    @objc func hidePicker() {
        print("done was tapped")
        pickerView.isHidden = true
    }

    @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
        print("close button is clicked")
      //  delegate?.filterStateChange(state: defaultValue)
        dismiss(animated: true, completion: nil)
    
    }
    
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        
        //loadSavedFilterValue()
        print("radius \(radiusValue), openBy \(openByValue) & rankByValue\(rankByValue!)")
        if radiusValue > 0 || openByValue == false || rankByValue == "Distance" {
//            defalut = true
            print("with new value")
            saveFilterValues()
            defaultValue = false
            delegate?.filterStateChange(state: defaultValue)
            delegate?.getFilterRadiusValues(radius: radiusValue)
            delegate?.getFilterOpenByValues(open: openByValue)
            delegate?.getFilterRankByValues(rankby: rankByValue!)
            

        }else {
//            defalut = false
            saveFilterValues()
            print("save with default value")
            defaultValue = true
            delegate?.filterStateChange(state: defaultValue)
        }
       

        print("save button clicked with radius value: \(String(describing: radiusValue))")
        dismiss(animated: true, completion: nil)

    }
    
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        rankByValue = "Prominence"
        radiusValue = 0.0
        openByValue = true
        defaultValue = true
        rankBySelectedLabel.text = rankByValue
        radiusSlider.setValue(Float(radiusValue), animated: false)
        isOpenNow.setOn(openByValue, animated: false)
        saveFilterValues()
        delegate?.filterStateChange(state: defaultValue)
    }
    
    @IBAction func radiusSliderChangedValue(_ sender: UISlider) {
        // raduis value should be got from here
        radiusValue = Double(sender.value)
        print("slider value changed to \(sender.value) int \(Int(sender.value))")
        
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // open value is taken from here
         openByValue = sender.isOn
            
       
        print("switch value was changed to \(sender.isOn)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
 //save to local
    func saveFilterValues(){
        let preferences = UserDefaults.standard
//        preferences.set(defalut, forKey: "defaultValue")
        print("radius \(radiusValue), openByValue \(openByValue) & \(rankByValue!) from savefilter")
        preferences.set(radiusValue, forKey: "radius")
        preferences.set(openByValue, forKey: "open")
        preferences.set(rankByValue, forKey: "rankby")
        preferences.set(defaultValue,forKey: "defaultValue")
        // Checking the preference is saved or not
        didSave(preferences: preferences)
    }
    
    //load the saved value
    func loadSavedFilterValue(){
                    let preferences = UserDefaults.standard
                    if preferences.string(forKey: "rankby") != nil {
                        let rankby = preferences.string(forKey: "rankby")
                        let radius = preferences.double(forKey: "radius")
                        let openNow = preferences.bool(forKey: "open")
                        print("rankby value from shred preference = \(rankby!)")
                        print("radius value from shred preference = \(radius)")
                        print("open value from shred preference = \(openNow)")
                        rankByValue = rankby!
                        radiusValue = radius
                        openByValue = openNow
                        rankBySelectedLabel.text = rankby
                        radiusSlider.setValue(Float(radius), animated: false)
                        isOpenNow.setOn(openNow, animated: false)
                    }else {
                        print("no value from shared preference")
                    }
    }
    
    // Checking the UserDefaults is saved or not
    func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave{
            // Couldn't Save
            print("Preferences could not be saved!")
        }
    }


}

extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rankByDictionary.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rankByDictionary[row].description()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
         rankByValue = rankByDictionary[row].description()
        rankBySelectedLabel.text = rankByDictionary[row].description()
        
    }
}


//custom protocol

protocol FilterViewControllerDelegates: class {
    func getFilterRadiusValues(radius: Double)
    func getFilterOpenByValues(open: Bool)
    func getFilterRankByValues(rankby: String)
    func filterStateChange(state: Bool)
}

