//
//  CollectionViewManager.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 21/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

import Cocoa
import HyperCardCommon


class CollectionViewManager: NSObject, NSCollectionViewDataSource {
    
    private let collectionView: NSCollectionView
    
    private let browser: Browser
    
    private let thumbnailSize: Size
    
    private weak var document: Document!
    
    private var thumbnails: [CGImage?]
    
    private let renderingQueue: DispatchQueue
    
    private var renderingPriorities: [Int]
    
    private var currentPriority = 0
    
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
        let nib = NSNib(nibNamed: "CardItem", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: CollectionViewManager.itemIdentifier)
        collectionView.dataSource = self
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
        
        let item = self.collectionView.makeItem(withIdentifier: CollectionViewManager.itemIdentifier, for: indexPath)
        let view = item.view as! CardItemView
        
        /* Set-up the callback parameters */
        view.document = document
        view.index = indexPath.item
                
        if let image = thumbnails[indexPath.item] {
            view.displayImage(image)
        }
        else {
            view.displayImage(nil)
            
            /* Ask to draw the item. If the item is selected, make it draw first because
             it smoothes the animation when displaying the card list */
            currentPriority += 1
            self.renderingPriorities[indexPath.item] = currentPriority + (item.isSelected ? 10000 : 0)
            
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
                let thumbnail = slf.createThumbnail(from: slf.browser.cgimage)
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
        
        return item
    }
    
    private func createThumbnail(from image: CGImage) -> CGImage {
        
        let scale = Int(NSScreen.main()!.backingScaleFactor)
        let width = self.thumbnailSize.width * scale
        let height = self.thumbnailSize.height  * scale
        let data = RgbConverter.createRgbData(width: width, height: height)
        let context = RgbConverter.createContext(forRgbData: data, width: width, height: height)
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()!
    }
    
}
