//
//  XCUITestCase+PercySnapshot.h
//  ios-ci-sample
//
//  Created by Miklos Fazekas on 30/10/16.
//  Copyright © 2016 Miklos Fazekas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#if 0
@interface XCTestCase()
- (void) startActivityWithTitle:(NSString*) title block:(void (^)(void)) block;
@end
#endif

#if 0
@interface XCTestCase (PercySnapshot)
- (void)percySnapshotWithPath:(NSString*)path;
@end
#endif
