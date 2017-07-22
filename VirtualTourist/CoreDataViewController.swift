//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Richard H on 15/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    
    var blockOperations: [BlockOperation] = []
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            fetchedResultsController?.delegate = self
            executeSearch()
            
            self.collectionView!.reloadData()
            
            
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>){
        fetchedResultsController = fc
        super.init(nibName:nil, bundle:nil)
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}

extension CoreDataViewController{
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Do Not Override here")
    }
}

extension CoreDataViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }

    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    //Mark: set the size of the cells depending on the width of the screen plus the margins
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let dimension = (self.view.frame.size.width - 6.0) / 3.0
        return CGSize(width: dimension, height: dimension)
    }
    
    //Mark: return minimum line spacing - called when layout is invalidated
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(3.0)
    }
    
    //Mark: return minimum interim spacing - called when layout is invalidated
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(3.0)
    }
    
}


extension CoreDataViewController{
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("There wa an error performing search: \(e)")
            }
        }
    }
}

extension CoreDataViewController: NSFetchedResultsControllerDelegate{
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView?.performBatchUpdates({ 
            for operation: BlockOperation in self.blockOperations{
                operation.start()
            }
        }, completion: { (finished) in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            self.collectionView?.insertSections(set)
        case .delete:
            self.collectionView?.deleteSections(set)
        default:
            // irrelevant in our case
            break
        }
        
    }
    

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            self.collectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView?.deleteItems(at: [indexPath!])
        case .update:
            self.collectionView?.reloadItems(at: [indexPath!])
        case .move:
            self.collectionView?.deleteItems(at: [indexPath!])
            self.collectionView?.insertItems(at: [newIndexPath!])
        }
    }
    
    
    
    
    
}

