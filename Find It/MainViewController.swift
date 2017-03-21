//
//  MainViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK:- Class variables
    private var isSignUp:Bool?
    private var pageViewController: UIPageViewController?
    private var pageLabels = ["Page 1", "Page 2", "Page 3"]
    private var pageColors = [UIColor(red: 220.0/255.0, green: 198.0/255.0, blue: 224.0/255.0, alpha: 1.0),UIColor(red: 236.0/255.0, green: 100.0/255.0, blue: 75.0/255.0, alpha: 1.0),UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0)]
    private var backgroundImageNames = ["tutorial-image-0","tutorial-image-1","tutorial-image-2"]
    
    
    //Class IBOutlets
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    // MARK:- IB Actions
    @IBAction func signInButtonPressed(_ sender: Any) {
        isSignUp = false
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        isSignUp = true
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
    }
    
    // MARK:- Page View Controller Delegate Methods
    func setupPageViewController(){
        let startingViewController: TutorialViewController = self.viewController(at: 0)
        let viewControllers: [TutorialViewController] = [startingViewController]
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController?.dataSource = self
        self.pageViewController?.delegate = self
        self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: { _ in })
        self.pageViewController?.view.frame = self.view.frame
        
        self.view.addSubview((pageViewController?.view)!)
        self.view.sendSubview(toBack: (self.pageViewController?.view)!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        var index:Int = (viewController as? TutorialViewController)!.index!
        
        index -= 1
        guard index >= 0 else{
            return nil
        }
        
        return self.viewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        var index:Int = (viewController as? TutorialViewController)!.index!
        index += 1
        
        guard pageLabels.count != index else {
            return nil
        }
        
        return self.viewController(at: index)
    }
    
    func viewController(at index: Int) -> TutorialViewController {
        // Create a new view controller and pass suitable data.
        let tutorialViewController: TutorialViewController? = self.storyboard?.instantiateViewController(withIdentifier: "TutorialController") as! TutorialViewController?
        tutorialViewController?.backgroundImageName = self.backgroundImageNames[index]
        tutorialViewController?.descriptionText = self.pageLabels[index]
        tutorialViewController?.backgroundColor = self.pageColors[index]
        tutorialViewController?.index = index
        
        return tutorialViewController!
    }
    
    
    var pendingIndex = 0;
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageControl.currentPage = pendingIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let itemController = pendingViewControllers.first as! TutorialViewController
        pendingIndex = itemController.index!
        
    }
    
    
    // MARK:- Utilities for class
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        print("Hello")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AuthenticateSegue"{
            if let destinationViewController = segue.destination as? AuthenticateViewController{
                destinationViewController.isSignUp = self.isSignUp
            }
        }
    }
}
