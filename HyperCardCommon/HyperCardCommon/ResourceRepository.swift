//
//  ResourceRepository.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



public struct ResourceRepository {
    
    /* The Resource<> objects have not common superclass, so no type can be given to the array   */
    public var resources: [Any]    = []
    
    public static let mainRepository = buildMainRepository()
    
}

private func buildMainRepository() -> ResourceRepository {
    
    var repository = ResourceRepository()
    
    /* Add the icons */
    let icons = loadIcons()
    repository.resources.append(contentsOf: icons)
    
    /* Add the fonts */
    let fonts = loadClassicFontResources()
    repository.resources.append(contentsOf: fonts)
    
    return repository
}

private func loadIcons() -> [Any] {
    
    /* Create the repository */
    var icons = [Any]()
    
    /* Add the icons */
    let iconIdentifiers = listIconIdentifiers()
    for iconIdentifier in iconIdentifiers {
        let icon = AppResourceIcon(identifier: iconIdentifier)
        icons.append(icon)
    }
    
    return icons
}

private class AppResourceIcon: Resource<Image> {
    // TODO no name for the icons?
    
    private static let fakeImage = Image(width: 0, height: 0)
    
    public init(identifier: Int) {
        super.init(identifier: identifier, name: "", type: ResourceTypes.icon, content: AppResourceIcon.fakeImage)
    }
    
    private var contentLoaded = false
    override public var content: Image {
        get {
            if !contentLoaded {
                super.content = loadIcon(withIdentifier: identifier)
                contentLoaded = true
            }
            return super.content
        }
        set {
            super.content = newValue
        }
    }
    
}

private let IconFilePrefix = "icon_"
private let IconPath = "Icons"

private func listIconIdentifiers() -> [Int] {
    
    /* Get the path of the icon directory */
    guard let resourcePath = HyperCardBundle.resourcePath else {
        return []
    }
    
    /* Load the file names */
    guard let fileNames = try? FileManager.`default`.contentsOfDirectory(atPath: resourcePath) else {
        return []
    }
    
    /* Find the icon identifiers */
    let iconFileNames = fileNames.filter({$0.hasPrefix(IconFilePrefix)})
    let iconIdentifiers = iconFileNames.flatMap({ (s: String) -> Int? in
        let scanner = Scanner(string: s)
        guard scanner.scanString(IconFilePrefix, into: nil) else {
            return nil
        }
        var result: Int32 = 0
        guard scanner.scanInt32(&result) else {
            print(s)
            return nil
        }
        return Int(result)
    })
    
    return iconIdentifiers
}

private func loadIcon(withIdentifier identifier: Int) -> Image {
    
    /* Load the icon */
    let iconName = IconFilePrefix + identifier.description
    if let maskedImage = MaskedImage(named: iconName) {
        if case MaskedImage.Layer.bitmap(let image, _, _) = maskedImage.image {
            return image
        }
    }
    fatalError("loadIcon: can't find icon with identifier \(identifier)")
}

private let classicFontRepositoryNames: [String] = [
    "Athens",
    "Cairo",
    "Charcoal",
    "Chicago",
    "Courier",
    "Geneva",
    "Helvetica",
    "London",
    "Los Angeles",
    "Monaco",
    "Palatino",
    "San Francisco",
    "Symbol",
    "Times",
    "Venice",
    
    "Fonts"
]

private func loadClassicFontResources() -> [Any] {
    
    return classicFontRepositoryNames.flatMap(loadClassicFontResources).reduce([], { (a: [Any], b: [Any]) in a+b })
    
}

private func loadClassicFontResources(withName name: String) -> [Any]? {
    
    /* Get the path to file */
    guard let path = HyperCardBundle.path(forResource: name, ofType: "dfont") else {
        return nil
    }
    
    /* Load the file */
    let file = ClassicFile(path: path, loadResourcesFromDataFork: true)
    
    return file.resourceRepository?.resources
    
}


