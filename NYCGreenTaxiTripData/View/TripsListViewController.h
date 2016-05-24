//
//  TripsListTableViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TripData.h"

extern NSString *const THVTripCellIdentifier;

@interface TripsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tripsTableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadProgressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *startPauseDownloadButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewConstraint;

@property (nonatomic) TripData *selectedTrip;

- (IBAction)startPauseDownload:(id)sender;

@end
