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
    var mySelf: HolderViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageHolderView.layer.borderWidth = 2
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
    
    @IBAction func displayImage(_ sender: UIButton) {
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
    
    @IBAction func leftGesture(_ sender: UISwipeGestureRecognizer) {
        if mySelf?.backgroundImageLeading.constant != 0 {
            mySelf?.resetImageConstants()
            return;
        }
        if (mySelf?.backgrounImageTrailing.constant ?? 0) < 3*(UIScreen.main.bounds.width/4) {
            mySelf?.backgrounImageTrailing.constant += UIScreen.main.bounds.width/4
        }
        mySelf?.backgroundImageLeading.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.mySelf?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func rightGesture(_ sender: UISwipeGestureRecognizer) {
        if mySelf?.backgrounImageTrailing.constant != 0 {
            mySelf?.resetImageConstants()
            return;
        }
     if (mySelf?.backgroundImageLeading.constant ?? 0) < 3*UIScreen.main.bounds.width/4 {
            mySelf?.backgroundImageLeading.constant += UIScreen.main.bounds.width/4
        }
        mySelf?.backgrounImageTrailing.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.mySelf?.view.layoutIfNeeded()
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
