//
//  TripsListTableViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripsListViewController.h"
#import "TripsListTableHeaderViewController.h"
#import "TripsListTableViewCell.h"
#import "ModelCoordinator.h"
#import "TripData.h"

NSString *const THVTripCellIdentifier = @"TripCell";

@interface TripsListViewController ()

@property (nonatomic) NSFetchedResultsController *fetchedResultController;
@property (nonatomic) NSFetchRequest *fetchRequest;
@property (nonatomic) NSSortDescriptor *sortDescriptor;
@property (nonatomic) NSPredicate *fetchPredicate;

@property (nonatomic) TripsListTableHeaderViewController *tableHeaderVC;

@end

@implementation TripsListViewController

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	[self.tableHeaderVC.view setNeedsLayout];
	[self.tableHeaderVC.view layoutIfNeeded];
	
	CGFloat tableViewHeaderHeight = [self.tableHeaderVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
	
	CGRect tableViewHeaderFrame = self.tableHeaderVC.view.frame;
	tableViewHeaderFrame.size.height = tableViewHeaderHeight;
	self.tableHeaderVC.view.frame = tableViewHeaderFrame;
	self.tripsTableView.tableHeaderView = self.tableHeaderVC.view;
}

- (void)viewDidLoad {
	self.title = @"Trips";
	
	self.tableHeaderVC = [TripsListTableHeaderViewController new];
	[self addChildViewController:self.tableHeaderVC];
	
	[self.tripsTableView registerNib:[UINib nibWithNibName:@"TripsListTableViewCell" bundle:nil] forCellReuseIdentifier:THVTripCellIdentifier];
}

#pragma mark - UITableViewDataSource protocol
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResultController.sections[section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.fetchedResultController.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TripsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THVTripCellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

#pragma mark - UITableViewDelegate protocol
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"tapped row at: %@", indexPath);
}

#pragma mark - table view helper methods
- (void)configureCell:(TripsListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	TripData *cellEntity = [self.fetchedResultController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [NSString stringWithFormat:@"Pickup time: %@", cellEntity.pickupDateTime];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Total amount: %.02f", [cellEntity.totalAmount floatValue]];
	
	cell.backgroundColor = indexPath.row % 2 ? [UIColor grayColor] : [UIColor lightGrayColor];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tripsTableView reloadData];
}


#pragma mark - lazy properties initializers
- (NSFetchedResultsController *)fetchedResultController {
	if (!_fetchedResultController) {
		_fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[[ModelCoordinator sharedInstance] mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
		[_fetchedResultController setDelegate:self];
		
		NSError *fetchError = nil;
		if (![self.fetchedResultController performFetch:&fetchError]) {
			NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [fetchError localizedDescription], [fetchError userInfo]);
			abort();
		}
	}
	
	return _fetchedResultController;
}

- (NSFetchRequest *)fetchRequest {
	if (!_fetchRequest) {
		_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TripData entityName]];
		_fetchRequest.sortDescriptors = @[self.sortDescriptor];
		_fetchRequest.predicate = self.fetchPredicate;
	}
	
	return _fetchRequest;
}

- (NSSortDescriptor *)sortDescriptor {
	if (!_sortDescriptor) {
		_sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[TripData sortDescriptorName] ascending:[TripData sortAscending]];
	}
	
	return _sortDescriptor;
}

- (NSPredicate *)fetchPredicate {
	if (!_fetchPredicate) {
		_fetchPredicate = nil;
	}
	
	return _fetchPredicate;
}

@end
