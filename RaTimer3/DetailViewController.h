//
//  DetailViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTPieChart.h"
#import "CPTGraph.h"

//tietojen välittämiseksi takaisin masterviewcontrollerin pitää olla tämän delegaatti:
@protocol DetailViewControllerDelegate;

//tämän pitää olla tekstikentän sekä colorpickerin popopverpresentaatiokontrollerin delegaatti:
@interface DetailViewController : UIViewController <UITextFieldDelegate, UIPopoverPresentationControllerDelegate, CPTPieChartDataSource, CPTPieChartDelegate>

@property (strong, nonatomic) NSMutableDictionary *detailItem;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailNavigationBar;
@property (weak, nonatomic) IBOutlet UITextField *nimiTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *variSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *popOverAnkkuri;
@property (nonatomic, assign) id <DetailViewControllerDelegate> delegate;

//visualisointi:
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *paivaView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *viikkoView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *kuukausiView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *vuosiView;


@end

@protocol DetailViewControllerDelegate <NSObject>
//metodin pitää kertoa delegaatille *mikä* kohde muuttui ja *miten*:
- (void) muuttunutKohde:(NSMutableDictionary *) kohde vanhaKohde:(NSMutableDictionary *) vanha;
- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *)kysyttyKohde aikavalilla:(NSCalendarUnit)haluttuAikavali;
//visualisaatiota varten detail view tarvitsee kaikkien kohteiden tiedot:
@property (strong, nonatomic) NSMutableArray *objects;
@end

