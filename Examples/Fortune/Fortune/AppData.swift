//
//  AppData.swift
//  Fortune
//
//  Created by Edward Smith on 10/4/17.
//  Copyright © 2017 Branch. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let AppDataDidUpdate = NSNotification.Name.init("AppDataDidUpdateNotification")
}

class AppData {

    var appOpens: Int {
        didSet { saveAndNotify() }
    }

    var linksOpened: Int {
        didSet { saveAndNotify() }
    }

    var linksCreated: Int {
        didSet { saveAndNotify() }
    }

    static let shared = AppData()
    var fortunes: [String.SubSequence] = [ ]
    var segmentEvents: Dictionary<String, AnyObject> = [:]

    private init() {
        appOpens = UserDefaults.standard.integer(forKey: "appOpens")
        linksOpened = UserDefaults.standard.integer(forKey: "linksOpened")
        linksCreated = UserDefaults.standard.integer(forKey: "linksCreated")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAppOpen(notification:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAppOpen(notification:)),
            name: NSNotification.Name.UIApplicationDidFinishLaunching,
            object: nil
        )
        // http://www.fortunecookiemessage.com/archive.php
        var fileURL = Bundle.main.bundleURL.appendingPathComponent("Fortunes.txt")
        if let allFortunes = try? String.init(contentsOf: fileURL) {
            self.fortunes = allFortunes.split(separator: "\n", omittingEmptySubsequences: true)
        }
        // https://segment.com/docs/spec/ecommerce/v2/
        fileURL = Bundle.main.bundleURL.appendingPathComponent("Events.json")
        if let fileData = try? Data.init(contentsOf: fileURL) {
            var eventsObj: Any?
            do {
                try eventsObj = JSONSerialization.jsonObject(with: fileData, options: [])
            } catch {
                print("Can't read events JSON: \(error).")
            }
            if let e = eventsObj as? Dictionary<String, AnyObject> {
                self.segmentEvents = e
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func initialize() {
        // Make sure we're lazy loaded and initialized. Not much to do.
    }

    @objc func updateAppOpen(notification: Notification) {
        self.appOpens += 1
    }

    func saveAndNotify() {
        UserDefaults.standard.set(appOpens, forKey: "appOpens")
        UserDefaults.standard.set(linksOpened, forKey: "linksOpened")
        UserDefaults.standard.set(linksCreated, forKey: "linksCreated")
        NotificationCenter.default.post(name: Notification.Name.AppDataDidUpdate, object: self)
    }

    func randomFortune() -> String {
        let index = Int(arc4random_uniform(UInt32(fortunes.count)))
        let s = self.fortunes[index]
        return String(s)
    }
}
