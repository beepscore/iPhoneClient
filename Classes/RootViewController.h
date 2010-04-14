//
//  RootViewController.h
//  iPhoneClient
//
//	HW3_1
//
//  Copyright 2010 Chris Parrish

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController
{
#pragma mark Instance variables
    NSNetServiceBrowser*	browser_;
	NSMutableArray*			services_;
}

#pragma mark Properties


@end
