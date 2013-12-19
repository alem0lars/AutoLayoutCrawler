//
//  ALCViewController.m
//  AutoLayoutCrawler
//
//  Created by Alessandro Molari on 2013/12/18.
//  Copyright (c) 2013 Nextreamlabs. All rights reserved.
//

#import "ALCViewController.h"
#import "ALCResultFormatter.h"


@interface ALCViewController ()

#define NUMBER_OF_PICKERS (1)
#define NIB_EXTENSION (@"nib")

@property (strong, nonatomic) NSNumber *selectedXIBIndex;
@property (strong, nonatomic) ALCResultFormatter *resultFormatter;

@end


@implementation ALCViewController

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.resultFormatter = [[ALCResultFormatter alloc] init];
    self.selectedXIBIndex = 0;
    [self loadXIBs];
}

- (void)dealloc
{
    self.loadedView = nil;
    self.availableXIBs = nil;
    self.selectedXIBIndex = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.xibPicker.delegate = self;
    self.xibPicker.dataSource = self;
    
    [super viewWillAppear:animated];
    
    self.resultTextView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return NUMBER_OF_PICKERS;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.availableXIBs count];
}

#pragma mark - Picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row < [self.availableXIBs count]) {
        self.selectedXIBIndex = [[NSNumber alloc] initWithInteger:row];
        NSLog(@"Selected view: %@", [self.availableXIBs objectAtIndex:[self.selectedXIBIndex integerValue]]);
    } else {
        NSLog(@"Error: invalid row %ld", (long)row);
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    
    if (row < [self.availableXIBs count]) {
        title = [self.availableXIBs objectAtIndex:row];
    } else {
        NSLog(@"Invalid row %ld", (long)row);
        title = @"Invalid row";
    }
    
    return title;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *title;
    
    if (row < [self.availableXIBs count]) {
        title = [[NSAttributedString alloc] initWithString:[self.availableXIBs objectAtIndex:row]];
    } else {
        NSLog(@"Invalid row %ld", (long)row);
        title = [[NSAttributedString alloc] initWithString:@"Invalid row"];
    }
    
    return title;
}

#pragma mark - Actions

- (IBAction)clearButtonPressed:(id)sender
{
    self.resultTextView.text = [[NSString alloc] init];
}

- (IBAction)calculateButtonPressed:(id)sender
{
    if ([self.selectedXIBIndex integerValue] < [self.availableXIBs count]) {
        NSString * selectedXIBName = [self.availableXIBs objectAtIndex:[self.selectedXIBIndex integerValue]];
        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:selectedXIBName owner:self options:nil];
        self.loadedView = [xib objectAtIndex:0];
        NSAttributedString *constraintsString = [self.resultFormatter getConstraintsStringAttributedForView:self.loadedView
                                                                                                        xib:selectedXIBName];
        if ([constraintsString length] > 0) {
            NSMutableAttributedString *resultAttributedText =
                    [[NSMutableAttributedString alloc] initWithAttributedString:self.resultTextView.attributedText];
            [resultAttributedText appendAttributedString:constraintsString];
            [resultAttributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            self.resultTextView.attributedText = resultAttributedText;
        } else {
            NSString *warningMessage = [self.resultFormatter getNoConstraintsWarningMessageForXIB:selectedXIBName];
            NSMutableAttributedString *warningMessageAttributed =
                    [self.resultFormatter getNoConstraintsWarningMessageAttributedForXIB:selectedXIBName];
            [warningMessageAttributed appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            NSLog(@"Warning: %@", warningMessage);
            self.resultTextView.attributedText = warningMessageAttributed;
        }
    } else {
        NSLog(@"Error: invalid picker index %@", self.selectedXIBIndex);
    }
}

#pragma mark - Utilities

- (void)loadXIBs
{
    NSMutableArray *availableXIBs = [[NSMutableArray alloc] init];
    
    //NSBundle* bundle = [NSBundle bundleWithPath:absolutePathToNibFile];
    NSBundle *bundle = [NSBundle mainBundle];
    NSLog(@"Using bundle %@", bundle);
    
    NSString *xibDirectory = [bundle resourcePath];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    BOOL fileExists = [fileManager fileExistsAtPath:xibDirectory isDirectory:&isDirectory];
    if (fileExists && isDirectory) {
        NSError *error;
        NSArray *xibDirectoryContent = [fileManager contentsOfDirectoryAtPath:xibDirectory error:&error];
        for (id xibDirectoryElement in xibDirectoryContent) {
            if ([[xibDirectoryElement pathExtension] isEqualToString:NIB_EXTENSION]) {
                [availableXIBs addObject:[[xibDirectoryElement lastPathComponent] stringByDeletingPathExtension]];
            }
        }
    } else {
        NSLog(@"XIBs folder doesn't exit");
    }
    
    self.availableXIBs = availableXIBs;
}

@end
