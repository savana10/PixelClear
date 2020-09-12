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
    @IBOutlet weak var bottomHolderConstant: NSLayoutConstraint!
    @IBOutlet weak var leftHandleView: UIVisualEffectView!
    @IBOutlet weak var rightHandleView: UIVisualEffectView!
    @IBOutlet weak var rightHandleWidth: NSLayoutConstraint!
    @IBOutlet weak var leftHandleWidth: NSLayoutConstraint!
    
    var mySelf: HolderViewController?
    
    fileprivate var displayBorder = true
    
    private var leftInitalValue: CGFloat = 0
    private var rightInitalValue: CGFloat = 0
    private let minWidth: CGFloat = 60
    private let minAlpha: CGFloat = 0.25
    private let maxAlpha: CGFloat = 1.0
    private var bottomValue: CGFloat = 20
    
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
                self.leftHandleView.isHidden = false
                self.rightHandleView.isHidden = false
            }
        }
        imagePicker.displayHandler  = { displaying in
            self.view.layer.zPosition = CGFloat(!displaying ? INT_MAX : 0)
        }
        
        rightHandleView.pc_makeViewRounded(circular: true)
        leftHandleView.pc_makeViewRounded(circular: true)
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
        let origin = (holderState == .regularDisplay) ? CGPoint(x: 0, y: UIScreen.main.bounds.height-(60+bottomValue)) : .zero
        mySelf?.view.frame = CGRect(origin: origin, size: CGSize(width: window.frame.size.width, height: (holderState == .regularDisplay) ? 60 :UIScreen.main.bounds.height))
        mySelf?.backgroundImage.isHidden = (holderState == .regularDisplay)
        mySelf?.bottomConstant.constant = (holderState == .regularDisplay)  ? .zero : bottomValue
        applyBorderToImage(holderState != .regularDisplay)
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
        self.leftHandleView.isHidden = true
        self.rightHandleView.isHidden = true
    }
    
    @IBAction func refreshToDefault(_ sender: Any) {
        mySelf?.holderState = .regularDisplay
        mySelf?.resetImageConstants()
        mySelf?.backgroundImage.alpha = 1
        mySelf?.reloadDisplay()
    }
    
    @IBAction func updateBorder(_ sender: UIButton) {
        if (holderState != .regularDisplay) {
            sender.isSelected = !sender.isSelected
            displayBorder = !displayBorder
            applyBorderToImage(sender.isSelected)
        }
    }
    
    @IBAction func closeWholeView(_ sender: Any) {
        DisplayView.shared.hide()
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
        
        leftHandleView.alpha = maxAlpha
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .began {
            leftHandleView.alpha = minAlpha
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
        rightHandleView.alpha = maxAlpha
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .began {
            rightHandleView.alpha = minAlpha
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
    
    @IBAction func hideBottomHolder(_ sender: Any) {
        bottomHolderConstant.constant =  (bottomHolderConstant.constant == 60) ? 0 : 60
        rightHandleWidth.constant = (rightHandleWidth.constant == 80 ) ? 0 : 80
        leftHandleWidth.constant = (leftHandleWidth.constant == 80 ) ? 0 : 80
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func moveBottomView(_ gesture: UIPanGestureRecognizer) {
        if (holderState == .regularDisplay) {
            return;
        }
        let translation = gesture.translation(in: view)
        guard let _ = gesture.view else {
            return
        }
        bottomConstant.constant = bottomValue.advanced(by: -translation.y)
        if bottomConstant.constant < 20  {
            bottomConstant.constant = 20
        }
        
        if bottomConstant.constant > UIScreen.main.bounds.size.height - 100  {
            bottomConstant.constant = UIScreen.main.bounds.size.height - 100
        }

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .began {
            if gesture.state == .ended || gesture.state == .cancelled {
                let midPoint = UIScreen.main.bounds.height/2
                if bottomConstant.constant <=  midPoint+120  && bottomConstant.constant >= midPoint-80 {
                    bottomConstant.constant = bottomConstant.constant >= midPoint ? midPoint+120 : midPoint - 100
                }
                
            }
            bottomValue = bottomConstant.constant
        }
        
    }
    
    
}


public class DisplayView: NSObject {
    
    @objc public static let shared = DisplayView()
    
    private lazy var mainView: UIViewController  = {
        return UIStoryboard(name: "Holder", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: "holderController")
    }()
    
    
    public func display() {
        if self.displayView() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                guard let primaryWindow = UIApplication.shared.windows.first else { return }
                primaryWindow.translatesAutoresizingMaskIntoConstraints = true
                self.mainView.view.layer.zPosition = CGFloat(INT_MAX)
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
        return !Bundle.main.isProduction
    }
}
