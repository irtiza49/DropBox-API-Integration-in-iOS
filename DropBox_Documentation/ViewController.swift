//
//  ViewController.swift
//  DropBox_Documentation
//
//  Created by BS-136 on 1/4/18.
//  Copyright © 2018 BS-136com.bs23.com. All rights reserved.
//

import UIKit
import SwiftyDropbox
import FileBrowser

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var client = DropboxClientsManager.authorizedClient
    var imagePicker             = UIImagePickerController()
    var base64UIImageString     = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func triggerDropBoxFunction(sender: UIButton){
        switch (sender.tag){
        case 0:
            print("zero")
            self.myButtonInControllerPressed()
            
        case 1:
            print("one")
            self.RPCStyleRequest()
            
        case 2:
            print("two")
            self.saveImageToDropBox()
            
            //let fileBrowser = FileBrowser()
            //present(fileBrowser, animated: true, completion: nil)
            
        case 3:
            print("three")
            
        case 4:
            print("four")
            
        default:
            print("Integer out of range")
        }
        
    }
    func myButtonInControllerPressed() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,controller: self,openURL: { (url: URL) -> Void in
                UIApplication.shared.openURL(url)
        })
    }
    func RPCStyleRequest(){
        
        let folderPath = "/test/path/in/Dropbox/account"
        //let folderPath = "/BB"
        DropboxClientsManager.authorizedClient?.files.createFolderV2(path: "\(folderPath)").response { response, error in
            if let response = response {
                print(response)
            } else if let error = error {
                print(error)
            }
        }
        
    }
    func showAlert(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Utility Methods
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
        
        let jpegCompressionQuality: CGFloat = 0.9 // Set this to whatever suits your purpose
        if let base64String = UIImageJPEGRepresentation(chosenImage, jpegCompressionQuality)?.base64EncodedString() {
            self.base64UIImageString = base64String
        } //end of base64String
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func saveImageToDropBox(){
        // Upload a file
        
        let testData = "Hello Niloy!".data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        DropboxClientsManager.authorizedClient?.files.getMetadata(path: "/hello.txt").response { response, error in
            print("*** Get file metadata ***")
            if let metadata = response {
                if let file = metadata as? Files.FileMetadata {
                    print("This is a file with path: \(String(describing: file.pathLower))")
                    print("File size: \(file.size)")
                } else if let folder = metadata as? Files.FolderMetadata {
                    print("This is a folder with path: \(String(describing: folder.pathLower))")
                }
            } else {
                print(error!)
                self.setClientVerification()
            }
        }
        
        DropboxClientsManager.authorizedClient?.files.upload(path: "/hello.txt", mode: Files.WriteMode.overwrite, input: testData!).response { response, error in
            if let metadata = response {
                print()
                print("*** Upload file ****")
                print("Uploaded file name: \(metadata.name)")
                print("Uploaded file revision: \(metadata.rev)")
                
                // Get file (or folder) metadata
                
            }
        }//end of client
    }

    func setClientVerification(){
        DropboxClientsManager.authorizeFromController(UIApplication.shared,controller: self, openURL: { (url: URL) -> Void in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
    }

}
