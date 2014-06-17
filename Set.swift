//
//  Set.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/16/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

struct SetGenerator<T: Hashable>: Generator {
    var _generator: MapSequenceGenerator<Dictionary<T, Bool>.GeneratorType, T>

    init(generator: MapSequenceGenerator<Dictionary<T, Bool>.GeneratorType, T>) {
        self._generator = generator
    }

    mutating func next() -> T? {
        return self._generator.next()
    }
}

class Set<T: Hashable>: Sequence {
    var _dict = Dictionary<T, Bool>()

    init() {}

    init(array: T[]) {
        for t in array {
            self.put(t)
        }
    }

    init(set: NSSet) {
        for t: AnyObject in set.allObjects{ // Can't do `as T[]` for some reason.
            self.put(t as T)
        }
    }

    var count: Int {
        return self._dict.count
    }

    func put(element: T) {
        self._dict[element] = true
    }

    func has(element: T?) -> Bool {
        if let resolvedElement = element {
            if let _ = self._dict[resolvedElement] {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    func remove(element: T?) {
        if let resolvedElement = element {
            self._dict[resolvedElement] = nil
        }
    }

    subscript(element: T?) -> Bool {
        return self.has(element)
    }

    func generate() -> SetGenerator<T> {
        return SetGenerator<T>(generator: self._dict.keys.generate())
    }
}
