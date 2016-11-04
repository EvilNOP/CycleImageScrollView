//
//  CycleImageScrollView.swift
//  CycleImageScrollView
//
//  Created by Matthew on 16/11/1.
//  Copyright © 2016年 Matthew. All rights reserved.
//

import UIKit
import Alamofire

class CycleImageScrollView: UIView {

    // Constants
    private let padding: CGFloat = 8.0
    private let imageViewCount: Int = 3
    private let pageControlWidth: CGFloat = 45.0
    private let pageControlHeight: CGFloat = 37.0
    private let cycleImageScrollViewHeight: CGFloat = 180.0
    
    fileprivate let imageScrollView: UIScrollView
    fileprivate let pageControl: UIPageControl
    
    private var images: [UIImage] = []
    private var imageSwappingTimer: Timer?
    
    var pageControlIndicatorTintColor: UIColor? {
        get {
            return pageControl.pageIndicatorTintColor
        }
        
        set {
            pageControl.pageIndicatorTintColor = newValue
        }
    }
    
    var currentPageControlIndicatorTintColor: UIColor? {
        get {
            return pageControl.currentPageIndicatorTintColor
        }
        
        set {
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    
    var imageURLStrings: [String] {
        didSet {
            // Update the number of pages.
            pageControl.numberOfPages = imageURLStrings.count
            
            // Request the cover images at the moment the image urls being set.
            imageURLStrings.forEach {
                self.requestImage($0)
            }
        }
    }
    
    var autoScrollTimeInterval: TimeInterval
    
    // MARK: - Life Cycle
    init(){
        let screenWidth = UIScreen.main.bounds.width
        
        self.imageURLStrings = []
        self.imageSwappingTimer = nil
        self.autoScrollTimeInterval = 5.0
        
        // Create a scroll view which has a same bounds of super view.
        self.imageScrollView = UIScrollView(
            frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: cycleImageScrollViewHeight)
        )
        
        // Place the page control in the middle of loop image scroll view.
        self.pageControl = UIPageControl(
            frame: CGRect(
                x: screenWidth / 2.0 - pageControlWidth / 2.0,
                y: cycleImageScrollViewHeight - padding - pageControlHeight,
                width: pageControlWidth,
                height: pageControlHeight
            )
        )
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: cycleImageScrollViewHeight))
        
        configureImageScrollView()
        
        populateImageScrollViewWithImageViews(
            ofSize: CGSize(width: screenWidth, height: cycleImageScrollViewHeight)
        )
        
