//
//  DemoCollectionViewController.m
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/9/28.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import "DemoCollectionViewController.h"
#import "DemoContentCell.h"
#import "DemoHeader.h"
#import "LRCollectionTableLayout.h"

#define SCREEN_SIZE     [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH    SCREEN_SIZE.width
#define SCREEN_HEIGHT   SCREEN_SIZE.height

typedef enum : unsigned int {
    ScrollDirectionNone,
    ScrollDirectionVertical,
    ScrollDirectionHorizontal,
} ScrollDirection;

@interface DemoCollectionViewController () <LRCollectionTableLayoutDelegate>
{
    int numberOfGroups;
    int numberOfColumns;
    int *numberOfRowsInGroup;
    int *beginRowOfGroup;
    CGPoint startPosition;
    ScrollDirection scrollDirection;
    int numberOfItemsPerSection;
}
@end

@implementation DemoCollectionViewController

static NSString * const reuseIdentifier = @"DemoContentCell";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    LRCollectionTableLayout *tableLayout = [[LRCollectionTableLayout alloc] init];
    tableLayout.delegate = self;
    self = [super initWithCollectionViewLayout:tableLayout];
    if (self) {
        numberOfGroups = 5;
        numberOfColumns = 15;
        numberOfRowsInGroup = malloc(sizeof(int) * numberOfGroups);
        for (int i = 0; i < numberOfGroups; i++) {
            numberOfRowsInGroup[i] = [self numberOfRowsInGroup:i];
        }
        beginRowOfGroup = malloc(sizeof(int) * numberOfGroups);
        int sumOfRows = 1;
        for (int i = 0; i < numberOfGroups; i++) {
            beginRowOfGroup[i] = sumOfRows;
            sumOfRows += numberOfRowsInGroup[i];
        }
        
        UIBarButtonItem *reloadItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                          target:self
                                                          action:@selector(refresh:)];
        self.navigationItem.rightBarButtonItem = reloadItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    // Register cell classes
    [self.collectionView registerClass:[DemoContentCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[DemoHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"DemoHeader"];
//    self.collectionView.directionalLockEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    float firstColumnWidth = [self layout:nil widthOfColumn:0];
    float columnWidth = [self layout:nil widthOfColumn:1];
    float collectionWidth = self.collectionView.bounds.size.width;
    int numberOfCellsInWidth = (int)ceilf((collectionWidth - firstColumnWidth) / columnWidth);
    numberOfItemsPerSection = MAX(numberOfCellsInWidth, numberOfColumns + 1);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    float firstColumnWidth = [self layout:nil widthOfColumn:0];
    float columnWidth = [self layout:nil widthOfColumn:1];
    float collectionWidth = size.width;
    int numberOfCellsInWidth = (int)ceilf((collectionWidth - firstColumnWidth) / columnWidth);
    numberOfItemsPerSection = MAX(numberOfCellsInWidth + 1, numberOfColumns + 2);
    int currentNumberOfItems = (int)[self.collectionView numberOfItemsInSection:0];
    NSLog(@"numberOfItemsPerSection: %d", numberOfItemsPerSection);
    NSLog(@"currentNumberOfItems: %d", currentNumberOfItems);
    if (numberOfItemsPerSection != currentNumberOfItems) {
        [self.collectionView reloadData];
        CGPoint contentOffset = self.collectionView.contentOffset;
        if (contentOffset.y > 10) {
            contentOffset.y -= 2;
        } else {
            contentOffset.y += 2;
        }
        [self.collectionView setContentOffset:contentOffset animated:YES];
    }
}

- (void)dealloc {
    free(numberOfRowsInGroup);
    free(beginRowOfGroup);
}

#pragma mark - UICollectionViewDataSource

- (int)numberOfRowsInGroup:(int)group {
    switch (group) {
        case 0:
            return 18;
        case 1:
            return 13;
        case 2:
        case 3:
        case 4:
            return 10;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    int lastGroup = numberOfGroups - 1;
    return beginRowOfGroup[lastGroup] + numberOfRowsInGroup[lastGroup];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfItemsPerSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DemoContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            cell.label.text = @"固定";
            cell.backgroundColor = [UIColor greenColor];
        } else if (indexPath.item <= numberOfColumns) {
            cell.label.text = [NSString stringWithFormat:@"车辆 %d", (int)indexPath.item - 1];
            cell.backgroundColor = [UIColor cyanColor];
        } else {
            cell.label.text = nil;
            cell.backgroundColor = [UIColor cyanColor];
        }
    } else {
        int group = 0;
        for (int i = 0; i < numberOfGroups; i++) {
            if (indexPath.section < beginRowOfGroup[i]) {
                break;
            }
            group = i;
        }
        int row = (int)indexPath.section - beginRowOfGroup[group];
        int column = (int)indexPath.item - 1;
        if (indexPath.item == 0) {
            cell.label.text = [NSString stringWithFormat:@"参数 %d", row];
            cell.backgroundColor = [UIColor yellowColor];
        } else if (indexPath.item <= numberOfColumns) {
            cell.label.text = [NSString stringWithFormat:@"车辆：%d\n类别：%d\n参数：%d", column, group, row];
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.label.text = nil;
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        for (int i = 0; i < numberOfGroups; i++) {
            if (indexPath.section == beginRowOfGroup[i]) {
                DemoHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DemoHeader" forIndexPath:indexPath];
                header.label.text = [NSString stringWithFormat:@"类别：%d", i];
                header.detailLabel.text = @"Detail";
                return header;
            }
        }
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 确定 collectionView 的滚动方向
    if (scrollDirection == ScrollDirectionNone){
        if (fabsf((float)startPosition.x - (float)scrollView.contentOffset.x) <
            fabsf((float)startPosition.y - (float)scrollView.contentOffset.y)){
            scrollDirection = ScrollDirectionVertical;
        } else {
            scrollDirection = ScrollDirectionHorizontal;
        }
    }
    // 使 collectionView 沿确定好的方向滚动
    if (scrollDirection == ScrollDirectionVertical) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.x = startPosition.x;
        scrollView.contentOffset = contentOffset;
    } else if (scrollDirection == ScrollDirectionHorizontal){
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = startPosition.y;
        scrollView.contentOffset = contentOffset;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    startPosition = scrollView.contentOffset;
    scrollDirection = ScrollDirectionNone;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrollDirection = ScrollDirectionNone;
}

#pragma mark - LRCollectionTableLayoutDelegate

- (float)layout:(LRCollectionTableLayout *)tableLayout heightOfRow:(int)row {
    switch (row) {
        case 0:
            return 60 * SCREEN_WIDTH / 320.0;
        default:
            return 40 * SCREEN_WIDTH / 320.0;
    }
}

- (float)layout:(LRCollectionTableLayout *)tableLayout widthOfColumn:(int)column {
    switch (column) {
        case 0:
            return 56 * SCREEN_WIDTH / 320.0;
        default:
            return 80 * SCREEN_WIDTH / 320.0;
    }
}

- (float)layout:(LRCollectionTableLayout *)tableLayout heightForHeaderInRow:(int)row {
    for (int i = 0; i < numberOfGroups; i++) {
        if (row == beginRowOfGroup[i]) {
            return 30 * SCREEN_WIDTH / 320.0;
        } else if (row < beginRowOfGroup[i]) {
            return 0;
        }
    }
    return 0;
}

#pragma mark - Actions

- (void)refresh:(UIBarButtonItem *)item {
    [self.collectionView reloadData];
}

@end
