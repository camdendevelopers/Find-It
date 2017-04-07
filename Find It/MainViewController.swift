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
    private var currentIndex = 0
    private var pageViewController:UIPageViewController?
    private var pageTitles:[String] = [titleText0, titleText1, titleText2, titleText3]
    private var pageColors:[UIColor] = [kColor4990E2,kColorFF7D7D,kColorE3CC00,kColor4990E2]
    private var pageDescriptions:[String] = [descriptionText0, descriptionText1, descriptionText2, descriptionText3]
    private var backgroundImageNames:[String] = ["tutorial-icon-0","tutorial-icon-1","tutorial-icon-2","tutorial-icon-3"]
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTutorialViewController(0),
                self.newTutorialViewController(1),
                self.newTutorialViewController(2),
                self.newTutorialViewController(3)]
    }()
 
    
    //Class IBOutlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup up page view controller
        setupPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
        
        // 2. Change button depending on user signup/signin
        setupButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 1. Change status bar color back to white when moving away from screen
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK:- IB Actions
    @IBAction func signInButtonPressed(_ sender: Any) {
        // 1. Change flag since user is signing in
        self.isSignUp = false
        
        // 2. Move to next screen
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        // 1. Change flag since user is signing up
        self.isSignUp = true
        
        // 2. Move to next screen
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
    }
    
    // MARK:- Page View Controller Delegate Methods
    func setupPageViewController(){
        
        // 1. Assign first view controller
        if let firstViewController = orderedViewControllers.first {
            // 2. Set the page indicator to display the current index at 0
            self.pageControl.currentPage = self.currentIndex
            self.pageControl.currentPageIndicatorTintColor = self.pageColors[self.currentIndex]
            
            // 3. Initialize new page view controller
            self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
            self.pageViewController?.delegate = self
            self.pageViewController?.dataSource = self
            self.pageViewController?.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            self.pageViewController?.view.frame = self.view.frame
            
            // 4. Add it to the current view but send behind button
            self.view.addSubview((self.pageViewController?.view)!)
            self.view.sendSubview(toBack: (self.pageViewController?.view)!)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        // 1. Check if there are any more view controllers to display
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        // 2. If yes, decrease the index by one
        let previousIndex = viewControllerIndex - 1
 
        // 3. Make sure you are not at the first screen
        guard previousIndex >= 0 else {
            return nil
        }
        
        // 4. Return the view controller to display
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        // 1. Check if there are any more view controllers to display
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        // 2. If yes, increase the index by one
        let nextIndex = viewControllerIndex + 1

        // 3. Make sure you are not at the first screen
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        
        // 4. Return the view controller to display
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 1. Check if screen has finished transition from one view to next
        if completed {
            
            // 2. If yes, update the page control current indicator to change to index
            self.pageControl.currentPage = self.currentIndex
            self.pageControl.currentPageIndicatorTintColor = self.pageColors[self.currentIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        // 1. Update the current index to the view controller index user will transition to
        let itemController = pendingViewControllers.first as! TutorialViewController
        self.currentIndex = itemController.index!
    }
 
    
    fileprivate func newTutorialViewController(_ index: Int) -> UIViewController {
        
        // 1. Create a new tutorial view controller screen
        let tutorialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialController") as! TutorialViewController
        
        // 2. Update its properties
        tutorialViewController.backgroundImageName = self.backgroundImageNames[index]
        tutorialViewController.descriptionText = self.pageDescriptions[index]
        tutorialViewController.titleText = self.pageTitles[index]
        tutorialViewController.backgroundColor = self.pageColors[index]
        tutorialViewController.index = index
        
        // 3. Return tutorial screen
        return tutorialViewController
    }
    
    // MARK:- Utilities for class
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    func setupButton(){
        
        // 1. Add a radius to button to make it round
        self.signInButton.layer.cornerRadius = self.signInButton.frame.size.height / 2
        self.signInButton.clipsToBounds = true
        self.signInButton.layer.masksToBounds = true
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
