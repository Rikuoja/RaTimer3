//
//  MasterViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "SettingsViewController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <DetailViewControllerDelegate, UIPopoverPresentationControllerDelegate, SettingsViewControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
//kuinka tarkkaan kulunut aika halutaan näyttää:
@property (nonatomic) NSTimeInterval ajanNayttotarkkuus;
//miltä aikaväliltä kulunut aika näytetään:
@property (nonatomic) NSCalendarUnit naytettavaAikavali;
//tallennetaan kohteet yhteen arrayhin:
@property (strong, nonatomic) NSMutableArray *objects;
//tallennetaan ruudunpäivityksestä vastaavat ajastimet toiseen arrayhin (ei voi tallentaa plistiin):
//ajastinten ja kohteiden olisi parempi olla ei-julkisia, mutta tämä estäisi testauksen ja toisaalta detailviewin tekemän kaikkien kohteiden visualisaation.
@property (strong, nonatomic) NSMutableArray *ajastimet;

- (IBAction)playPainettu:(UIButton *)sender;
- (void)tallennaKohteet;
- (void)lueKohteet;
- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *)kysyttyKohde aikavalilla:(NSCalendarUnit)haluttuAikavali;
- (NSString *)aikaaKulunutSelkokielella:(NSDateComponents *)aikaaKulunut;
- (void)muuttunutKohde:(NSMutableDictionary *) kohde vanhaKohde:(NSMutableDictionary *) vanha;
- (void)paivitaTaulukko;
- (void)valitseKohde:(NSInteger) kohde;

@end

