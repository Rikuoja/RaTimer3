//
//  OmaTableViewCell.h
//  RaTimer
//
//  Created by Riku Oja on 3.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OmaTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nimiLabel;
@property (nonatomic, weak) IBOutlet UILabel *aikaLabel;
@property (nonatomic, weak) IBOutlet UIImageView *kuvaView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *playIndikaattori;

@end
