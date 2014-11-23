//
//  DetailViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSMutableDictionary *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    //vanha kohde pitää pitää tallessa jotta delegaatti löytää sen:
    NSMutableDictionary* muuttunutKohde = self.detailItem.copy;
    muuttunutKohde[@"Nimi"]=self.nimiTextField.text;
    [self.delegate muuttunutKohde:(NSMutableDictionary *)muuttunutKohde vanhaKohde:(NSMutableDictionary *)self.detailItem];
    self.detailItem=muuttunutKohde;
    [self configureView];
    return YES;
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailNavigationBar.title = self.detailItem[@"Nimi"];
        self.nimiTextField.text = self.detailItem[@"Nimi"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
