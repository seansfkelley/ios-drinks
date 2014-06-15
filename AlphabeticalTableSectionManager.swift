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
            let key = "\(titleExtractor(item).utf16[0])".uppercaseString

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
}

//@interface SortedTableSectionManager : NSObject
//
//- (id)initWithArray:(NSArray *)array sortedByProperty:(NSString *)property;
//
//- (id)objectForIndexPath:(NSIndexPath *)indexPath;
//- (NSUInteger)sortedIndexForIndexPath:(NSIndexPath *)indexPath;
//- (NSUInteger)sectionForSectionIndexTitle:(NSString *)title;
//
//@property (readonly) NSDictionary *nameToSection;
//@property (readonly) NSArray *indexToSection;
//@property (readonly) NSArray *indexToTitle;
//@property (readonly) NSArray *sorted;
//@property (readonly) NSArray *sectionIndexTitles;
//
//@end
