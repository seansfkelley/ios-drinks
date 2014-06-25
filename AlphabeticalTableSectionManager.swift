//
//  AlphabeticalTableSectionManager.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

class AlphabeticalTableSectionManager<T: AnyObject> {
    typealias Section = T[]

    let letterToSection: Dictionary<String, Section>
    let orderedSections: Section[]
    let orderedSectionTitles: String[]
    let sortedItems: Section
    let allSectionIndexTitles: String[]

    init(items: T[], titleExtractor: (T) -> String) {
        self.sortedItems = sort(items, { titleExtractor($0) < titleExtractor($1) })

        var letterToSection = Dictionary<String, Section>()
        var orderedSections: Section[] = []
        var orderedSectionTitles: String[] = []

        var letterToIndex = Dictionary<String, Int>()
        var i = 0

        for item in self.sortedItems {
            // TODO: Gross workaround to get the first character of the string.
            let key = String(Array(titleExtractor(item))[0])

            if var section: Section = letterToSection[key] {
                section += item
                letterToSection[key] = section
                orderedSections[letterToIndex[key]!] = section
            } else {
                let section = [item]
                letterToSection.updateValue(section, forKey: key)
                orderedSections += section
                orderedSectionTitles += key

                letterToIndex[key] = i++
            }
        }

        self.letterToSection = letterToSection
        self.orderedSections = orderedSections
        self.orderedSectionTitles = orderedSectionTitles
        self.allSectionIndexTitles = [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#" ]
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> T {
        return self.orderedSections[indexPath.section][indexPath.row]
    }

    func sectionForSectionIndexTitle(sectionTitle: String) -> Int {
        for var i = self.orderedSectionTitles.count - 1; i >= 0; --i {
            var compareResult: NSComparisonResult = sectionTitle.compare(self.orderedSectionTitles[i])
            if compareResult == NSComparisonResult.OrderedDescending || compareResult == NSComparisonResult.OrderedSame {
                return i
            }
        }
        return self.orderedSectionTitles.count - 1
    }

    func sortedIndexForIndexPath(indexPath: NSIndexPath) -> Int {
        var index = 0
        for i in 0..indexPath.section { // .. -> exclusive
            index += self.orderedSections[i].count
        }
        return index + indexPath.row
    }
}
