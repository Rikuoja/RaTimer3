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
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "HRColorInfoView.h"

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

#pragma mark - Protocols

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

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    //tarvitaan uipopoverpresentationcontrollerdelegate-protokollaan!
    return UIModalPresentationNone;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //detailview asetetaan colorpickerin popovercontrollerin delegaatiksi
    if ([segue.identifier isEqualToString:@"naytaPopover"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        UIViewController *popoverinViewController = navigationController.viewControllers.firstObject;
        UIPopoverPresentationController *popoverPresentaatioController = navigationController.popoverPresentationController;
        popoverPresentaatioController.delegate = self;
        //hoidetaan kontrollointi tässä niin ei tarvitse tehdä custom-luokkaa
        //oletusmuotoinen colorPicker toimii (storyboardilla tehty bugittaa):
        HRColorPickerView* colorPicker = [[HRColorPickerView alloc] init];
        colorPicker.color = [UIColor colorWithCSS:self.detailItem[@"Vari"]];
        //colorPicker.colorMapView.saturationUpperLimit=@0.6; ei toimi
        popoverinViewController.view=colorPicker;
        [colorPicker addTarget:self action:@selector(paivitaVari:) forControlEvents:UIControlEventValueChanged];
    }
}


#pragma mark - Editing methods

- (void)paivitaVari:(HRColorPickerView *)colorPickerView {
    //pointteri vanhaan kohteeseen säilytettävä jotta delegaatti löytää sen:
    NSMutableDictionary* muuttunutKohde = [self.detailItem mutableCopy];
    muuttunutKohde[@"Vari"]=[colorPickerView.color cssString];
    //tällä delegaatti kirjoittaa uuden kohteen pointterin vanhan päälle ja päivittää itsensä:
    [self.delegate muuttunutKohde:(NSMutableDictionary *)muuttunutKohde vanhaKohde:(NSMutableDictionary *)self.detailItem];
    //näillä detailviewcontroller tekee saman:
    self.detailItem=muuttunutKohde;
    [self configureView];
}

@end
