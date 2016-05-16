//
//  TripsListTableViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

extern NSString *const THVTripCellIdentifier;

@interface TripsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tripsTableView;

@end
