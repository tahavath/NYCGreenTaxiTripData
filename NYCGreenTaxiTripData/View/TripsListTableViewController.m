//
//  TripsListTableViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripsListTableViewController.h"

NSString *const THVTripCellIdentifier = @"TripCell";

@implementation TripsListTableViewController

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Trips list";
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THVTripCellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THVTripCellIdentifier];
	}
	
	return cell;
}

@end
