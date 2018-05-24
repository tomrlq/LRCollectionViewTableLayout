//
//  DemoHeader.m
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/10/15.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import "DemoHeader.h"

@implementation DemoHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGRect headerRect = self.bounds;
        
        CGRect labelFrame = CGRectMake(16, 0,
                                       headerRect.size.width / 2.0 - 16,
                                       headerRect.size.height);
        
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        self.label = label;
        label.font = [UIFont systemFontOfSize:14];
        [label setAutoresizingMask:(UIViewAutoresizingFlexibleHeight |
                                    UIViewAutoresizingFlexibleRightMargin)];
        [self addSubview:label];
        
        CGRect detailFrame = CGRectMake(headerRect.size.width / 2.0,
                                        0,
                                        headerRect.size.width / 2.0 - 16,
                                        headerRect.size.height);
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
        self.detailLabel = detailLabel;
        detailLabel.font = [UIFont systemFontOfSize:14];
        [detailLabel setTextAlignment:NSTextAlignmentRight];
        [detailLabel setAutoresizingMask:(UIViewAutoresizingFlexibleHeight |
                                          UIViewAutoresizingFlexibleLeftMargin)];
        [self addSubview:detailLabel];
        
        UIView *seperator = [[UIView alloc] init];
        seperator.backgroundColor = [UIColor lightGrayColor];
        seperator.frame = CGRectMake(0,
                                     headerRect.size.height - 0.5,
                                     headerRect.size.width,
                                     0.5);
        [seperator setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin)];
        [self addSubview:seperator];
    }
    return self;
}

@end
