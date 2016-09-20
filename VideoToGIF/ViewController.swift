//
//  ViewController.swift
//  VideoToGIF
//
//  Created by Patrick Balestra on 9/18/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Cocoa
import Regift

class ViewController: NSViewController {
    
    @IBOutlet weak var chooseVideoButton: NSButton!
    @IBOutlet weak var convertToButton: NSButton!
    @IBOutlet weak var videoMetadataField: NSTextField!
    @IBOutlet weak var frameRateField: NSTextField!
    @IBOutlet weak var frameRateSlider: NSSlider!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    fileprivate var videoURL: URL?
    fileprivate let fileManager = FileManager.default
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.title = "Video to GIF"
    }
    
    // MARK: Actions

    @IBAction func chooseFile(_ sender: AnyObject) {
        
        guard let window = view.window else { return }
        
        let openFileDialog = NSOpenPanel()
        openFileDialog.prompt = "Select Video"
        openFileDialog.worksWhenModal = true
        openFileDialog.allowsMultipleSelection = false
        openFileDialog.canChooseDirectories = false
        openFileDialog.canChooseFiles = true
        openFileDialog.resolvesAliases = true
        openFileDialog.beginSheetModal(for: window, completionHandler: { result in
            
            // If the user pressed on the "Select Video" button, get the URL of the file.
            if result == NSModalResponseOK {
                // Close the open panel dialog.
                openFileDialog.close()
                
                // Update the UI and store the video URL.
                if let url = openFileDialog.url {
                    self.updateUIAfterGettingVideoPath(url: url)
                } else {
                    // Display an error message.
                    let alert = NSAlert()
                    alert.messageText = "The selected Video is not valid."
                    alert.runModal()
                }
            }
        })
    }
    
    @IBAction func convertToGIF(_ sender: AnyObject) {
        convertToGIF()
    }
    
    @IBAction func frameRateChanged(_ slider: NSSlider) {
        frameRateField.stringValue = "\(slider.intValue) FPS"
    }
    
    // MARK: Functions
    
    private func updateUIAfterGettingVideoPath(url: URL) {
        frameRateSlider.isEnabled = true
        convertToButton.isEnabled = true
        chooseVideoButton.title = "Change Another Video"
        videoMetadataField.stringValue = url.fileMetadata()
        videoURL = url
    }
    
    private func convertToGIF() {
        
        guard let url = videoURL else { return }
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        Regift.createGIFFromSource(url, startTime: 0.0, duration: 2.0, frameRate: 15) { result in
            
            if let result = result {
                let gifMetadata = result.fileMetadata()
                frameRateSlider.isHidden = true
                frameRateField.stringValue = gifMetadata
                askUserWhereToSave(gifURL: result)
            }
        }
    }

    private func askUserWhereToSave(gifURL: URL) {
        
        guard let window = view.window else { return }
        
        let openFileDialog = NSOpenPanel()
        openFileDialog.prompt = "Save GIF"
        openFileDialog.worksWhenModal = true
        openFileDialog.allowsMultipleSelection = false
        openFileDialog.canChooseDirectories = true
        openFileDialog.canChooseFiles = false
        openFileDialog.resolvesAliases = true
        openFileDialog.beginSheetModal(for: window, completionHandler: { result in
            
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true

            if let videoName = self.videoURL?.deletingPathExtension().lastPathComponent, let destinationURL = openFileDialog.url?.appendingPathComponent("\(videoName).gif"), result == NSModalResponseOK {
                
                do {
                    try self.fileManager.moveItem(at: gifURL, to: destinationURL)
                }
                catch let error as NSError {
                    let alert = NSAlert()
                    alert.messageText = error.localizedDescription
                    alert.runModal()
                }
            } else {
                print("No video choosen")
            }
        })
    }
}
