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
    @IBOutlet weak var backgrounImageTrailing: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageLeading: NSLayoutConstraint!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    @IBOutlet weak var imageHolderView: UIView!
    @IBOutlet var imagePicker: ImageSelection!
    @IBOutlet weak var bottomHolderView: UIView!
    
    var mySelf: HolderViewController?
    
    fileprivate var displayBorder = true
    
    private var leftInitalValue: CGFloat = 0
    private var rightInitalValue: CGFloat = 0
    private let minWidth: CGFloat = 60
    
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
        imageHolderView.layer.borderWidth = border ? 2 : 0
        imageHolderView.layer.borderColor = UIColor.lightGray.cgColor
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
        mySelf?.backgrounImageTrailing.constant = 0
        mySelf?.backgroundImageLeading.constant = 0
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
    
    @IBAction func hideBottomHolderView(_ sender: Any) {
         toggleBottomViewDisplay()
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.mySelf?.toggleBottomViewDisplay()
        }
    }
    
    @IBAction func panFromLeftToRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard let _ = gesture.view else {
            return
        }
       
        backgrounImageTrailing.constant = leftInitalValue.advanced(by: translation.x)
        if backgrounImageTrailing.constant < 0  {
           backgrounImageTrailing.constant = 0
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .began {
            leftInitalValue = backgrounImageTrailing.constant
        }

    }
    
    @IBAction func panFromRightToLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard let _ = gesture.view else {
            return
        }
        backgroundImageLeading.constant = rightInitalValue.advanced(by: translation.x * -1)
        if backgroundImageLeading.constant < 0  {
            backgroundImageLeading.constant = 0
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .began {
            rightInitalValue = backgroundImageLeading.constant
        }
        
    }
    
    
    fileprivate func toggleBottomViewDisplay() {
        mySelf?.bottomHolderView.isHidden = !(mySelf?.bottomHolderView.isHidden ?? false)
        if mySelf?.backgroundImage.isHidden ?? true &&  mySelf?.bottomHolderView.isHidden ?? true {
            mySelf?.applyBorderToImage(false)
        } else {
            mySelf?.applyBorderToImage(mySelf?.displayBorder ?? true)
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
