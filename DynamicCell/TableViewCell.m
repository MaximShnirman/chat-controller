//
//  TableViewCell.m
//  DynamicCell
//
//  Created by Maxim Shnirman on 6/30/15.
//  Copyright (c) 2015 Maxim Shnirman. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor redColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
