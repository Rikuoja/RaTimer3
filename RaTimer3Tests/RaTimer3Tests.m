//
//  RaTimer3Tests.m
//  RaTimer3Tests
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

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
        [uusiKohde setValue:@"" forKey:@"Kuva"];
        [uusiKohde setValue:@NO forKey:@"Kaytossa"];
        [uusiKohde setValue:[NSMutableArray array] forKey:@"Ajat"];
        for (int j=1; j<100; j++) {
            NSMutableDictionary* uusiAika = [NSMutableDictionary dictionary];
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
