//
//  MainRepository.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension ResourceRepository {
    
    /// The main resource repository, representing the resource forks of HyperCard and Mac OS.
    static let mainRepositories = buildMainRepositories()
}

private func buildMainRepositories() -> [ResourceRepository] {
    
    var repositories: [ResourceRepository] = []
    
    /* Add the icons */
    repositories.append(loadIcons())
    
    /* Add the fonts */
    repositories.append(contentsOf: loadClassicFontResources())
    
    return repositories
}

private func loadIcons() -> ResourceRepository {
    
    /* Create the repository */
    var icons = [Resource]()
    
    /* Add the icons */
    let iconIdentifiers = listIconIdentifiers()
    for iconIdentifier in iconIdentifiers {
        let icon = Resource(identifier: iconIdentifier, name: "", typeIdentifier: ResourceTypes.icon) { () -> Icon in
            return loadIcon(withIdentifier: iconIdentifier)
        }
        icons.append(icon)
    }
    
    return ResourceRepository(resources: icons)
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
    let iconIdentifiers = iconFileNames.compactMap({ (s: String) -> Int? in
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

private func loadIcon(withIdentifier identifier: Int) -> Icon {
    
    /* Load the icon */
    let iconName = IconFilePrefix + identifier.description
    if let maskedImage = MaskedImage(named: iconName) {
        if case MaskedImage.Layer.bitmap(let image, _, _) = maskedImage.image {
            return Icon(image: image)
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
    "New York",
    "Palatino",
    "San Francisco",
    "Symbol",
    "Times",
    "Venice",
    
    "Fonts"
]

private func loadClassicFontResources() -> [ResourceRepository] {
    
    return classicFontRepositoryNames.compactMap(loadClassicFontResources)
}

private func loadClassicFontResources(withName name: String) -> ResourceRepository? {
    
    /* Get the path to file */
    guard let path = HyperCardBundle.path(forResource: name, ofType: "dfont") else {
        return nil
    }
    
    /* Load the file */
    let file = ClassicFile(path: path)
    
    return ResourceRepository(loadFromData: file.dataFork!)
    
}


