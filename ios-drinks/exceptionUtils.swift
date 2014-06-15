//
//  exceptionUtils.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/14/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

func raiseInputException(description: String) {
    NSException.raise("IllegalInputFormat", format: description, arguments: CVaListPointer(fromUnsafePointer: UnsafePointer()))
}