//
//  HolderViewController.swift
//  ImageTesting
//
//  Created by savana kranth on 06/08/2020.
//  Copyright © 2020 savana kranth. All rights reserved.
//

import UIKit

enum DisplayState {
    case imageDisplay
    case regularDisplay
    
}

class HolderViewController: UIViewController {
    
    fileprivate var holderState: DisplayState = .regularDisplay
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    @IBOutlet var imagePicker: ImageSelection!
    @IBOutlet weak var bottomHolderView: UIView!
    @IBOutlet weak var holdersHeight: NSLayoutConstraint!
    
    
    @IBOutlet private weak var parentView: UIView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var leftHandleView: UIVisualEffectView!
    @IBOutlet private weak var rightHandleView: UIVisualEffectView!
    
    
    var mySelf: HolderViewController?
    
    fileprivate var displayBorder = true
    
    private var maxWidth: CGFloat {
           get {
               return UIScreen.main.bounds.width
           }
    }
    private var handleWidth: CGFloat {
        get {
            return rightHandleView.bounds.width
        }
    }
    
    private var maskLayer = CAShapeLayer()
    
    private let edgeOffset: CGFloat = 30

    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyBorderToImage(true)
        if let parent = self.parent {
            imagePicker.displayController = parent
        } else if let rootController = UIApplication.shared.windows.first?.rootViewController {
            imagePicker.displayController = rootController
        }
        
        imagePicker.imageSelected = { selected in
            if self.backgroundImage.isHidden && selected {
                self.displayImage()
            }
            
        }
        

    }
    
    func applyBorderToImage(_ border:Bool = false)  {
        parentView.layer.borderWidth = border ? 2 : 0
        parentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func reloadDisplay() {
        guard let window = self.view.window else { return }
        if mySelf == nil {
            mySelf = self
        }
        window.clipsToBounds = true
        window.translatesAutoresizingMaskIntoConstraints = true
        let origin = (holderState == .regularDisplay) ? CGPoint(x: 0, y: UIScreen.main.bounds.height-80) : .zero
        mySelf?.view.frame = CGRect(origin: origin, size: CGSize(width: window.frame.size.width, height: (holderState == .regularDisplay) ? 60 :UIScreen.main.bounds.height))
        mySelf?.backgroundImage.isHidden = (holderState == .regularDisplay)
        mySelf?.bottomConstant.constant = (holderState == .regularDisplay)  ? .zero : 20  //34
        mySelf?.view.layoutIfNeeded()
    }
    
    fileprivate func displayImage() {
        mySelf?.holderState = (holderState == .regularDisplay) ? .imageDisplay : .regularDisplay
        mySelf?.reloadDisplay()
    }
    
    @IBAction func brightnessUpdate(_ sender: UIButton) {
        if (sender.tag == 2) && backgroundImage.alpha < 1.0 {
            mySelf?.backgroundImage.alpha += 0.25
        } else if (sender.tag == 1) && backgroundImage.alpha > 0.25 {
            mySelf?.backgroundImage.alpha -= 0.25
        }
    }
        
    fileprivate func resetImageConstants()  {
//        mySelf?.backgrounImageTrailing.constant = 0
//        mySelf?.backgroundImageLeading.constant = 0
    }
    
    @IBAction func refreshToDefault(_ sender: Any) {
        mySelf?.holderState = .regularDisplay
        mySelf?.resetImageConstants()
        mySelf?.backgroundImage.alpha = 1
        mySelf?.reloadDisplay()
    }
    
    @IBAction func updateBorder(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        displayBorder = !displayBorder
        applyBorderToImage(sender.isSelected)
    }
    
    
    @IBAction func userSwipe(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: view)
        
        guard let gestureView = gesture.view else {
            return
        }
        
        // Right limit for mask
        var x = gestureView.center.x + translation.x
        if x < 0 { x = 0 }
        if x < leftHandleView.center.x { x = leftHandleView.center.x }
        if x > maxWidth { x = maxWidth }
        let y = gestureView.center.y
        
        // Update view position
        gestureView.center = CGPoint(x: x, y: y)
        
        // Mask
        var bounds = parentView.bounds
        bounds.origin.x = leftHandleView.center.x
        bounds.size.width = x - leftHandleView.center.x
        
        let path = UIBezierPath(rect: bounds)
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        gesture.setTranslation(.zero, in: view)
        
        // End event
        if gesture.state == .ended || gesture.state == .cancelled {
            let leftEdge: CGFloat = edgeOffset
            let rightEdge: CGFloat = maxWidth - edgeOffset
            
            // If at the extreme edge, update the mask with animation
            if x < leftEdge { x = 0 }
            if x > rightEdge { x = maxWidth }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                gestureView.center = CGPoint(x: x, y: y)
                bounds.origin.x = self.leftHandleView.center.x
                bounds.size.width = x - self.leftHandleView.center.x
                
                let path = UIBezierPath(rect: bounds)
                self.maskLayer.path = path.cgPath
                self.overlayView.layer.mask = self.maskLayer
            })
        }
        
    }
    
    fileprivate func toggleBottomViewDisplay() {
        mySelf?.holdersHeight.constant = mySelf?.holdersHeight.constant == 60 ? 0 : 60
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func toggleOptionsDisplayStatus(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.toggleBottomViewDisplay()
        }
    }
    
}


public class DisplayView: NSObject {
    
    private lazy var mainView: UIViewController  = {
        return UIStoryboard(name: "Holder", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: "holderController")
    }()
    
    
    public func display() {
        if !self.displayView() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                guard let primaryWindow = UIApplication.shared.windows.first else { return }
                primaryWindow.translatesAutoresizingMaskIntoConstraints = true
                primaryWindow.addSubview(self.mainView.view)
                (self.mainView as! HolderViewController).reloadDisplay()
            }
        }
        
    }
    
    public func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            guard let primaryWindow = UIApplication.shared.windows.first else { return }
            if primaryWindow.subviews.contains(self.mainView.view) {
                self.mainView.view.removeFromSuperview()
            }
        }
    }
    
    fileprivate func displayView() -> Bool {
        #if DEBUG
            return false
        #else
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
                return true
            }
            return !path.contains("sandboxReceipt")
        #endif
    }
}
