//
//  MainScreenTripDetailsViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 24/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MainScreenTripDetailsViewController.h"

@interface MainScreenTripDetailsViewController ()

@property (nonatomic, weak) id<MainScreenTripDetailsDelegateProtocol> delegate;

@property (nonatomic) NSString *pickupLabelText;
@property (nonatomic) NSString *dropoffLabelText;
@property (nonatomic) NSString *additionalInfoText;

@end

@implementation MainScreenTripDetailsViewController

- (id)initWithPickupString:(NSString *)pickupString dropoffString:(NSString *)dropoffString additionalInfoString:(NSString *)additionalInfoString delegate:(id<MainScreenTripDetailsDelegateProtocol>)delegate {
	self = [super initWithNibName:@"MainScreenTripDetailsViewController" bundle:nil];
	
	if (self) {
		self.delegate = delegate;
		
		self.pickupLabelText = pickupString;
		self.dropoffLabelText = dropoffString;
		self.additionalInfoText = additionalInfoString;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.pickupDataLabel.text = self.pickupLabelText;
	self.dropoffDataLabel.text = self.dropoffLabelText;
	self.additionalInfoLabel.text = self.additionalInfoText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showDetails:(id)sender {
	[self.delegate goToTripDetails];
}

@end
