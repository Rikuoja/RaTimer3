//
//  SettingsViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.12.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tarkkuusSegmentedControl;
@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;

- (IBAction)paivitaAikavali:(id)sender;
- (IBAction)paivitaTarkkuus:(id)sender;

@end

@protocol SettingsViewControllerDelegate <NSObject>
@property (nonatomic) NSCalendarUnit naytettavaAikavali;
@property (nonatomic) NSTimeInterval ajanNayttotarkkuus;
- (void)paivitaTaulukko;
@end
