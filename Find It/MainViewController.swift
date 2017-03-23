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
    //private var pageLabels = ["Page 1", "Page 2", "Page 3"]
    private var pageTitles = [titleText0, titleText1, titleText2, titleText3]
    private var pageDescriptions = [descriptionText0, descriptionText1, descriptionText2, descriptionText3]
    private var pageColors = [kColor4990E2,kColorFF7D7D,kColorE3CC00,kColor4990E2]
    private var backgroundImageNames = ["tutorial-icon-0","tutorial-icon-1","tutorial-icon-2","tutorial-icon-3"]
    
    
    //Class IBOutlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        setupButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
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
        
        guard pageTitles.count != index else {
            return nil
        }
        
        return self.viewController(at: index)
    }
    
    func viewController(at index: Int) -> TutorialViewController {
        // Create a new view controller and pass suitable data.
        let tutorialViewController: TutorialViewController? = self.storyboard?.instantiateViewController(withIdentifier: "TutorialController") as! TutorialViewController?
        tutorialViewController?.backgroundImageName = self.backgroundImageNames[index]
        tutorialViewController?.descriptionText = self.pageDescriptions[index]
        tutorialViewController?.titleText = self.pageTitles[index]
        tutorialViewController?.backgroundColor = self.pageColors[index]
        tutorialViewController?.index = index
        
        return tutorialViewController!
    }
    
    
    var pendingIndex = 0;
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageControl.currentPage = pendingIndex
            //CHECK HERE
            pageControl.currentPageIndicatorTintColor = pageColors[pendingIndex]
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
    
    func setupButton(){
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
