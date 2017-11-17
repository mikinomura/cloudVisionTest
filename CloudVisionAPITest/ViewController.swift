//
//  ViewController.swift
//  CloudVisionAPITest
//
//  Created by Miki Nomura on 11/3/17.
//  Copyright © 2017 Miki Nomura. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   //UIImageView to stock image datas
    @IBOutlet weak var image: UIImageView!
    var selectedImage: UIImageView!
    
    //Squares for color spectrums
    @IBOutlet weak var square1: UIView!
    @IBOutlet weak var square2: UIView!
    @IBOutlet weak var square3: UIView!
    @IBOutlet weak var square4: UIView!
    @IBOutlet weak var square5: UIView!
    @IBOutlet weak var square6: UIView!
    @IBOutlet weak var square7: UIView!
    @IBOutlet weak var square8: UIView!
    @IBOutlet weak var square9: UIView!
    @IBOutlet weak var square10: UIView!
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            //Pick an image
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            
            //No Edit
            picker.allowsEditing = false
            
            //Show Cameraroll
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selected = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        selectedImage.image = selected
        
        
        detectImageProperty()
    }
    
    func detectImageProperty() {
        if let base64image = UIImagePNGRepresentation(selectedImage.image!)?.base64EncodedString() {
            let request: Parameters = [
                "requests": [
                    "image": [
                        "content": base64image
                    ],
                    "features": [
                        [
                            "type": "IMAGE_PROPERTIES"
                        ]
                    ]
                ]
            ]
            
            let httpHeader: HTTPHeaders = [
                "Content-Type": "application/json",
                "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
            ]
            
            var googleApiKey = "AIzaSyBK7YdH1J5k6eA1GbPjRnczcPHfLgpnqiY"
            
            Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(googleApiKey)", method: .post, parameters: request, encoding: JSONEncoding.default, headers: httpHeader).validate(statusCode: 200..<300).responseJSON { response in
                // レスポンスの処理
                self.googleImageResult(response: response)
            }
        }
    }
    
    func googleImageResult(response: DataResponse<Any>) {
        guard let result = response.result.value else {
            // Return if the response is empty
            return
        }
        let json = JSON(result)
        var jsonColors: JSON = json["responses"][0]["imagePropertiesAnnotation"]["dominantColors"]["colors"]
        //var annotations: JSON = json["responses"][0]["imagePropertiesAnnotation"]["dominantColors"]["colors"][0]["color"]
        var colorBoxes: Array = [square1, square2, square3, square4, square5, square6, square7, square8, square9, square10]
        let numberOfDominantColors = json["responses"][0]["imagePropertiesAnnotation"]["dominantColors"]["colors"].count
        
        var startXPosition = Int((colorBoxes[0]?.frame.origin.x)!)
        
        for i in 0...9 {
            let blue = jsonColors[i]["color"]["blue"].floatValue
            let red = jsonColors[i]["color"]["red"].floatValue
            let green = jsonColors[i]["color"]["green"].floatValue
            let score = jsonColors[i]["score"].floatValue
            let yPosition = colorBoxes[i]?.frame.origin.y
            let width = score * 100
            
            colorBoxes[i]?.backgroundColor = UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: 1.0)
            
            colorBoxes[i]?.frame = CGRect(x:Int(startXPosition), y: Int(yPosition!), width: Int(width) , height: 100)
            startXPosition = startXPosition + Int(width)
   
        }
    }
    
    @IBAction func ShareButtonTapped(_ sender: UIButton) {
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

}

