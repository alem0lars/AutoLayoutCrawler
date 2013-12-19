//
//  ALCResultFormatter.h
//  AutoLayoutCrawler
//
//  Created by Alessandro Molari on 2013/12/19.
//  Copyright (c) 2013 Nextreamlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALCResultFormatter : NSObject

#pragma mark - Creators

- (NSString *)getConstraintsStringForView:(UIView *)view;
- (NSMutableAttributedString *)getConstraintsStringAttributedForView:(UIView *)view xib:(NSString *)xib;
- (NSString *)getNoConstraintsWarningMessageForXIB:(NSString *)xib;
- (NSMutableAttributedString *)getNoConstraintsWarningMessageAttributedForXIB:(NSString *)xib;

#pragma mark - Matchers

- (BOOL)matchContainsConstraint:(NSString *)string;

@end
