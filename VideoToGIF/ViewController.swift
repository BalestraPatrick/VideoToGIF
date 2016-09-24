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

    fileprivate let fileManager = FileManager.default
    fileprivate var videoURL: URL?
    fileprivate var gifURL: URL?
    fileprivate var videoState = VideoState.initial {
        didSet {
            updateVideoState()
        }
    }

    lazy var selectVideoDialog: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.prompt = "Select Video"
        panel.worksWhenModal = true
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.resolvesAliases = true
        return panel
    }()

    lazy var saveGIFDialog: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.prompt = "Save GIF"
        panel.worksWhenModal = true
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.resolvesAliases = true
        return panel
    }()
    
    // MARK: Actions

    @IBAction func chooseFile(_ sender: AnyObject) {
        
        guard let window = view.window else { return }

        selectVideoDialog.beginSheetModal(for: window, completionHandler: { result in

            // If the user pressed on the "Select Video" button, get the URL of the file.
            if result == NSModalResponseOK {
                // Close the open panel dialog.
                self.selectVideoDialog.close()
                
                // Update the UI and store the video URL.
                if let url = self.selectVideoDialog.url {
                    self.videoState = .selected(url: url)
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

    private func updateVideoState() {

        switch videoState {
        case .converting:
            progressIndicator.start()
        case .converted(let destinationURL):
            if let originalVideoURL = videoURL, let gifURL = gifURL, let destinationURL = destinationURL {
                let gifFileName = originalVideoURL.deletingPathExtension().lastPathComponent + ".gif"
                let finalGIFURL = destinationURL.appendingPathComponent(gifFileName)
                do {
                    try fileManager.moveItem(at: gifURL, to: finalGIFURL)
                } catch {
                    let alert = NSAlert()
                    alert.messageText = error.localizedDescription
                    alert.runModal()
                }

                let gifMetadata = finalGIFURL.fileMetadata()
                frameRateSlider.isHidden = true
                frameRateField.stringValue = gifMetadata
            }
            progressIndicator.stop()
        case .selected(let url):
            videoURL = url
            frameRateSlider.isEnabled = true
            convertToButton.isEnabled = true
            chooseVideoButton.title = "Change Another Video"
            videoMetadataField.stringValue = url.fileMetadata()
            frameRateSlider.isHidden = false
            frameRateField.stringValue = "\(frameRateSlider.intValue) FPS"

        case .initial:
            frameRateSlider.isEnabled = false
            convertToButton.isEnabled = false
            chooseVideoButton.title = "Choose Video"
            frameRateField.stringValue = "\(frameRateSlider.intValue) FPS"
        }
    }

    private func convertToGIF() {
        
        if case .selected(let url) = videoState {
            videoState = .converting

            Regift.createGIFFromSource(url, startTime: 0.0, duration: url.videoDuration(), frameRate: frameRateSlider.integerValue) { result in
                self.gifURL = result
                self.askUserWhereToSave(gifURL: url)
            }
        } else if let gifURL = gifURL {
            askUserWhereToSave(gifURL: gifURL)
        }
    }

    private func askUserWhereToSave(gifURL: URL) {
        
        guard let window = view.window else { return }

        saveGIFDialog.beginSheetModal(for: window, completionHandler: { result in

            self.saveGIFDialog.close()

            if let destinationURL = self.saveGIFDialog.url, result == NSModalResponseOK {
                self.videoState = .converted(url: destinationURL)
            } else {
                print("No video choosen")
            }
        })
    }
}
