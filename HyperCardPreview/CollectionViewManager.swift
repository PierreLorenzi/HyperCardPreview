//
//  CollectionViewManager.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 21/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


class CollectionViewManager: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    private let collectionView: NSCollectionView
    
    private let browser: Browser
    
    private let thumbnailSize: Size
    
    private weak var document: Document!
    
    var thumbnails: [CGImage?]
    
    private let renderingQueue: DispatchQueue
    
    private var renderingPriorities: [Int]
    
    private var currentPriority = 0
    
    var selectedIndex = -1
    
    private static let itemIdentifier = "item"
    
    init(collectionView: NSCollectionView, stack: Stack, document: Document) {
        self.collectionView = collectionView
        self.browser = Browser(stack: stack)
        self.thumbnailSize = CollectionViewManager.computeThumbnailSize(cardWidth: browser.image.width, cardHeight: browser.image.height, thumbnailSize: (collectionView.collectionViewLayout! as! NSCollectionViewFlowLayout).itemSize)
        self.document = document
        self.thumbnails = [CGImage?](repeating: nil, count: stack.cards.count)
        self.renderingQueue = DispatchQueue(label: "CollectionViewManager Rendering Queue")
        self.renderingPriorities = [Int](repeating: 0, count: stack.cards.count)
        
        super.init()
        
        /* Register as data source */
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "CardItem"), bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: CollectionViewManager.itemIdentifier))
        collectionView.dataSource = self
        collectionView.delegate = self
        
        /* When the collection view scrolls, update the thumbnail priorities */
        collectionView.postsBoundsChangedNotifications = true
        var observerToRemove: NSObjectProtocol? = nil
        let observer = NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: collectionView.superview!, queue: nil, using: { [weak self] _ in
            
            guard let slf = self else {
                if let observer = observerToRemove {
                    NotificationCenter.default.removeObserver(observer)
                }
                return
            }
            
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems()
            for path in visibleIndexPaths {
                if slf.renderingPriorities[path.item] != 0 {
                    slf.currentPriority += 1
                    slf.renderingPriorities[path.item] = slf.currentPriority + (collectionView.frameForItem(at: path.item).intersects(collectionView.visibleRect) ? 10000 : 0)
                }
            }
        })
        observerToRemove = observer
    }
    
    private static func computeThumbnailSize(cardWidth: Int, cardHeight: Int, thumbnailSize: NSSize) -> Size {
        
        /* Find the scale that makes the image fit both vertically and horizontally */
        let scaleX = (thumbnailSize.width - 2.0 * CardItemView.selectionMargin) / CGFloat(cardWidth)
        let scaleY = (thumbnailSize.height - 2.0 * CardItemView.selectionMargin) / CGFloat(cardHeight)
        let scale = min(scaleX, scaleY)
        
        /* Scale the stack size */
        return Size(width: Int(round(CGFloat(cardWidth) * scale)), height: Int(round(CGFloat(cardHeight) * scale)))
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return browser.stack.cards.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = self.collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CollectionViewManager.itemIdentifier), for: indexPath)
        let view = item.view as! CardItemView
        
        /* Set-up the callback parameters */
        view.document = document
        view.index = indexPath.item
        let cardName = self.browser.stack.cards[indexPath.item].name
        view.title = "\(cardName != "" ? cardName.description : "\(indexPath.item + 1)")"
                
        if let image = thumbnails[indexPath.item] {
            view.displayImage(image)
        }
        else {
            view.displayLoadingThumbnail(forCardWidth: browser.image.width, height: browser.image.height)
            
            /* Ask to draw the item. If the item is selected, make it draw first because
             it smoothes the animation when displaying the card list */
            currentPriority += 1
            self.renderingPriorities[indexPath.item] = currentPriority + (item.isSelected ? 100000 : 0)
            
            self.renderingQueue.async {
                [weak self] in
                
                /* Ensure the document is still around */
                guard let slf = self else {
                    return
                }
                
                let cardIndex = slf.renderingPriorities.lazy.enumerated().max(by: { (x0: (Int, Int), x1: (Int, Int)) -> Bool in
                    return x0.1 < x1.1
                })!.0
                
                slf.browser.cardIndex = cardIndex
                slf.browser.refresh()
                let thumbnail = slf.createThumbnail(from: slf.browser.buildImage())
                slf.thumbnails[cardIndex] = thumbnail
                let indexPathUpdated = IndexPath(item: cardIndex, section: 0)
                let indexSet = Set<IndexPath>([indexPathUpdated])
                
                slf.renderingPriorities[cardIndex] = 0
                
                DispatchQueue.main.async {
                    [weak self] in
                    
                    /* Ensure the document is still around */
                    guard let slf = self else {
                        return
                    }
                    
                    slf.collectionView.reloadItems(at: indexSet)
                }
            }
        }
        
        /* Check selection because when the items are reloaded, the selection is lost. */
        if collectionView.selectionIndexPaths.count == 0 {
            collectionView.selectionIndexPaths = Set<IndexPath>(arrayLiteral: IndexPath(item: self.selectedIndex, section: 0))
        }
        if indexPath.item == self.selectedIndex && !item.isSelected {
            item.isSelected = true
        }
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        selectedIndex = indexPaths.first!.item
    }
    
    private func createThumbnail(from image: CGImage) -> CGImage {
        
        let scale = Int(NSScreen.main!.backingScaleFactor)
        let width = self.thumbnailSize.width * scale
        let height = self.thumbnailSize.height  * scale
        let data = RgbConverter.createRgbData(width: width, height: height)
        let context = RgbConverter.createContext(forRgbData: data, width: width, height: height)
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()!
    }
    
}
