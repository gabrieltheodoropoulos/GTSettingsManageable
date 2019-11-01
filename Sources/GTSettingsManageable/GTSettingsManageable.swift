//
//  GTSettingsManageable.swift
//
//
//  Created by Gabriel Theodoropoulos.
//  https://gtiapps.com
//
//  Provided under the [MIT license](https://opensource.org/licenses/MIT)
//

import Foundation

/**
 Handle in-app settings and configuration by using provided methods
 to load, update, delete and perform other operations on them.
 
 Original settings should exist as a property list file in the app bundle,
 otherwise the adopting type's properties should come with initial, default values.
 
 Settings file is stored in the Caches directory of the app and it's a *property list (plist)*
 file.
 
 - Note: More than one settings files can co-exist to an app. See the `settingsURL()` method
 for more information about *naming*.
 
 - Precondition: The adopting custom type **must conform to** `Codable` protocol.
 
 ### Available API
 
 ```
 - load()
 - loadUsingSettingsFile()
 - update()
 - delete()
 - reset()
 - settingsURL()
 - toDictionary()
 - describeSettings()
 ```
 
 Read the documentation of each method for more information and details.
 
 */
public protocol GTSettingsManageable {
    func settingsURL() -> URL
    func update() -> Bool
    mutating func load() -> Bool
    mutating func loadUsingSettingsFile() -> Bool
    func delete() -> Bool
    mutating func reset() -> Bool
    func toDictionary() -> [String: Any?]?
    func describeSettings()
}


extension GTSettingsManageable where Self: Codable {
    /**
     It specifies and returns the URL to the settings file in
     the Caches directory of the app.
     
     The name of the custom type adopting this protocol is used
     as the name for the file created in the Caches directory. The file
     that will be created is a *property list (plist)* file.
     
     - Returns: The URL of the settings file to the Caches directory.
     */
    public func settingsURL() -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent("\(Self.self).plist")
    }
    
    
    /**
     It encodes the custom type adopting the GTSettingsManageable protocol
     as a property list object and writes it to the file in the Caches director.
     
     - Returns: `true` if writing to file succeeds, `false` otherwise.
     */
    public func update() -> Bool {
        do {
            let encoded = try PropertyListEncoder().encode(self)
            try encoded.write(to: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    /**
     It loads setting values from the settings file in the Caches directory.
     
     If the settings file exists in the Caches directory, it reads its contents
     and decodes the property list data to the custom type that adopts GTSettingsManageable.
     
     If the settings file doesn't exist in the Caches directory because it
     hasn't been created yet or it has been manually deleted, then it uses the
     `update()` method to create it. It also uses an internal method called
     `backupSettingsFile()` to keep a backup of the original settings.
     
     - Returns: `true` if loading the settings file succeeds (or writing it for first
     time to the Caches directory), `false` otherwise.
     */
    public mutating func load() -> Bool {
        if FileManager.default.fileExists(atPath: settingsURL().path) {
            do {
                let fileContents = try Data(contentsOf: settingsURL())
                self = try PropertyListDecoder().decode(Self.self, from: fileContents)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            if update() {
                backupSettingsFile()
                return true
            } else { return false }
        }
    }
    
    
    /**
     It copies a source settings file from the app bundle to the Caches directory
     and then it loads it by opening and decoding it.
     
     The source settings file is copied to the Caches directory if only it hasn't
     been copied already. Also, since the original file exists in the app bundle,
     no backup of the settings file is kept like it happens in the `load()` method.
     
     - Returns: `true` if copying (if necessary) and decoding the property list settings succeeds,
     `false` otherwise.
     */
    public mutating func loadUsingSettingsFile() -> Bool {
        guard let originalSettingsURL = Bundle.main.url(forResource: "\(Self.self)", withExtension: "plist")
            else { return false }
        
        do {
            if !FileManager.default.fileExists(atPath: settingsURL().path) {
                try FileManager.default.copyItem(at: originalSettingsURL, to: settingsURL())
            }
            
            let fileContents = try Data(contentsOf: settingsURL())
            self = try PropertyListDecoder().decode(Self.self, from: fileContents)
            return true
            
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    /**
     It deletes the settings file from the Caches directory.
     
     - Returns: `true` on success, `false` otherwise.
     */
    public func delete() -> Bool {
        do {
            try FileManager.default.removeItem(at: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    /**
     It resets the settings by deleting the settings file and reloading
     the original ones.
     
     At first the method tries to load the original settings from the app bundle.
     (see `loadUsingSettingsFile()`). If there's no settings file there,
     it tries to restore initial settings that were previously backed up while using
     the `load()` method.
     
     Restoring previous backup takes place in an internal method called `restoreSettingsFile()`.
     
     - Returns: `true` on success, `false` otherwise.
     */
    public mutating func reset() -> Bool {
        if delete() {
            if !loadUsingSettingsFile() {
                if restoreSettingsFile() {
                    return load()
                }
            } else {
                return true
            }
        }
        return false
    }
    
    
    /**
     It loads and returns settings from the settings file as a dictionary.
     
     - Returns: A `[String: Any]` dictionary if loading settings succeeds, `nil` otherwise.
     */
    public func toDictionary() -> [String: Any?]? {
        do {
            if FileManager.default.fileExists(atPath: settingsURL().path) {
                let fileContents = try Data(contentsOf: settingsURL())
                let dictionary = try PropertyListSerialization.propertyList(from: fileContents, options: .mutableContainersAndLeaves, format: nil) as? [String: Any?]
                return dictionary
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    
    /**
     An auxiliary method that prints settings on the console.
     */
    public func describeSettings() {
        let mirror = Mirror(reflecting: self)
        var output = ""
        
        mirror.children.forEach { (child) in
            if let label = child.label {
                output += "Setting: \"\(label)\""
            } else {
                output += "Setting: ---"
            }
            
            output += ", Value: \(child.value)\n"
        }
        
        print(output)
    }
    
    
    /**
     It creates a copy of the original settings. The copy has the "init" extension.
     */
    internal func backupSettingsFile() {
        do {
            try FileManager.default.copyItem(at: settingsURL(), to: settingsURL().appendingPathExtension("init"))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    /**
     It restores a settings backup file by copying the "init" file to the settings
     property list file.
     
     - Returns: `true` if the initial settings file exists and copying it succeeds, `false`
     otherwise.
     */
    internal func restoreSettingsFile() -> Bool {
        do {
            try FileManager.default.copyItem(at: settingsURL().appendingPathExtension("init"), to: settingsURL())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
