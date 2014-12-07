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
#import "CPTGraph.h"
#import "CPTGraphHostingView.h"
#import "CPTTheme.h"
#import "CPTMutableTextStyle.h"
#import "CPTColor.h"
#import "CPTXYGraph.h"

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //interface builder on piirtänyt plottialueet vasta nyt => voidaan piirtää kuvaajat!
    [self piirraKuvat];
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
        //oletusmuotoinen colorPicker toimii tässä (storyboardilla tehty bugittaa):
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

#pragma mark - Visualization

- (void) piirraKuvat {
    NSMutableArray* kuvaViewit = [NSMutableArray array];
    NSMutableArray* kuvaGraphit = [NSMutableArray array];
    NSMutableArray* otsikot = [NSMutableArray array];
    NSMutableArray* pieChartit = [NSMutableArray array];
    [kuvaViewit addObject:self.paivaView];
    [otsikot addObject:@"Today"];
    [kuvaViewit addObject:self.viikkoView];
    [otsikot addObject:@"This week"];
    [kuvaViewit addObject:self.kuukausiView];
    [otsikot addObject:@"This month"];
    [kuvaViewit addObject:self.vuosiView];
    [otsikot addObject:@"This year"];
    for (CPTGraphHostingView* view in kuvaViewit) {
        view.allowPinchScaling=NO;
        CPTXYGraph* lisattavaGraph=[[CPTXYGraph alloc] initWithFrame:view.bounds];
        view.hostedGraph=lisattavaGraph;
        [kuvaGraphit addObject:lisattavaGraph];
    }
    for (CPTXYGraph* graph in kuvaGraphit) {
        graph.paddingLeft = 0.0f;
        graph.paddingTop = 0.0f;
        graph.paddingRight = 0.0f;
        graph.paddingBottom = 0.0f;
        graph.axisSet = nil;
        graph.title = otsikot[[kuvaGraphit indexOfObject:graph]];
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color = [CPTColor grayColor];
        textStyle.fontName = @"Helvetica-Bold";
        textStyle.fontSize = 16.0f;
        [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
        //sitten vihdoin lisätään piechart:
        CPTPieChart* pieChart;
        pieChart = [[CPTPieChart alloc] init];
        pieChart.dataSource = self;
        pieChart.delegate = self;
        pieChart.pieRadius = ((CPTGraphHostingView *)kuvaViewit[[kuvaGraphit indexOfObject:graph]]).bounds.size.height*0.35;
        pieChart.startAngle = M_PI_4;
        pieChart.sliceDirection = CPTPieDirectionClockwise;
        pieChart.identifier = (NSString* )otsikot[[kuvaGraphit indexOfObject:graph]];
        [graph addPlot:pieChart];
        [pieChartit addObject:pieChart];
    }
}

#pragma mark - CPTPieChartDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.delegate.objects count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSCalendarUnit haluttuAikavali;
    NSDateComponents* tunnitMinuutitSekunnit;
    if ([plot.identifier isEqual:@"Today"]) haluttuAikavali=NSCalendarUnitDay;
    if ([plot.identifier isEqual:@"This week"]) haluttuAikavali=NSCalendarUnitWeekOfMonth;
    if ([plot.identifier isEqual:@"This month"]) haluttuAikavali=NSCalendarUnitMonth;
    if ([plot.identifier isEqual:@"This year"]) haluttuAikavali=NSCalendarUnitYear;
    tunnitMinuutitSekunnit=[self.delegate aikaaKulunut:self.delegate.objects[index] aikavalilla:haluttuAikavali];
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
        return [NSNumber numberWithInt:tunnitMinuutitSekunnit.hour*60*60+tunnitMinuutitSekunnit.minute*60+tunnitMinuutitSekunnit.second];
    } else return nil;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    return nil;
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return @"";
}

@end
