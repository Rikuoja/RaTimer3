//
//  DetailViewController.h
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>

//tietojen välittämiseksi takaisin masterviewcontrollerin pitää olla tämän delegaatti:
@protocol DetailViewControllerDelegate;

@interface DetailViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *detailItem;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailNavigationBar;
@property (weak, nonatomic) IBOutlet UITextField *nimiTextField;
@property (nonatomic, assign) id <DetailViewControllerDelegate> delegate;

@end

@protocol DetailViewControllerDelegate <NSObject>
- (void) muuttunutKohde:(NSMutableDictionary *) kohde;
@end

