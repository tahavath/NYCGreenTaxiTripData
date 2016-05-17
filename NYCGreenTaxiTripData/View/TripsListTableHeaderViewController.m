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
	if ([[DownloadCoordinator sharedInstance] isDownloadPaused]) {
		[[DownloadCoordinator sharedInstance] downloadTrips];
		NSLog(@"Start downloading");
	} else {
		[[DownloadCoordinator sharedInstance] pauseDownload];
		NSLog(@"Download paused");
	}
}
@end
