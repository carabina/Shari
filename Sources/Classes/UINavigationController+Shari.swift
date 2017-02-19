//
//  UINavigationController+Shari.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/11.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit

enum InternalStructureViewType:Int {
    case ToView = 900, ScreenShot = 910, Overlay = 920
}

public extension Shari where Base: UINavigationController {

    var parentTargetView: UIView {
        return base.view
    }
    
    func presentViewController(toViewController:UIViewController) {

        toViewController.beginAppearanceTransition(true, animated: true)
        ModalAnimator.present(toView: toViewController.view, fromView: parentTargetView) { [weak self] in
            guard let strongSelf = self else { return }
            toViewController.endAppearanceTransition()
            toViewController.didMove(toParentViewController: strongSelf.base)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: base,
            action: #selector(base.overlayViewDidTap(_:))
        )
        let overlayView = ModalAnimator.overlayView(fromView: parentTargetView)
        overlayView!.addGestureRecognizer(tapGestureRecognizer)

    }
    
    func dismissModalView(completion: (() -> Void)?) {
        
        base.willMove(toParentViewController: nil)

        ModalAnimator.dismiss(
            fromView: parentTargetView,
            presentingViewController: base.visibleViewController) { [weak self] in

                completion?()
                self?.base.visibleViewController?.removeFromParentViewController()
        }
        
    }
    
   
    func dismissDownSwipeModalView(completion: (() -> Void)?) {
        
        base.willMove(toParentViewController: nil)
        
        ModalAnimator.dismiss(
            fromView: base.view.superview ?? parentTargetView,
            presentingViewController: base.visibleViewController) { [weak self] in
                
                completion?()
                self?.base.visibleViewController?.removeFromParentViewController()
                
        }
        
    }
}

extension UINavigationController {
    
    @objc fileprivate func overlayViewDidTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        si.parentTargetView.isUserInteractionEnabled = false
        willMove(toParentViewController: nil)
        
        ModalAnimator.dismiss(
            fromView: si.parentTargetView,
            presentingViewController: visibleViewController) { [weak self] in
                
                self?.visibleViewController?.removeFromParentViewController()
                self?.si.parentTargetView.isUserInteractionEnabled = true
                
        }
        
    }
}

