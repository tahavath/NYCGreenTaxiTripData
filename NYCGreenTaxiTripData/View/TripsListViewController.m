//
//  TripsListTableViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripsListViewController.h"
#import "TripsListTableViewCell.h"
#import "ModelCoordinator.h"
#import "DownloadCoordinator.h"
#import "TripDetailsViewController.h"
#import "MainViewController.h"

NSString *const THVTripCellIdentifier = @"TripCell";
NSString *const THVSectionSortKeyPath = @"month";
NSString *const THVLabelPause = @"Pause";
NSString *const THVLabelResume = @"Resume";
NSString *const THVLabelDownloadData= @"Download data";

NSString *const THVTripDetailsSegueName = @"ShowTripDetails";

typedef enum {
	THVDragDirectionDown	= -1,
	THVDragDirectionNone	= 0,
	THVDragDirectionUp		= 1
} THVDragDirection;

THVDragDirection detectDragDirection(currentOffsetY, previouseOffsetY) {
	return currentOffsetY > previouseOffsetY ? THVDragDirectionUp :
			currentOffsetY < previouseOffsetY ? THVDragDirectionDown:
												THVDragDirectionNone;
}

@interface TripsListViewController ()

@property (nonatomic) NSFetchedResultsController *fetchedResultController;
@property (nonatomic) NSFetchRequest *fetchRequest;
@property (nonatomic) NSSortDescriptor *sectionSortDescriptor;
@property (nonatomic) NSSortDescriptor *sortDescriptor;
@property (nonatomic) NSPredicate *fetchPredicate;

@property (nonatomic) CGFloat headerViewHeightStartingConstraintValue;

@property (nonatomic) THVDragDirection previousDragDirection;
@property (nonatomic) CGFloat previousOffsetY;
@property (nonatomic) CGFloat cumulativeY;

@property (nonatomic) NSProgress *downloadProgress;

@end

@implementation TripsListViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.headerViewHeightStartingConstraintValue = self.headerViewConstraint.constant;
	
	[self.tripsTableView registerNib:[UINib nibWithNibName:@"TripsListTableViewCell" bundle:nil] forCellReuseIdentifier:THVTripCellIdentifier];
	
	self.previousDragDirection = THVDragDirectionNone;
	self.previousOffsetY = 0.0;
	self.cumulativeY = 0.0;
	
	self.downloadActivityIndicator.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressChanged) name:THVNotificationNameTripsOffsetChanged object:nil];
	
	self.placeholderLabel.text = THVLabelNoTripsToShow;
	
	if (![Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey]) {
		self.placeholderView.hidden = NO;
		self.tripsTableView.hidden = YES;
	} else {
		self.placeholderView.hidden = YES;
		self.tripsTableView.hidden = NO;
	}
	
	if (![Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey]) {
		[self.startPauseDownloadButton setTitle:THVLabelDownloadData forState:UIControlStateNormal];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDownloadProgress) name:THVNotificationNameOverallTripsChecked object:nil];
		[[DownloadCoordinator sharedInstance] checkOverallTripsCount];
		self.downloadProgressLabel.hidden = YES;
	} else if ([[DownloadCoordinator sharedInstance] isDownloadPaused]){
		[self.startPauseDownloadButton setTitle:THVLabelResume forState:UIControlStateNormal];
		[self prepareDownloadProgress];
	} else {
		[self.startPauseDownloadButton setTitle:THVLabelPause forState:UIControlStateNormal];
		self.downloadActivityIndicator.hidden = NO;
		[self.downloadActivityIndicator startAnimating];
		[self prepareDownloadProgress];
	}
	
	if (self.selectedTrip) {
		[self.tripsTableView selectRowAtIndexPath:[self.fetchedResultController indexPathForObject:self.selectedTrip] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}
}

-(void) viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		MainViewController *mainVC = self.navigationController.viewControllers[0];
		mainVC.selectedTripEntity = self.selectedTrip;
	}
	
	[super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:THVTripDetailsSegueName]){
		TripData *tripData = (TripData *)sender;
		
		TripDetailsViewController *vc = segue.destinationViewController;
		vc.pickupLatitude = [tripData.pickupLatitude doubleValue];
		vc.pickupLongitude = [tripData.pickupLongitude doubleValue];
		vc.dropoffLatitude = [tripData.dropoffLatitude doubleValue];
		vc.dropoffLongitude = [tripData.dropoffLongitude doubleValue];
		
		vc.tripDistance = [tripData.tripDistance floatValue];
	}
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *storedSectionName = [((id<NSFetchedResultsSectionInfo>)self.fetchedResultController.sections[section]) name];
	
	NSDateFormatter *inputFormatter = [[Commons sharedInstance] monthFormatterForStoringAndSorting];
	NSDateFormatter *outputFormatter = [[Commons sharedInstance] monthFormatterForSectionHeaders];
	
	NSDate *inputDate = [inputFormatter dateFromString:storedSectionName];
	return [outputFormatter stringFromDate:inputDate];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {

	NSArray<id<NSFetchedResultsSectionInfo>> *sections = [self.fetchedResultController sections];
	
	NSMutableArray *sectionsIndexTitles = [NSMutableArray arrayWithCapacity:sections.count];
	
	NSDateFormatter *inputFormatter = [[Commons sharedInstance] monthFormatterForStoringAndSorting];
	NSDateFormatter *outputFormatter = [[Commons sharedInstance] monthFormatterForSectionsIndexTitles];
	
	
	for (int i = 0; i < sections.count; i++) {
		NSDate *inputDate = [inputFormatter dateFromString:[sections[i] name]];
		sectionsIndexTitles[i] = [outputFormatter stringFromDate:inputDate];
	}
	
	return sectionsIndexTitles;
}

