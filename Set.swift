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

struct Set<T: Hashable>: Sequence {
    var _dict = Dictionary<T, Bool>()

    init() {}

    init(array: T[]) {
        for e in array {
            self.put(e)
        }
    }

    init(array: T?[]) {
        self.put(array)
    }

    init(set: NSSet) {
        self.put(set)
    }

    init(set: Set<T>) {
        self.put(set)
    }

    var count: Int {
        return self._dict.count
    }

    mutating func put(element: T?) {
        if let resolvedElement = element {
            self._dict[resolvedElement] = true
        }
    }

    mutating func put(array: T?[]) {
        for e in array {
            self.put(e)
        }
    }

    mutating func put(set: NSSet) {
        for e: AnyObject in set.allObjects { // Can't do `as T[]` for some reason.
            self.put(e as T) // Used forced downcast to throw exceptions if the data is wrong.
        }
    }

    mutating func put(set: Set<T>) {
        for e in set {
            self.put(e)
        }
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

    mutating func remove(element: T?) {
        if let resolvedElement = element {
            self._dict[resolvedElement] = nil
        }
    }

    mutating func remove(array: T?[]) {
        for e in array {
            self.remove(e)
        }
    }

    mutating func remove(set: NSSet) {
        for e: AnyObject in set.allObjects { // Can't do `as T[]` for some reason.
            self.remove(e as T) // Used forced downcast to throw exceptions if the data is wrong.
        }
    }

    mutating func remove(set: Set<T>) {
        for e in set {
            self.remove(e)
        }
    }

    subscript(element: T?) -> Bool {
        return self.has(element)
    }

    // Could be done for all sequences, really: https://gist.github.com/nubbel/d5a3639bea96ad568cf2
    func toArray() -> T[] {
        return T[](self._dict.keys)
    }

    func generate() -> SetGenerator<T> {
        return SetGenerator<T>(generator: self._dict.keys.generate())
    }

    func map <U>(fn: (T) -> U?) -> Set<U> {
        return Set<U>(array: self.toArray().map(fn))
    }

    func filter(fn: (T) -> Bool) -> Set<T> {
        return Set(array: self.toArray().filter(fn))
    }

}

func + <T>(a: Set<T>, b: Set<T>) -> Set<T> {
    var result = Set<T>(set: a)
    result.put(b)
    return result
}

func - <T>(a: Set<T>, b: Set<T>) -> Set<T> {
    var result = Set<T>(set: a)
    result.remove(b)
    return result
}
