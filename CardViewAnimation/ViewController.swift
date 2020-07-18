//
//  ViewController.swift
//  CustomActionSheet
//
//  Created by Usman Nazir on 18/07/2020.
//  Copyright © 2020 Usman Nazir. All rights reserved.
//

import UIKit

enum CardState {
    case expanded
    case peek
    case collapsed
}

class ViewController: UIViewController {

    var cardViewController : CardViewController!
    //var cardVisible = false
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 65
    
    var currentState : CardState = .collapsed
    
    var nextState:CardState {
        switch currentState {
        case .collapsed:
            return .peek
        case .expanded:
            return .collapsed
        case .peek:
            return .expanded
        }
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
    }

    func setupCard(){
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: self.view.bounds.height - 100)
        cardViewController.view.clipsToBounds = true
        cardViewController.handleArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:))))
    }

    @IBAction func openCard(_ sender: Any) {
        animateTransitionIfNeeded(state: nextState, duration: 0.4)
    }
    
    @objc
    func handlePanGesture(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            updateInteractiveTransition(fractionCompleted: 0)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = 100
                case .peek:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - 450
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.currentState = self.nextState
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                default:
                    break
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
        }
    }
}

