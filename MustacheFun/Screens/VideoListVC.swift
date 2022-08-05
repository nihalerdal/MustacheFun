//
//  VideoListVC.swift
//  MustacheFun
//
//  Created by Nihal Erdal on 8/3/22.
//

import UIKit
import CoreData

class VideoListVC: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController : DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Video>!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        setupFetchedResultsController()
      
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    fileprivate func setupFetchedResultsController() {
        //creat fetchRequest
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch couldn't be performed: \(error.localizedDescription)")
        }
    }

}
