//
//  MasterViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <DetailViewControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
//tallennetaan kohteet yhteen arrayhin:
@property (strong, nonatomic) NSMutableArray *objects;
//tallennetaan ruudunpäivityksestä vastaavat ajastimet toiseen arrayhin (ei voi tallentaa plistiin):
@property (strong, nonatomic) NSMutableArray *ajastimet;
//kuinka tarkkaan kulunut aika halutaan näyttää:
@property (nonatomic) NSTimeInterval ajanNayttotarkkuus;
//miltä aikaväliltä kulunut aika näytetään:
@property (nonatomic) NSCalendarUnit naytettavaAikavali;


- (IBAction)playPainettu:(UIButton *)sender;
- (void)tallennaKohteet;
- (void)lueKohteet;
- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *)kysyttyKohde aikavalilla:(NSCalendarUnit)haluttuAikavali;
- (NSString *)aikaaKulunutSelkokielella:(NSDateComponents *)aikaaKulunut;

@end

