//
//  ViewController.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 03/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var colvwImage: UICollectionView!
    fileprivate let imageManager = PHCachingImageManager()
    var fetchResult : PHFetchResult<PHAsset>?
    fileprivate var thumbnailSize: CGSize = CGSize.zero
    let camera = CameraManager.init()
    var cameraView : UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateItemSize()
        requestPermission()
//        requestCameraPermission()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup
    
    private func setupCollectionView(){
        colvwImage.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        colvwImage.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")
       
        colvwImage.delegate = self
        colvwImage.dataSource = self
        colvwImage.prefetchDataSource = self
    }
    
    fileprivate func updateCollectionView() {
        self.updateItemSize()
        self.setupCollectionView()
    }
    
    private func requestPermission(){
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                     self.updateCollectionView()
                }
//                print("Found \(allPhotos.count) assets")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            }
        }
    }
    
    private func requestCameraPermission(){
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {

                do{
                    try self.camera.initializeCamera()
                    DispatchQueue.main.async {
                        self.camera.previewLayer?.frame = CGRect.init(origin: CGPoint.zero, size: self.thumbnailSize)
                        self.cameraView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: self.thumbnailSize))
                        self.cameraView?.layer.addSublayer(self.camera.previewLayer!)
                        self.colvwImage.insertItems(at: [IndexPath.init(row: 0, section: 0)])
                    }
                   
                }catch let error{
                    
                }
            } else {
                
            }
        }
    }
    
    private func updateItemSize() {
        
        let viewWidth = UIScreen.main.bounds.width
        let itemWidth = viewWidth / 4.0
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        
        thumbnailSize = itemSize//CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
}
extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assets : [PHAsset] = []
        
        for indexPath in indexPaths{
            let index = indexPath.item - (cameraView != nil ? 1 : 0)
            if index < 0{
                continue
            }
             if let asset = fetchResult?.object(at: index){
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
            let index = indexPath.item - (cameraView != nil ? 1 : 0)
            if index < 0{
                continue
            }
            if let asset = fetchResult?.object(at: index){
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
            return fet.count + (cameraView != nil ? 1 : 0)
        }
        return  cameraView != nil ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 , let view = cameraView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
            cell.addSubview(view)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
            
            let index = indexPath.item - (cameraView != nil ? 1 : 0)
            
            if let asset = fetchResult?.object(at: index){
                cell.representedAssetIdentifier = asset.localIdentifier
                let scale = UIScreen.main.scale
                let thumbSize = CGSize(width: thumbnailSize.width * scale, height: thumbnailSize.height * scale)
                imageManager.requestImage(for: asset, targetSize:thumbSize , contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                    // The cell may have been recycled by the time this handler gets called;
                    // set the cell's thumbnail image only if it's still showing the same asset.
                    if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                        cell.imgPhoto.image = image
                    }
                })
            }
             return cell
        }
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
            let media = MultipleMediaViewerVC.init(nibName: "MultipleMediaViewerVC", bundle: nil)
        media.imageManager = imageManager
        media.fetchResult = fetchResult
        media.index = indexPath.item
        self.navigationController?.pushViewController(media, animated: true)
        
//            self.progressView.isHidden = false
//        PHImageManager.default().requestImage(for: (fetchResult?.object(at: indexPath.row))!,
//                                                  targetSize: CGSize.init(width: 1920, height: 1080),
//                                                  contentMode: .aspectFit,
//                                                  options: options,
//                                                  resultHandler: { image, _ in
//    
//            })
        
    }
}
