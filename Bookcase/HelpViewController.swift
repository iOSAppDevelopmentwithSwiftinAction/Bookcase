//
//  HelpViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
let appBlue = UIColor(red: 52/255, green: 170/255, blue: 220/255, alpha: 1)
class HelpViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [HelpPage1ViewController(),
                HelpPage2ViewController(),
                HelpPage3ViewController()]
    }()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = appBlue
        self.delegate = self
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        if !UserDefaults.standard.bool(forKey: beenHereBefore) {
            doneButton.title = "Skip"
            UserDefaults.standard.set(true, forKey: beenHereBefore)
        }
    }
    @IBAction func hitDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {return nil}
        let previousIndex = viewControllerIndex - 1
        if previousIndex < 0 {return nil}
        return orderedViewControllers[previousIndex]
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {return nil}
        let nextIndex = viewControllerIndex + 1
        if nextIndex >= orderedViewControllers.count {return nil}
        return orderedViewControllers[nextIndex]
    }
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
