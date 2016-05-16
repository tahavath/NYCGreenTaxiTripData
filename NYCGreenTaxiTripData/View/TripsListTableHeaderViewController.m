//
//  TripsListTableHeaderViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripsListTableHeaderViewController.h"
#import "DownloadCoordinator.h"

@interface TripsListTableHeaderViewController ()

@end

@implementation TripsListTableHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startStopDownload:(id)sender {
	[[DownloadCoordinator sharedInstance] downloadNextItems:100];
}
@end