        configurePageControl()
    }
    
    override init(frame: CGRect) {
        self.imageURLStrings = []
        self.imageSwappingTimer = nil
        self.autoScrollTimeInterval = 5.0
        
        // Create a scroll view which has a same bounds of super view.
        self.imageScrollView = UIScrollView(
            frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        )
        
        // Place the page control in the middle of loop image scroll view.
        self.pageControl = UIPageControl(frame: CGRect(
            x: frame.width / 2.0 - pageControlWidth / 2.0,
            y: frame.height - padding - pageControlHeight,
            width: pageControlWidth,
            height: pageControlHeight)
        )
        
        super.init(frame: frame)
        
        configureImageScrollView()
        
        populateImageScrollViewWithImageViews(ofSize: frame.size)
        
        configurePageControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // After finishing layou subviews, update the images.
        // At the initial time, the image for the first image view to display is the last image, and the second image view will display the first image, so on.
        swapImages()
    }
    
    // MARK: - Private Methods
    private func configureImageScrollView() {
        // Disable both the horizontal and vertical scroll indicator.
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        
        imageScrollView.delegate = self
        
        // Paging.
        imageScrollView.isPagingEnabled = true
        
        // Important! Make sure to set up its content size.
        imageScrollView.contentSize = CGSize(
            width: frame.width * CGFloat(imageViewCount), height: frame.height
        )
        
        addSubview(imageScrollView)
    }
    
    private func populateImageScrollViewWithImageViews(ofSize size: CGSize) {
        for index in 0..<imageViewCount {
            let imageView = UIImageView(
                frame: CGRect(x: size.width * CGFloat(index), y: 0.0, width: size.width, height: size.height)
            )
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            self.imageScrollView.addSubview(imageView)
            
            // Constraint images view to stick within its super view.
            imageView.autoresizingMask = [
                UIViewAutoresizing.flexibleLeftMargin,
                UIViewAutoresizing.flexibleRightMargin,
                UIViewAutoresizing.flexibleTopMargin,
                UIViewAutoresizing.flexibleBottomMargin,
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            
            imageScrollView.addSubview(imageView)
        }
        
        // Constraint images scroll view to stick within its super view.
        imageScrollView.autoresizingMask = [
            UIViewAutoresizing.flexibleLeftMargin,
            UIViewAutoresizing.flexibleRightMargin,
            UIViewAutoresizing.flexibleTopMargin,
            UIViewAutoresizing.flexibleBottomMargin,
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
    }
    
    private func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 0
        
        pageControl.autoresizingMask = [
            UIViewAutoresizing.flexibleLeftMargin,
            UIViewAutoresizing.flexibleRightMargin,
            UIViewAutoresizing.flexibleTopMargin,
            UIViewAutoresizing.flexibleBottomMargin,
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        
        addSubview(pageControl)
    }
    
    @objc private func nextImage() {
        imageScrollView.setContentOffset(CGPoint(x: frame.width * 2.0, y: 0.0), animated: true)
    }
    
    private func requestImage(_ urlString: String) {
        Alamofire.request(urlString).responseData {
            dataResponse in
            
            // Try to load the image with the given data.
            if let data = dataResponse.result.value, let image = UIImage(data: data) {
                // Store the image.
                self.images.append(image)
                
                // Swap images if all the images were downloaded as well as fire the timer.
                if self.images.count == self.imageURLStrings.count {
                    self.swapImages()
                    
                    self.startTimer()
                }
            }
        }
    }
    
    fileprivate func startTimer() {
        imageSwappingTimer = Timer(
            timeInterval: autoScrollTimeInterval,
            target: self,
            selector: #selector(CycleImageScrollView.nextImage),
            userInfo: nil,
            repeats: true
        )
        
        RunLoop.main.add(imageSwappingTimer!, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func stopTimer() {
        imageSwappingTimer?.invalidate()
        imageSwappingTimer = nil
    }
    
    fileprivate func swapImages() {
        for index in 0..<imageScrollView.subviews.count {
            let imageView = imageScrollView.subviews[index] as! UIImageView
            
            // The page index will be updated to correct page index for each image view to display cycle images.
            var pageIndex = pageControl.currentPage
            
            if index == 0 {
                // This branch means the first image view should display the image of former page index.
                pageIndex -= 1
                
                // Special case 1, this means the current page index is 0, so the first image view should display the last image.
                if pageIndex < 0 {
                    pageIndex = pageControl.numberOfPages - 1
                }
            } else if index == 2 {
                // This branch means the last image view should display the image of latter page index.
                pageIndex += 1
                
                // Special case 2, this means the current page index is 2, so the last image view should display the first image.
                if pageIndex >= pageControl.numberOfPages {
                    pageIndex = 0
                }
            }
            
            // After updating each page index, update the image view's image.
            if pageIndex < images.count {
                // This tag value will be used to calculate the current page of the page control.
                imageView.tag = pageIndex
                imageView.image = images[pageIndex]
            }
        }
        
        // Reset the content offet to the second image view to implement infinite cycle scroll view.
        imageScrollView.contentOffset = CGPoint(x: frame.width, y: 0.0)
    }
}

// MARK: - Scroll View Delegate
extension CycleImageScrollView: UIScrollViewDelegate {
    
    // Calculate the current page of page control.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Page index is used to update the current page of page control.
        var pageIndex = 0
        
        // Calculate the minimum distance to figure out which image view is most close to the origin x of image scroll view's content offset.
        // First make it bigger enough.
        var minimumDistance = CGFloat.greatestFiniteMagnitude
        
        for index in 0..<imageScrollView.subviews.count {
            // Extract the subview and downcast to image view.
            let imageView = imageScrollView.subviews[index] as! UIImageView
            
            // Calculate the distance.
            let distance: CGFloat = abs(imageView.frame.origin.x - imageScrollView.contentOffset.x)
            
            // Update the minimum distance and page index.
            if distance < minimumDistance {
                minimumDistance = distance
                
                // The tag value value stands for the index of the image that the image view display.
                pageIndex = imageView.tag
            }
        }
        
        // Finally, update the current page of page control.
        pageControl.currentPage = pageIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update images when the scroll view has ended decelerating the scrolling movement.
        swapImages()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        swapImages()
    }
}
