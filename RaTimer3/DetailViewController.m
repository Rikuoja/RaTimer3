//
//  DetailViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "DetailViewController.h"
#import "UIColor+RandomColors.h"
#import "UIColor+Hex.h"
#import "HRColorPickerView.h"

@interface DetailViewController ()

//lisätään colorPickerView samaan kontrolleriin (vai pitäisikö tehdä oma kontrolleri??)
@property (strong, nonatomic) HRColorPickerView *colorPickerView;
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
    //pointteri vanhaan kohteeseen säilytettävä jotta delegaatti löytää sen:
    NSMutableDictionary* muuttunutKohde = [self.detailItem mutableCopy];
    muuttunutKohde[@"Nimi"]=self.nimiTextField.text;
    //tällä delegaatti kirjoittaa uuden kohteen pointterin vanhan päälle ja päivittää itsensä:
    [self.delegate muuttunutKohde:(NSMutableDictionary *)muuttunutKohde vanhaKohde:(NSMutableDictionary *)self.detailItem];
    //näillä detailviewcontroller tekee saman:
    self.detailItem=muuttunutKohde;
    [self configureView];
    return YES;
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailNavigationBar.title = self.detailItem[@"Nimi"];
        self.nimiTextField.text = self.detailItem[@"Nimi"];
        //lisätään colorpicker:
        self.colorPickerView = [[HRColorPickerView alloc] init];
        self.colorPickerView.color = [UIColor colorWithCSS:self.detailItem[@"Vari"]];
        [self.colorPickerView addTarget:self
                            action:@selector(paivitaVari:)
                  forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.colorPickerView];
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

#pragma mark - Detail item methods

- (void)paivitaVari:(HRColorPickerView *)colorPickerView {
    //pointteri vanhaan kohteeseen säilytettävä jotta delegaatti löytää sen:
    NSMutableDictionary* muuttunutKohde = [self.detailItem mutableCopy];
    muuttunutKohde[@"Vari"]=[colorPickerView.color hexString];
    //tällä delegaatti kirjoittaa uuden kohteen pointterin vanhan päälle ja päivittää itsensä:
    [self.delegate muuttunutKohde:(NSMutableDictionary *)muuttunutKohde vanhaKohde:(NSMutableDictionary *)self.detailItem];
    //näillä detailviewcontroller tekee saman:
    self.detailItem=muuttunutKohde;
    [self configureView];
}

@end
