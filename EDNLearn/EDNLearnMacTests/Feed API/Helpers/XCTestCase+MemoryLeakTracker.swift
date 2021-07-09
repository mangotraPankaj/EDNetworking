//
//  XCTestCase+MemoryLeakTracker.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 21/06/21.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line)
    {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Memory leak.", file: file, line: line)
        }
    }
}
