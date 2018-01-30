//
//  PhotoManagerDelegate.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 11/11/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Photos

protocol PhotoManagerDelegate: class {
    func photoLibraryDidChange(with changes: PHFetchResultChangeDetails<PHAsset>)
}

protocol PhotoManagerColectionViewDelegate: PhotoManagerDelegate {
    var collectionView: UICollectionView! { get }
}

extension PhotoManagerDelegate where Self: PhotoManagerColectionViewDelegate {
    func photoLibraryDidChange(with changes: PHFetchResultChangeDetails<PHAsset>) {
        if changes.hasIncrementalChanges {
            // If we have incremental diffs, animate them in the collection view.
            collectionView.performBatchUpdates({
                // For indexes to make sense, updates must be in this order:
                // delete, insert, reload, move
                if let removed = changes.removedIndexes, !removed.isEmpty {
                    collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                }
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                }
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
                changes.enumerateMoves { fromIndex, toIndex in
                    self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                 to: IndexPath(item: toIndex, section: 0))
                }
            })
        } else {
            //Reload the collection view if incremental diffs are not available.
            collectionView.reloadData()
        }
    }
}

