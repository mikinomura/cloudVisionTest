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

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var imagePropertyText: UILabel!
    
    @IBAction func selectPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            //Reset texts
            text.text = ""
            
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
        
        image.contentMode = .scaleAspectFit
        image.image = selected
        
        text.text = "Detecting texts..."
        imagePropertyText.text = "Detecting image properties..."
        
        dismiss(animated: true, completion: nil)
        
        detectText()
        
        detectImageProperty()
    }
    
    enum DetectMethod: String {
        case GOOGLE
    }
    
    var method = DetectMethod.GOOGLE
    
    func detectText() {
        switch method {
        case DetectMethod.GOOGLE:
            detectTextGoogle()
        }
    }
    
    func detectTextGoogle() {
        if let base64image = UIImagePNGRepresentation(image.image!)?.base64EncodedString() {
            let request: Parameters = [
                "requests": [
                    "image": [
                        "content": base64image
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION",
                            "maxResults": 1
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
                self.googleResult(response: response)
            }
        }
    }
    
    func googleResult(response: DataResponse<Any>) {
        guard let result = response.result.value else {
            // レスポンスが空っぽだったりしたら終了
            return
        }
        let json = JSON(result)
        let annotations: JSON = json["responses"][0]["textAnnotations"]
        var detectedText: String = ""
        // 結果からdescriptionを取り出して一つの文字列にする
        annotations.forEach { (_, annotation) in
            detectedText += annotation["description"].string!
        }
        // 結果を表示する
        text.text = detectedText
    }
    
    func detectImageProperty() {
        if let base64image = UIImagePNGRepresentation(image.image!)?.base64EncodedString() {
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
            // レスポンスが空っぽだったりしたら終了
            return
        }
        let json = JSON(result)
        let annotations: JSON = json["responses"]
        // 結果を表示する
        imagePropertyText.text = annotations.string 
    }

}

