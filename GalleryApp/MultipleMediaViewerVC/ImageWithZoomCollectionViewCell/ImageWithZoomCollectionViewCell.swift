//
//  ImageWithZoomCollectionViewCell.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 08/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit

class ImageWithZoomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollvw: UIScrollView!
    @IBOutlet weak var imgvw: UIImageView!
    var representedAssetIdentifier : String?
    var tapGesture : UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(){
        
        scrollvw.maximumZoomScale = 5
        scrollvw.minimumZoomScale = 1
        scrollvw.delegate = self
        
        tapGesture = UITapGestureRecognizer.init()
        tapGesture?.numberOfTapsRequired = 2
        tapGesture?.addTarget(self, action: #selector(handleDoubleTap))
        scrollvw.addGestureRecognizer(tapGesture!)
    }
    
    @objc private func handleDoubleTap(recognizer:UITapGestureRecognizer){
        if scrollvw.zoomScale == 1.0{
            scrollvw.zoom(to: zoomRectForScale(scale: 5.0, center: recognizer.location(in: scrollvw)), animated: true)
        }else{
            scrollvw.setZoomScale(1.0, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgvw.frame.size.height / scale
        zoomRect.size.width  = imgvw.frame.size.width  / scale
        let newCenter = scrollvw.convert(center, from: imgvw)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}

extension ImageWithZoomCollectionViewCell : UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgvw
    }
}
