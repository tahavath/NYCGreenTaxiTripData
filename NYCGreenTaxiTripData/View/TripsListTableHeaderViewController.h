//
//  TripsListTableHeaderViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripsListTableHeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UIButton *startStopDownload;

- (IBAction)startStopDownload:(id)sender;
@end
