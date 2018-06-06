//
//  MainRepository.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 05/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension ResourceRepository {
    
    /// The repository representing the resource forks of HyperCard and Mac OS.
    public static let mainRepository = buildMainRepository()
}


private extension ResourceRepository {
    
    mutating func append(_ repository: ResourceRepository) {
        self.icons.append(contentsOf: repository.icons)
        self.fontFamilies.append(contentsOf: repository.fontFamilies)
        self.cardColors.append(contentsOf: repository.cardColors)
        self.backgroundColors.append(contentsOf: repository.backgroundColors)
        self.pictures.append(contentsOf: repository.pictures)
    }
    
}

private func buildMainRepository() -> ResourceRepository {
    
    var repository = ResourceRepository(icons: [], fontFamilies: [], cardColors: [], backgroundColors: [], pictures: [])
    
    /* Add the icons */
    let icons = loadIcons()
    repository.append(icons)
    
    /* Add the fonts */
    let fonts = loadClassicFontResources()
    repository.append(fonts)
    
    return repository
}

private func loadIcons() -> ResourceRepository {
    
    /* Create the repository */
    var icons = [IconResource]()
    
    /* Add the icons */
    let iconIdentifiers = listIconIdentifiers()
    for iconIdentifier in iconIdentifiers {
        let contentProperty = Property<Icon> { () -> Icon in
            return loadIcon(withIdentifier: iconIdentifier)
        }
        let icon = IconResource(identifier: iconIdentifier, name: "", contentProperty: contentProperty)
        icons.append(icon)
    }
    
    return ResourceRepository(icons: icons, fontFamilies: [], cardColors: [], backgroundColors: [], pictures: [])
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

private func loadClassicFontResources() -> ResourceRepository {
    
    var fontRepository = ResourceRepository(icons: [], fontFamilies: [], cardColors: [], backgroundColors: [], pictures: [])
    let repositories = classicFontRepositoryNames.compactMap(loadClassicFontResources)
    
    for repository in repositories {
        fontRepository.append(repository)
    }
    
    return fontRepository
}

private func loadClassicFontResources(withName name: String) -> ResourceRepository? {
    
    /* Get the path to file */
    guard let path = HyperCardBundle.path(forResource: name, ofType: "dfont") else {
        return nil
    }
    
    /* Load the file */
    let file = ClassicFile(path: path)
    
    return ResourceRepository(fromResourceFork: file.dataFork!)
    
}


