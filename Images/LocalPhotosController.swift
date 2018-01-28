//
//  LocalPhotosController.swift
//  Images
//
//  Created by Bondar Yaroslav on 28/01/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class LocalPhotosController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var photoManager = PhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoManager.requestPhotoAccess { status in
            switch status {
            case .authorized:
                self.photoManager.resetCachedAssets()
                self.photoManager.delegate = self
                self.photoManager.prepereForUse()
                self.collectionView.reloadData()
            case .denied:
                presentSettingsAlert(in: self)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoManager.updateCachedAssetsFor(view: view, collectionView: collectionView)
    }
    
    /// View controller-based status bar appearance
    override var prefersStatusBarHidden: Bool { return true }
    
    /// Determine the size of the thumbnails to request from the PHCachingImageManager
    private func updateItemSize() {
        let size = itemSize(for: collectionView)
        let scale = UIScreen.main.scale
        photoManager.photoSize = CGSize(width: size.width * scale, height: size.height * scale)
    }
}

extension LocalPhotosController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetch = photoManager.fetchResult else {
            return 0
        }
        return fetch.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PhotoCell.self, for: indexPath)
        photoManager.fill(cell: cell, for: indexPath)
        return cell
    }
}
extension LocalPhotosController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
extension LocalPhotosController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        photoManager.updateCachedAssetsFor(view: view, collectionView: collectionView)
    }
}

extension LocalPhotosController: PhotoManagerColectionViewDelegate { }
