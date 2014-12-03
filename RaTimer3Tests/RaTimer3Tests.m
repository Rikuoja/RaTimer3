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

@interface RaTimer3Tests : XCTestCase

@property NSMutableArray* testikohteet;

@end

@implementation RaTimer3Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    //testataan kalenterilaskujen nopeutta randomisoiduilla kohteilla, joilla riittävän paljon aikaeventtejä riittävän pitkältä aikaväliltä:
    self.testikohteet=[self.testikohteet initWithCapacity:100];
    for (int i=1; i<100; i++) {
        NSMutableDictionary* uusiKohde = [NSMutableDictionary dictionary];
        [uusiKohde setValue:[@(i) stringValue] forKey:@"Nimi"];
        [uusiKohde setValue:@"" forKey:@"Vari"];
        [uusiKohde setValue:@NO forKey:@"Kaytossa"];
        [uusiKohde setValue:[NSMutableArray array] forKey:@"Ajat"];
        //aloitetaan satunnaisten aikojen generointi:
        int aikojenMaara=100;
        NSDate* alkuhetki = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*365];
        NSDate* nykyhetki = [NSDate date];
        NSTimeInterval valinPituus = [nykyhetki timeIntervalSinceDate:alkuhetki]/aikojenMaara;
        for (int j=0; j<aikojenMaara; j++) {
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
    }
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
