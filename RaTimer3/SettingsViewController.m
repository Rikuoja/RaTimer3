//
//  SettingsViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.12.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "SettingsViewController.h"
#import "DismissSegue.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    switch (self.delegate.naytettavaAikavali) {
        case (NSCalendarUnitDay): self.rangeSegmentedControl.selectedSegmentIndex=0; break;
        case (NSCalendarUnitWeekOfMonth): self.rangeSegmentedControl.selectedSegmentIndex=1; break;
        case (NSCalendarUnitMonth): self.rangeSegmentedControl.selectedSegmentIndex=2; break;
        case (NSCalendarUnitYear): self.rangeSegmentedControl.selectedSegmentIndex=3; break;
    }
    switch ((NSInteger)self.delegate.ajanNayttotarkkuus) {
        case (60): self.tarkkuusSegmentedControl.selectedSegmentIndex=0; break;
        case (60*15): self.tarkkuusSegmentedControl.selectedSegmentIndex=1; break;
        case (60*30): self.tarkkuusSegmentedControl.selectedSegmentIndex=2; break;
        case (60*60): self.tarkkuusSegmentedControl.selectedSegmentIndex=3; break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)paivitaAikavali:(id)sender {
    switch (self.rangeSegmentedControl.selectedSegmentIndex) {
        case (0): self.delegate.naytettavaAikavali=NSCalendarUnitDay; break;
        case (1): self.delegate.naytettavaAikavali=NSCalendarUnitWeekOfMonth; break;
        case (2): self.delegate.naytettavaAikavali=NSCalendarUnitMonth; break;
        case (3): self.delegate.naytettavaAikavali=NSCalendarUnitYear; break;
    }
    [self.delegate paivitaTaulukko];
    //käytetään storyboardin dismiss-segueta poistumiseen:
    [self performSegueWithIdentifier:@"dismiss" sender:self];
}

- (IBAction)paivitaTarkkuus:(id)sender {
    switch (self.tarkkuusSegmentedControl.selectedSegmentIndex) {
        case (0): self.delegate.ajanNayttotarkkuus=60; break;
        case (1): self.delegate.ajanNayttotarkkuus=60*15; break;
        case (2): self.delegate.ajanNayttotarkkuus=60*30; break;
        case (3): self.delegate.ajanNayttotarkkuus=60*60; break;
    }
    [self.delegate paivitaTaulukko];
    //käytetään storyboardin dismiss-segueta poistumiseen:
    [self performSegueWithIdentifier:@"dismiss" sender:self];
}
@end
