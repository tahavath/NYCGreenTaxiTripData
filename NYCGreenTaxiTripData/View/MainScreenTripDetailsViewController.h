//
//  MainScreenTripDetailsViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 24/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScreenTripDetailsDelegateProtocol.h"

@interface MainScreenTripDetailsViewController : UIViewController

- (id)initWithPickupString:(NSString *)pickupString dropoffString:(NSString *)dropoffString additionalInfoString:(NSString *)additionalInfoString delegate:(id<MainScreenTripDetailsDelegateProtocol>)delegate;

- (IBAction)showDetails:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *pickupDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;

@end
