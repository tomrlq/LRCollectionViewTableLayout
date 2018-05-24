//
//  LRCollectionTableLayout.h
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/9/28.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LRCollectionTableLayoutDelegate;

/**
 *  Table布局，
 *  CollectionView 的 section 是 table 的 row，
 *  CollectionView 的 item 是 table 的 column
 */
@interface LRCollectionTableLayout : UICollectionViewLayout
@property (nonatomic, weak) id<LRCollectionTableLayoutDelegate> delegate;
@end

/// Table布局的委托协议
@protocol LRCollectionTableLayoutDelegate <NSObject>
/// 某行的高度
- (float)layout:(LRCollectionTableLayout *)tableLayout heightOfRow:(int)row;
/// 某列的宽度
- (float)layout:(LRCollectionTableLayout *)tableLayout widthOfColumn:(int)column;
/// 某行的 header 的高度，返回 0 将不会添加 header，kind 是 UICollectionElementKindSectionHeader
- (float)layout:(LRCollectionTableLayout *)tableLayout heightForHeaderInRow:(int)row;
@end
