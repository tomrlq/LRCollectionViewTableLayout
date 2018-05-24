//
//  LRCollectionTableLayout.m
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/9/28.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import "LRCollectionTableLayout.h"

@interface LRCollectionTableLayout ()
{
    NSMutableArray *attributesOfCells;      // 所有 cell 的 attributes
    NSMutableArray *attributesOfHeaders;    // 所有 header 的 attributes
    float collectionViewWidth;      // collectionView 的宽度
    CGSize contentSize;     // collectonView 的 contentSize
    BOOL isInitializing;    // 是否正在初始化
    BOOL isReloading;       // 是否重新加载数据源
    BOOL isTransiting;      // header 的索引是否处于过渡状态
    int headerIndex;        // 当前的 header 索引
    int *headerRows;        // 各个 header 所在的行
    float *headerMinYs;     // 各个 header 的最小Y坐标
    float *headerHeights;   // 各个 header 的高度
}
@end

@implementation LRCollectionTableLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        attributesOfCells = [NSMutableArray array];
        attributesOfHeaders = [NSMutableArray array];
        isInitializing = YES;
        isTransiting = YES;
        headerIndex = -1;
        headerRows = NULL;
        headerMinYs = NULL;
        headerHeights = NULL;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    // 判断 collectionView 是否有 reloadData
    int numberOfRows = (int)[self.collectionView numberOfSections];
    if (numberOfRows == 0) {
        return;
    }
    int numberOfColumns = (int)[self.collectionView numberOfItemsInSection:0];
    if (!isInitializing &&
        (numberOfRows != (int)[attributesOfCells count] ||
         numberOfColumns != (int)[attributesOfCells[0] count])) {
        isInitializing = YES;
    }
    
    // collectionView 的相关属性
    float leftInset = (float)self.collectionView.contentInset.left;
    float topInset = (float)self.collectionView.contentInset.top;
    if (@available(iOS 11, *)) {
        topInset = (float)self.collectionView.adjustedContentInset.top;
    }
    float firstRowHeight = [self.delegate layout:self heightOfRow:0];
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    // 让第一行、第一列、header、随着 collectionView 滚动
    if (!isInitializing) {
        // 保持第一列的位置
        int numberOfRows = (int)[self.collectionView numberOfSections];
        for (int i = 0; i < numberOfRows; i++) {
            UICollectionViewLayoutAttributes *attributes = attributesOfCells[i][0];
            CGRect frame = attributes.frame;
            frame.origin.x = contentOffset.x + leftInset;
            attributes.frame = frame;
        }
        // 保持第一行的位置
        int numberOfColumns = (int)[self.collectionView numberOfItemsInSection:0];
        for (int i = 0; i < numberOfColumns; i++) {
            UICollectionViewLayoutAttributes *attributes = attributesOfCells[0][i];
            CGRect frame = attributes.frame;
            frame.origin.y = contentOffset.y + topInset;
            attributes.frame = frame;
        }
        // 保持 header 的X坐标随着 collectionView 横向滚动
        for (int i = 0; i < (int)attributesOfHeaders.count; i++) {
            UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[i];
            CGRect frame = attributes.frame;
            frame.origin.x = contentOffset.x + leftInset;
            attributes.frame = frame;
        }
        // 索引值进入过渡状态
        if (!isTransiting &&
            headerIndex < (int)attributesOfHeaders.count - 1 &&
            contentOffset.y >= (headerMinYs[headerIndex + 1] - headerHeights[headerIndex] - firstRowHeight - topInset)) {
            isTransiting = YES;
            UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[headerIndex];
            CGRect frame = attributes.frame;
            frame.origin.y = headerMinYs[headerIndex + 1] - headerHeights[headerIndex];
            attributes.frame = frame;
        }
        // 增加 header 索引值
        if (headerIndex < (int)attributesOfHeaders.count - 1 &&
            contentOffset.y >= (headerMinYs[headerIndex + 1] - firstRowHeight - topInset)) {
            isTransiting = NO;
            headerIndex++;
        }
        // 减少 header 索引值
        if (headerIndex >= 0 &&
            contentOffset.y < (headerMinYs[headerIndex] - firstRowHeight - topInset)) {
            isTransiting = YES;
            headerIndex--;
            UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[headerIndex + 1];
            CGRect frame = attributes.frame;
            frame.origin.y = headerMinYs[headerIndex + 1];
            attributes.frame = frame;
        }
        // 索引值退出过渡状态
        if (isTransiting &&
            headerIndex >= 0 &&
            contentOffset.y < (headerMinYs[headerIndex + 1] - headerHeights[headerIndex] - firstRowHeight - topInset)) {
            isTransiting = NO;
        }
        // 保持 header 的Y坐标随着 collectionView 纵向滚动
        if (headerIndex >= 0 && !isTransiting) {
            UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[headerIndex];
            CGRect frame = attributes.frame;
            frame.origin.y = contentOffset.y + topInset + firstRowHeight;
            attributes.frame = frame;
        }
        // 保持 header 的宽度与 collectionView 宽度一致
        if (collectionViewWidth != (float)self.collectionView.bounds.size.width) {
            collectionViewWidth = (float)self.collectionView.bounds.size.width;
            for (UICollectionViewLayoutAttributes *attributes in attributesOfHeaders) {
                CGRect frame = attributes.frame;
                frame.size.width = collectionViewWidth;
                attributes.frame = frame;
            }
        }
        return;
    }
    
    /*
        下面的代码只会在初始化的时候执行一次
     */
    if (isInitializing) {
        float offsetX = 0.0;
        float offsetY = 0.0;
        collectionViewWidth = (float)self.collectionView.bounds.size.width;
        [attributesOfCells removeAllObjects];
        [attributesOfHeaders removeAllObjects];
        // 枚举每一行的 attributes
        for (int row = 0; row < numberOfRows; row++) {
            // 是否添加 header
            float headerHeight = [self.delegate layout:self heightForHeaderInRow:row];
            if (headerHeight > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:row];
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
                attributes.frame = CGRectMake(offsetX, offsetY, collectionViewWidth, headerHeight);
                attributes.zIndex = 3;
                [attributesOfHeaders addObject:attributes];
                offsetY += headerHeight;
            }
            // 行高
            float rowHeight = [self.delegate layout:self heightOfRow:row];
            NSMutableArray *attributesInRow = [NSMutableArray array];
            // 枚举该行中每一个 Cell 的 attributes
            for (int column = 0; column < numberOfColumns; column++) {
                float columnWidth = [self.delegate layout:self widthOfColumn:column];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:column inSection:row];
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = CGRectMake(offsetX, offsetY, columnWidth, rowHeight);
                if (row == 0 && column == 0) {
                    attributes.zIndex = 5;
                } else if (row == 0) {
                    attributes.zIndex = 4;
                } else if (column == 0) {
                    attributes.zIndex = 2;
                }
                [attributesInRow addObject:attributes];
                offsetX += columnWidth;
            }
            [attributesOfCells addObject:attributesInRow];
            offsetX = 0.0;
            offsetY += rowHeight;
        }
        // 获取整个 collectionView 的 contentSize
        UICollectionViewLayoutAttributes *lastAttributes = [[attributesOfCells lastObject] lastObject];
        contentSize = CGSizeMake(CGRectGetMaxX(lastAttributes.frame),
                                 CGRectGetMaxY(lastAttributes.frame));
        // 所有 header 的 Y坐标
        if ([attributesOfHeaders count] > 0) {
            headerRows = realloc(headerRows, sizeof(int) * (int)attributesOfHeaders.count);
            headerMinYs = realloc(headerMinYs, sizeof(float) * (int)attributesOfHeaders.count);
            headerHeights = realloc(headerHeights, sizeof(float) * (int)attributesOfHeaders.count);
            for (int i = 0; i < (int)attributesOfHeaders.count; i++) {
                UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[i];
                headerRows[i] = (int)attributes.indexPath.section;
                headerMinYs[i] = (float)CGRectGetMinY(attributes.frame);
                headerHeights[i] = (float)CGRectGetHeight(attributes.frame);
            }
        }
        // 调整 header 的索引值
        for (headerIndex = -1; headerIndex < (int)attributesOfHeaders.count - 1; headerIndex ++) {
            if (contentOffset.y < headerMinYs[headerIndex + 1] - firstRowHeight - topInset) {
                break;
            }
        }
        // 根据 header 的索引值调整坐标
        for (int i = 0; i < headerIndex; i++) {
            UICollectionViewLayoutAttributes *attributes = attributesOfHeaders[i];
            CGRect frame = attributes.frame;
            frame.origin.x = contentOffset.x + leftInset;
            frame.origin.y = headerMinYs[i + 1] - headerHeights[i];
            attributes.frame = frame;
        }
        if (headerIndex >= 0) {
            isTransiting = NO;
        }
        isInitializing = NO;
        [self prepareLayout];
    }
}

