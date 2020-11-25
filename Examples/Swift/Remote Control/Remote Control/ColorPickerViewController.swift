//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var sendColorButton: UIButton!
    var pickedColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateColor()
        
        colorView.layer.borderWidth = 3.0
        colorView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
    }
    
    @IBAction func slidersValueChanged(_ sender: Any) {
        updateColor()
    }
    
    func updateColor() {
        let redAmount = CGFloat(redSlider.value) / 255.0
        let greenAmount = CGFloat(greenSlider.value) / 255.0
        let blueAmount = CGFloat(blueSlider.value) / 255.0
        
        pickedColor = UIColor(red: redAmount,
                              green: greenAmount,
                              blue: blueAmount,
                              alpha: 1.0)
        
        colorView.backgroundColor = pickedColor
    }
    
    func int(from color:UIColor) -> Int32 {
        let red = (Int32(redSlider.value) << 16)
        let green = (Int32(greenSlider.value) << 8)
        let blue = Int32(blueSlider.value)
        let rgb: Int32 = (Int32(255) << 24) + red + green + blue
        return rgb
    }
    
    @IBAction func sendColorButtonPressed(_ sender: Any) {
        
        if let tabBarController = tabBarController as? AdminViewTabBarController {
            tabBarController.send(object: int(from: pickedColor!) as Any, sender: self)
        }
    }
    
}
