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
@end
