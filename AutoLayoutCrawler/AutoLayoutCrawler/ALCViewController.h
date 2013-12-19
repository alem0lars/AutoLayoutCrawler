//
//  ALCViewController.h
//  AutoLayoutCrawler
//
//  Created by Alessandro Molari on 2013/12/18.
//  Copyright (c) 2013 Nextreamlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALCViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIView *loadedView;
@property (strong, nonatomic) NSArray *availableXIBs;

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *xibPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *actionsToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *calculateButton;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

#pragma mark - Actions

- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)calculateButtonPressed:(id)sender;

@end
