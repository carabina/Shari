//
//  NavigationController.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/14.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit

@objc public protocol NavigationControllerDelegate {
    @objc optional func navigationControllerDidSpreadToEntire(navigationController: UINavigationController)
}


public class NavigationController: UINavigationController {

    public var si_delegate: NavigationControllerDelegate?
    public var parentNavigationController: UINavigationController?
    public var parentTabBarController: UITabBarController?
    
    public var minDeltaUpSwipe: CGFloat = 50
    public var minDeltaDownSwipe: CGFloat = 50
    
    public var dismissControllSwipeDown = false
    public var fullScreenSwipeUp = true
    
    var previousLocation = CGPoint.zero
    var originalLocation = CGPoint.zero
    var originalFrame = CGRect.zero
        
    override public func viewDidLoad() {
        originalFrame = view.frame
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(NavigationController.handlePanGesture(gestureRecognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
   
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: parent!.view)
        let backgroundView = ModalAnimator.overlayView(fromView: parentTargetView)!
        let degreeY = location.y - previousLocation.y

        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            
            originalLocation = view.frame.origin
            break

        case UIGestureRecognizerState.changed:
            
            var frame = view.frame
            frame.origin.y += degreeY
            frame.size.height += -degreeY
            view.frame = frame

            ModalAnimator.transitionBackgroundView(overlayView: backgroundView, location: location)

            break

        case UIGestureRecognizerState.ended :
            
            if fullScreenSwipeUp &&  originalLocation.y - view.frame.minY > minDeltaUpSwipe {
                
                UIView.animate(
                    withDuration: 0.2,
                    animations: { [weak self] in

                        guard let strongslef = self else {
                            return
                        }
                        
                        var frame = strongslef.originalFrame
                        let statusBarHeight = UIApplication.shared.statusBarFrame.height
                        frame.origin.y = statusBarHeight
                        frame.size.height -= statusBarHeight
                        strongslef.view.frame = frame
                        
                        ModalAnimator.transitionBackgroundView(overlayView: backgroundView, location: strongslef.view.frame.origin)
                        
                    }, completion: { (result) -> Void in
                        
                        UIView.animate(
                            withDuration: 0.1,
                            delay: 0.0,
                            options: UIViewAnimationOptions.curveLinear,
                            animations: { () -> Void in
                                backgroundView.alpha = 0.0
                            },
                            completion: { [weak self] result in

                                guard let strongslef = self else {
                                    return
                                }
                              
                                gestureRecognizer.isEnabled = false
                                strongslef.si_delegate?.navigationControllerDidSpreadToEntire?(navigationController: strongslef)
                                
                            }
                        )
                    }
                )
                
            } else if dismissControllSwipeDown && view.frame.minY - originalLocation.y > minDeltaDownSwipe {
                si_dismissDownSwipeModalView(completion: nil)
            } else {

                UIView.animate(
                    withDuration: 0.6,
                    delay: 0.0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.1,
                    options: UIViewAnimationOptions.curveLinear,
                    animations: { [weak self] in
                        guard let strongslef = self else { return }
                        
                        ModalAnimator.transitionBackgroundView(overlayView: backgroundView, location: strongslef.originalLocation)
                        
                        var frame = strongslef.originalFrame //view.frame
                        frame.origin.y = strongslef.originalLocation.y
                        frame.size.height -= strongslef.originalLocation.y
                        strongslef.view.frame = frame
                    },

                    completion: { (result) -> Void in

                        gestureRecognizer.isEnabled = true

                })
                
            }

            break

        default:
            break
            
        }
        
        previousLocation = location
        
    }
    
    public override var parentTargetView: UIView {
        if tabBarController != nil {
            return tabBarController!.parentTargetView
        }
        
        return navigationController!.parentTargetView
    }
    
    public var parentController: UIViewController {
        if let tabBarController = tabBarController {
            return tabBarController
        }
        
        return navigationController!
    }
    
}
