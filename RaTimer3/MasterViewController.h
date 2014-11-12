//
//  MasterViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

- (IBAction)playPainettu:(UIButton *)sender;
- (void)tallennaKohteet;
- (void)lueKohteet;
- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *)kysyttyKohde aikavalilla:(NSCalendarUnit)haluttuAikavali;
- (NSString *)aikaaKulunutSelkokielella:(NSDateComponents *)aikaaKulunut;

@end

