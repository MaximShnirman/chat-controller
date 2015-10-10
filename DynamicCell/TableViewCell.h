//
//  TableViewCell.h
//  DynamicCell
//
//  Created by Maxim Shnirman on 6/30/15.
//  Copyright (c) 2015 Maxim Shnirman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgBobble;
@property (strong, nonatomic) IBOutlet UILabel *lblText;
@end
