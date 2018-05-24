//
//  DemoContentCell.m
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/9/28.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import "DemoContentCell.h"

@implementation DemoContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGRect cellRect = self.contentView.bounds;
        
        UILabel *label = [[UILabel alloc] initWithFrame:cellRect];
        self.label = label;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:11];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight)];
        [self.contentView addSubview:label];
        
        UIView *hSeperator = [[UIView alloc] init];
        hSeperator.backgroundColor = [UIColor lightGrayColor];
        hSeperator.frame = CGRectMake(0,
                                      cellRect.size.height - 0.5,
                                      cellRect.size.width,
                                      0.5);
        [hSeperator setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleTopMargin)];
        [self.contentView addSubview:hSeperator];
        
        UIView *vSeperator = [[UIView alloc] init];
        vSeperator.backgroundColor = [UIColor lightGrayColor];
        vSeperator.frame = CGRectMake(cellRect.size.width - 0.5,
                                      0,
                                      0.5,
                                      cellRect.size.height);
        [vSeperator setAutoresizingMask:(UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleLeftMargin)];
        [self.contentView addSubview:vSeperator];
    }
    return self;
}

@end
