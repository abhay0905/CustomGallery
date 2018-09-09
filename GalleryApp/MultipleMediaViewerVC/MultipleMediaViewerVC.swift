//
//  MultipleMediaViewerVC.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 08/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit
import Photos


class MultipleMediaViewerVC: UIViewController {

    @IBOutlet weak var colvwMedia: UICollectionView!
    var imageManager = PHCachingImageManager()
    var fetchResult : PHFetchResult<PHAsset>?
    var index : Int = 0
    lazy var thumbnailSize : CGSize = self.view.frame.size
    private var initialScrollingDone : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let indexPath = IndexPath(item: 12, section: 0)
        if !initialScrollingDone{
            initialScrollingDone = true
            colvwMedia.scrollToItem(at: IndexPath.init(row: index, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    // MARK: - Setup
    
    private func setupCollectionView(){
        colvwMedia.register(UINib(nibName: "ImageWithZoomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageWithZoomCollectionViewCell")
       
        colvwMedia.delegate = self
        colvwMedia.dataSource = self
        colvwMedia.prefetchDataSource = self
        self.navigationController?.isNavigationBarHidden = true

    }
    @IBAction func actionClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MultipleMediaViewerVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assets : [PHAsset] = []
        
        for indexPath in indexPaths{
            if let asset = fetchResult?.object(at: indexPath.item){
                assets.append(asset)
            }
        }
        let scale = UIScreen.main.scale
        
        let thumbSize = CGSize(width: thumbnailSize.width * scale, height: thumbnailSize.height * scale)
        imageManager.startCachingImages(for: assets,
                                        targetSize: thumbSize, contentMode: .aspectFill, options: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]){
        var removedAssets : [PHAsset] = []
        for indexPath in indexPaths{
            if let asset = fetchResult?.object(at: indexPath.item){
                removedAssets.append(asset)
            }
        }
        let scale = UIScreen.main.scale
        let thumbSize = CGSize(width: thumbnailSize.width * scale, height: thumbnailSize.height * scale)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbSize, contentMode: .aspectFill, options: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fet = fetchResult{
            return fet.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageWithZoomCollectionViewCell", for: indexPath) as! ImageWithZoomCollectionViewCell
        
        let index = indexPath.item
        cell.setupCell()
        if let asset = fetchResult?.object(at: index){
            cell.representedAssetIdentifier = asset.localIdentifier
            let scale = UIScreen.main.scale
            let thumbSize = CGSize(width: thumbnailSize.width * scale, height: thumbnailSize.height * scale)
            imageManager.requestImage(for: asset, targetSize:thumbSize , contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                    cell.imgvw.image = image
                    cell.setupCell()
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return thumbnailSize
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        if indexPath.row == 0{
        //            camera.startSession()
        //        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        if indexPath.row == 0{
        //            camera.stopSession()
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // Handler might not be called on the main queue, so re-dispatch for UI work.
            //                DispatchQueue.main.sync {
            //                    self.progressView.progress = Float(progress)
            //                }
            print(String(progress))
        }
        
        //            self.progressView.isHidden = false
        PHImageManager.default().requestImage(for: (fetchResult?.object(at: indexPath.row))!,
                                              targetSize: CGSize.init(width: 1920, height: 1080),
                                              contentMode: .aspectFit,
                                              options: options,
                                              resultHandler: { image, _ in
                                                // Hide the progress view now the request has completed.
                                                //                                                    self.progressView.isHidden = true
                                                //
                                                //                                                    // If successful, show the image view and display the image.
                                                //                                                    guard let image = image else { return }
                                                //
                                                //                                                    // Now that we have the image, show it.
                                                //                                                    self.imageView.isHidden = false
                                                //                                                    self.imageView.image = image
        })
        
    }
}

