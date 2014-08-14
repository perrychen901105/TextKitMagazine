//
//  DetailViewController.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "BookViewController.h"
#import "BookView.h"
#import "AppDelegate.h"

@interface BookViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation BookViewController
{
    BookView *_bookView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0.87f alpha:1.0f];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _bookView = [[BookView alloc] initWithFrame:self.view.bounds];
    _bookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bookView.bookMarkup = appDelegate.bookMarkup;
    
    [self.view addSubview:_bookView];
    NSLog(@"viewDidLoad");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Chapters";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)viewDidLayoutSubviews
{
    [_bookView buildFrames];
}

- (void)navigateToCharacterLocation:(NSUInteger)location
{
    [self.masterPopoverController dismissPopoverAnimated:YES];
    [_bookView navigateToCharacterLocation:location];
}

@end