- (CGSize)collectionViewContentSize {
    return contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *visiableAttributes = [NSMutableArray array];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, evaluatedObject.frame);
    }];
    // 所有可见 Cell 的 attributes
    for (NSArray *attributesInRow in attributesOfCells) {
        NSArray *visiableAttributesInRow = [attributesInRow filteredArrayUsingPredicate:predicate];
        [visiableAttributes addObjectsFromArray:visiableAttributesInRow];
    }
    // 所有可见 header 的 attributes
    NSArray *visiableAttributesOfHeaders = [attributesOfHeaders filteredArrayUsingPredicate:predicate];
    [visiableAttributes addObjectsFromArray:visiableAttributesOfHeaders];
    return visiableAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return attributesOfCells[indexPath.section][indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        int key = (int)indexPath.section;
        // 二分查找
        int *value = bsearch_b(&key, headerRows, (int)attributesOfHeaders.count, sizeof(int), ^int(const void *num1, const void *num2) {
            return *(int *)num1 - *(int *)num2;
        });
        if (value != NULL) {
            int index = (int)(value - headerRows);
            return attributesOfHeaders[index];
        }
    }
    return nil;
}

- (void)dealloc {
    free(headerRows);
    free(headerMinYs);
    free(headerHeights);
}

@end
