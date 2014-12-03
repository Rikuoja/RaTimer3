//
//  RaTimer3Tests.m
//  RaTimer3Tests
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDate+RORandom.h"
#import "AppDelegate.h"
#import "MasterViewController.h"

@interface RaTimer3Tests : XCTestCase

@property NSMutableArray* testikohteet;
@property NSMutableArray* testiajastimet;
@property UIApplication* appi;
@property AppDelegate* delegaatti;
@property UISplitViewController* splitkontrolleri;
@property MasterViewController* masterkontrolleri;
@property UITableView* tableview;
@property int kohteidenMaara;
@property int aikojenMaara;

@end

@implementation RaTimer3Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.kohteidenMaara=15;
    self.aikojenMaara=5000;
    
    self.appi = [UIApplication sharedApplication];
    self.delegaatti = [self.appi delegate];
    self.splitkontrolleri = (UISplitViewController *)self.delegaatti.window.rootViewController;
    self.masterkontrolleri = ((UINavigationController *)self.splitkontrolleri.viewControllers.firstObject).viewControllers.firstObject;
    self.tableview=self.masterkontrolleri.tableView;
    
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitSecond;
    
    //testataan kalenterilaskujen nopeutta randomisoiduilla kohteilla, joilla riittävän paljon aikaeventtejä riittävän pitkältä aikaväliltä:
    self.testikohteet = [NSMutableArray arrayWithCapacity:self.kohteidenMaara];
    self.testiajastimet = [NSMutableArray arrayWithCapacity:self.kohteidenMaara];
    for (int i=0; i<self.kohteidenMaara; i++) {
        NSMutableDictionary* uusiKohde = [NSMutableDictionary dictionary];
        [uusiKohde setValue:[@(i) stringValue] forKey:@"Nimi"];
        [uusiKohde setValue:@"" forKey:@"Vari"];
        [uusiKohde setValue:@NO forKey:@"Kaytossa"];
        [uusiKohde setValue:[NSMutableArray array] forKey:@"Ajat"];
        //aloitetaan satunnaisten aikojen generointi:
        NSDate* alkuhetki = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*365]; //aloitetaan vuoden takaa
        NSDate* nykyhetki = [NSDate date];
        NSTimeInterval valinPituus = [nykyhetki timeIntervalSinceDate:alkuhetki]/self.aikojenMaara;
        for (int j=0; j<self.aikojenMaara; j++) {
            NSMutableDictionary* uusiAika = [NSMutableDictionary dictionary];
            NSDate *valinAlku = [NSDate dateWithTimeInterval:valinPituus*j sinceDate:alkuhetki];
            NSDate *valinLoppu = [NSDate dateWithTimeInterval:valinPituus*(j+1) sinceDate:alkuhetki];
            NSDate *aloitus = [NSDate ro_randomDateFromDate:valinAlku uptoDate:valinLoppu];
            [uusiAika setValue:aloitus forKey:@"Alku"];
            //eventin lopetus oltava aloituksen jälkeen:
            NSDate *lopetus = [NSDate ro_randomDateFromDate:aloitus uptoDate:valinLoppu];
            [uusiAika setValue:lopetus forKey:@"Loppu"];
            [uusiKohde[@"Ajat"] addObject:uusiAika];
        }
        [self.testikohteet addObject:uusiKohde];
        [self.testiajastimet addObject:[NSNull null]];
    }
    self.masterkontrolleri.objects=self.testikohteet;
    self.masterkontrolleri.ajastimet=self.testiajastimet;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testTaulukkoLoytyy
{
    XCTAssertNotNil(self.tableview,@"TableViewta ei löydy");
}

- (void)testDatasourceLoytyy
{
    XCTAssertNotNil(self.tableview.dataSource, @"DataSourcea ei löydy");
}

- (void)testTableViewNumberOfRowsInSection
{
    XCTAssertTrue([self.masterkontrolleri tableView:self.tableview numberOfRowsInSection:0]==self.kohteidenMaara, @"Rivejä on %ld eikä %ld", (long)[self.masterkontrolleri tableView:self.tableview numberOfRowsInSection:0], (long)self.kohteidenMaara);
}

- (void)testTableViewIndexPathsForVisibleRows
{
    XCTAssertNotNil([self.tableview indexPathsForVisibleRows].firstObject,@"Rivejä ei näkyvissä");
}

- (void)testViimeisenPaivanAjat {
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitDay;
    [self measureBlock:^{
        //testataan yhden kohteen päivityksen nopeus:
        UITableViewCell* solu = [self.masterkontrolleri tableView:self.tableview cellForRowAtIndexPath:[self.tableview indexPathsForVisibleRows].firstObject];
        // Put the code you want to measure the time of here.
    }];
}

- (void)testViimeisenViikonAjat {
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitWeekOfMonth;
    [self measureBlock:^{
        //testataan yhden kohteen päivityksen nopeus:
        UITableViewCell* solu = [self.masterkontrolleri tableView:self.tableview cellForRowAtIndexPath:[self.tableview indexPathsForVisibleRows].firstObject];
        // Put the code you want to measure the time of here.
    }];
}

- (void)testViimeisenKuukaudenAjat {
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitMonth;
    [self measureBlock:^{
        //testataan yhden kohteen päivityksen nopeus:
        UITableViewCell* solu = [self.masterkontrolleri tableView:self.tableview cellForRowAtIndexPath:[self.tableview indexPathsForVisibleRows].firstObject];
        // Put the code you want to measure the time of here.
    }];
}


- (void)testViimeisenVuodenAjat {
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitYear;
    [self measureBlock:^{
        //testataan yhden kohteen päivityksen nopeus:
        UITableViewCell* solu = [self.masterkontrolleri tableView:self.tableview cellForRowAtIndexPath:[self.tableview indexPathsForVisibleRows].firstObject];
        // Put the code you want to measure the time of here.
    }];
}

- (void)testKaikkiAjat {
    self.masterkontrolleri.naytettavaAikavali = NSCalendarUnitEra;
    [self measureBlock:^{
        //testataan yhden kohteen päivityksen nopeus:
        UITableViewCell* solu = [self.masterkontrolleri tableView:self.tableview cellForRowAtIndexPath:[self.tableview indexPathsForVisibleRows].firstObject];
        // Put the code you want to measure the time of here.
    }];
}

@end