#pragma mark - UITableViewDelegate protocol
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedTrip = [self.fetchedResultController objectAtIndexPath:indexPath];
	
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	
	[self performSegueWithIdentifier:THVTripDetailsSegueName sender:self.selectedTrip];
	
	NSLog(@"tapped row at: %@", indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedTrip = [self.fetchedResultController objectAtIndexPath:indexPath];
}

#pragma mark - table view helper methods
- (void)configureCell:(TripsListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	TripData *cellEntity = [self.fetchedResultController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [NSString stringWithFormat:@"Pickup time: %@", [[[Commons sharedInstance] dateFormatter] stringFromDate:cellEntity.pickupDateTime]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Total amount: %.02f", [cellEntity.totalAmount floatValue]];
}

- (void)showTableHeaderView {
	self.headerViewConstraint.constant = self.headerViewHeightStartingConstraintValue;
	self.navigationItem.rightBarButtonItem = nil;
}

- (UIBarButtonItem *)createNavBarIndicator {
	UIActivityIndicatorView *navBarIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	navBarIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[navBarIndicator startAnimating];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTableHeaderView)];
	[navBarIndicator addGestureRecognizer:tap];
	
	return [[UIBarButtonItem alloc] initWithCustomView:navBarIndicator];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tripsTableView reloadData];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat currentOffsetY = scrollView.contentOffset.y;
	CGFloat currentDragDirection = detectDragDirection(currentOffsetY, self.previousOffsetY);
	
	if (currentDragDirection != self.previousDragDirection) {
		self.cumulativeY = 0.0;
	} else {
		self.cumulativeY += (currentOffsetY - self.previousOffsetY);
	}
	
	if (fabs(self.cumulativeY) > self.headerViewHeightStartingConstraintValue) {
		if (currentDragDirection == THVDragDirectionDown && self.cumulativeY < 0) {
			[self showTableHeaderView];
		} else if (currentDragDirection == THVDragDirectionUp && self.cumulativeY > 0 && currentOffsetY > 0) {
			self.headerViewConstraint.constant = 0;
			if (![[DownloadCoordinator sharedInstance] isDownloadPaused] && !self.navigationItem.rightBarButtonItem) {
				self.navigationItem.rightBarButtonItem = [self createNavBarIndicator];
			}
		}
	}
	
	self.previousOffsetY = currentOffsetY;
	self.previousDragDirection = currentDragDirection;
}

#pragma mark - lazy properties initializers
- (NSFetchedResultsController *)fetchedResultController {
	if (!_fetchedResultController) {
		_fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[[ModelCoordinator sharedInstance] mainQueueContext] sectionNameKeyPath:THVSectionSortKeyPath cacheName:nil];
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
		_fetchRequest.sortDescriptors = @[self.sectionSortDescriptor, self.sortDescriptor];
		_fetchRequest.predicate = self.fetchPredicate;
	}
	
	return _fetchRequest;
}

- (NSSortDescriptor *)sectionSortDescriptor {
	if (!_sectionSortDescriptor) {
		_sectionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:THVSectionSortKeyPath ascending:YES];
	}
	
	return _sectionSortDescriptor;
}

- (NSSortDescriptor *)sortDescriptor {
	if (!_sortDescriptor) {
		_sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[TripData sortDescriptorName] ascending:[TripData sortAscending]];
	}
	
	return _sortDescriptor;
}

- (NSPredicate *)fetchPredicate {
	if (!_fetchPredicate) {
		_fetchPredicate = [NSPredicate predicateWithFormat:@"dropoffLatitude != 0 AND dropoffLongitude != 0 AND pickupLatitude != 0 and pickupLongitude != 0"];
	}
	
	return _fetchPredicate;
}

#pragma mark - iboutlets methods
- (IBAction)startPauseDownload:(id)sender {
	if ([[DownloadCoordinator sharedInstance] isDownloadPaused]) {
		
		[[DownloadCoordinator sharedInstance] downloadTrips];
		[self.startPauseDownloadButton setTitle:THVLabelPause forState:UIControlStateNormal];
		self.downloadActivityIndicator.hidden = NO;
		[self.downloadActivityIndicator startAnimating];
		
	} else {
		
		[[DownloadCoordinator sharedInstance] pauseDownload];
		[self.startPauseDownloadButton setTitle:THVLabelResume forState:UIControlStateNormal];
		self.downloadActivityIndicator.hidden = YES;
		[self.downloadActivityIndicator stopAnimating];
		
	}
}

#pragma mark - progress handling
- (void)prepareDownloadProgress {
	NSNumber *overallTripsCount = [Commons readValueFromUserDefaultsForKey:THVUserDefaultsOverallTripsCountKey];
	NSNumber *currentOffset = [Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey];
	
	self.downloadProgress = [NSProgress progressWithTotalUnitCount:[overallTripsCount integerValue]];
	[self.downloadProgress setCompletedUnitCount:[currentOffset integerValue]];
	
	self.downloadProgressLabel.hidden = NO;
	self.downloadProgressLabel.text = self.downloadProgress.localizedAdditionalDescription;
	
	[self.downloadProgressView setObservedProgress:self.downloadProgress];
}

- (void)progressChanged {
	NSNumber *currentOffset = [Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey];
	[self.downloadProgress setCompletedUnitCount:[currentOffset integerValue]];
	self.downloadProgressLabel.text = self.downloadProgress.localizedAdditionalDescription;
	
	self.placeholderView.hidden = YES;
	self.tripsTableView.hidden = NO;
}

@end
