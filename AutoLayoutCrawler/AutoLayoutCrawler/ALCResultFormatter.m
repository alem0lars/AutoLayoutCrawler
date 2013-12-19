//
//  ALCResultFormatter.m
//  AutoLayoutCrawler
//
//  Created by Alessandro Molari on 2013/12/19.
//  Copyright (c) 2013 Nextreamlabs. All rights reserved.
//

#import "ALCResultFormatter.h"


@interface ALCResultFormatter ()

#define CONTAINS_CONSTRAINTS_REGEX (@"\\([\\s]\\)")
#define CONSTRAINT_REGEX (@"<NSLayoutConstraint:(0x[a-f0-9]+) ([HV]:\\S+).*\\(Names: '.+':(UI[A-Za-z]+:0x[a-f0-9]+) \\)>")

#define RESULT_TEXT_VIEW_DEFAULT_SIZE (14)

@end


@implementation ALCResultFormatter

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
}

#pragma mark - Creators

- (NSMutableString *)getConstraintsStringForView:(UIView *)view
{
    return [[NSMutableString alloc]initWithFormat:@"%@", view.constraints];
}

- (NSMutableAttributedString *)getConstraintsStringAttributedForView:(UIView *)view xib:(NSString *)xib
{
    NSString *constraintsString = [self getConstraintsStringForView:view];
    
    NSMutableAttributedString *out;
    
    NSString *constraintId;
    NSString *constraintContent;
    NSString *viewConstrainedName;
    
    if ([self matchContainsConstraint:constraintsString] &&
        [self matchConstraint:constraintsString
                 constraintId:&constraintId
            constraintContent:&constraintContent
          viewConstrainedName:&viewConstrainedName]) {
            NSDictionary *attributes;
            out = [[NSMutableAttributedString alloc] init];
            
            // { Build: "Constraint '<constraint>' for "
            
            attributes = @{NSUnderlineStyleAttributeName: [[NSNumber alloc] initWithInteger:NSUnderlineStyleSingle]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@"Constraint"
                                                                        attributes:attributes]];
            
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:RESULT_TEXT_VIEW_DEFAULT_SIZE]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:constraintId
                                                                        attributes:attributes]];
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@" for "]];
            // }
            
            // { Build: "View '<view_id>': "
            attributes = @{NSUnderlineStyleAttributeName: [[NSNumber alloc] initWithInteger:NSUnderlineStyleSingle]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@"View"
                                                                        attributes:attributes]];
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:RESULT_TEXT_VIEW_DEFAULT_SIZE]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:viewConstrainedName
                                                                        attributes:attributes]];
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:RESULT_TEXT_VIEW_DEFAULT_SIZE + 6]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@"☞"
                                                                        attributes:attributes]];
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            // }
            
            // { Build: "<constraint_content>"
            attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:RESULT_TEXT_VIEW_DEFAULT_SIZE]};
            [out appendAttributedString:[[NSAttributedString alloc] initWithString:constraintContent
                                                                        attributes:attributes]];
            // }
        } else {
            out = [self getNoConstraintsWarningMessageAttributedForXIB:xib];
    }
    
    return out;
}

- (NSString *)getNoConstraintsWarningMessageForXIB:(NSString *)xib
{
    return [[NSString alloc] initWithFormat:@"The view '%@' doesn't have constraints", xib];
}

- (NSMutableAttributedString *)getNoConstraintsWarningMessageAttributedForXIB:(NSString *)xib
{
    NSString *warningMessageString = [self getNoConstraintsWarningMessageForXIB:xib];
    NSMutableAttributedString *warningMessage =
    [[NSMutableAttributedString alloc] initWithString:warningMessageString
                                           attributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                                        NSStrokeWidthAttributeName: @(-2.0),
                                                        NSFontAttributeName: [UIFont italicSystemFontOfSize:RESULT_TEXT_VIEW_DEFAULT_SIZE],
                                                        NSStrokeColorAttributeName: [UIColor yellowColor]}];
    return warningMessage;
}

#pragma mark - Matchers

- (BOOL)matchConstraint:(NSString *)string
           constraintId:(NSString **)constraintId
      constraintContent:(NSString **)constraintContent
    viewConstrainedName:(NSString **)viewConstrainedName
{
    NSRange stringRange = NSMakeRange(0, [string length]);
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:CONSTRAINT_REGEX
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if (error) {
        return NO;
    }
    
    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    for (NSTextCheckingResult *match in matches) {
        *constraintId = [string substringWithRange:[match rangeAtIndex:1]];
        *constraintContent = [string substringWithRange:[match rangeAtIndex:2]];
        *viewConstrainedName = [string substringWithRange:[match rangeAtIndex:3]];
    }
    
    return YES;
}

- (BOOL)matchContainsConstraint:(NSString *)string
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:CONTAINS_CONSTRAINTS_REGEX
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if (error) {
        return NO;
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return numberOfMatches == 0;
}

@end
