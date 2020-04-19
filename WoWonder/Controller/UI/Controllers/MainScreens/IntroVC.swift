//
//  IntroVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 23/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WowonderMessengerSDK

class IntroVC: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var scrollNextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
        {
        didSet{
            scrollView.delegate = self
        }
    }
    
    var slides:[IntroItem] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setepUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    func setepUI(){
        self.skipBtn.setTitle(NSLocalizedString("SKIP", comment: ""), for: .normal)
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        
    }
    
  
    @IBAction func skipPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserSuggestionVC") as? UserSuggestionVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func moveToNextPressed(_ sender: Any) {
        if scrollNextBtn.titleLabel?.text == NSLocalizedString("Done", comment: ""){
            let vc = R.storyboard.dashboard.dashboard()
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)
        }else{
           scrollToNextSlide()
            
        }
        
        
    }
    private func createSlides() -> [IntroItem] {
        
        let slide1:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide1.imageLabel.image = UIImage(named: "ic_rocket")
        slide1.firstLabel.text = NSLocalizedString("New Version", comment: "")
        slide1.secondLabel.text =  NSLocalizedString("Fast so we can take you to our space", comment: "")
        slide1.backgroundColor = UIColor.hexStringToUIColor(hex: "2C4154")
        
        let slide2:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide2.imageLabel.image = UIImage(named: "ic_magnifying_glass")
        slide2.firstLabel.text = NSLocalizedString("Search Globally", comment: "")
        slide2.secondLabel.text = NSLocalizedString("Find new friends and contacts", comment: "")
        slide2.backgroundColor = UIColor.hexStringToUIColor(hex: "FCB741")
        let slide3:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide3.imageLabel.image = UIImage(named: "ic_paper_plane")
        slide3.firstLabel.text = NSLocalizedString("New Features", comment: "")
        slide3.secondLabel.text = NSLocalizedString("Send & Recieve all kind of messages", comment: "")
        slide3.backgroundColor = UIColor.hexStringToUIColor(hex: "2385C2")
        
        let slide4:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide4.imageLabel.image = UIImage(named: "ic_chat_violet")
        slide4.firstLabel.text = NSLocalizedString("Stay Sync", comment: "")
        slide4.secondLabel.text = NSLocalizedString("Keep you conversation going from all devices", comment: "")
        slide4.backgroundColor = UIColor.hexStringToUIColor(hex: "8E43AC")
        
        return [slide1, slide2, slide3, slide4]
    }
    private func setupSlideScrollView(slides : [IntroItem]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
            
        }
    }
    func scrollToNextSlide(){
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = scrollView.contentOffset;
        
        scrollView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true);
        
        
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        if pageControl.currentPage == 3 {
            self.skipBtn.isHidden = true
            self.scrollNextBtn.setImage(nil, for: .normal)
            self.scrollNextBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        }else {
            self.skipBtn.isHidden = false
            self.scrollNextBtn.setImage(UIImage(named: "ic_intro_forwardarrow"), for: .normal)
            self.scrollNextBtn.setTitle(nil, for: .normal)
        }
        
    }
    
    
    
    
    func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
        if(pageControl.currentPage == 0) {
            //Change background color to toRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1
            //Change pageControl selected color to toRed: 103/255, toGreen: 58/255, toBlue: 183/255, fromAlpha: 0.2
            //Change pageControl unselected color to toRed: 255/255, toGreen: 255/255, toBlue: 255/255, fromAlpha: 1
            
            let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.pageIndicatorTintColor = pageUnselectedColor
            
            
            let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            slides[pageControl.currentPage].backgroundColor = bgColor
            
            let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.currentPageIndicatorTintColor = pageSelectedColor
        }
    }
    
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
