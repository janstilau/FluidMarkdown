// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMMarkdownTableLayout.h"


@interface AMSizeConstraint : NSObject
@property (nonatomic) CGSize minSize;
@property (nonatomic) CGSize maxSize;
@end

@implementation AMSizeConstraint

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        self.maxSize = CGSizeZero;
    }
    return self;
}

- (void)updateSize:(CGSize)size
{
    CGSize s = self.minSize;
    s.width = MIN(self.minSize.width, size.width);
    s.height = MIN(self.minSize.height, size.height);
    self.minSize = s;
    
    s = self.maxSize;
    s.width = MAX(self.maxSize.width, size.width);
    s.height = MAX(self.maxSize.height, size.height);
    self.maxSize = s;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"min: %@, max: %@", NSStringFromCGSize(self.minSize), NSStringFromCGSize(self.maxSize)];
}

@end


@implementation AMMarkdownTableLayout
{
    // 每列的尺寸约束（聚合该列所有行的 min/max 尺寸），用于同列内同宽
    NSMutableArray <AMSizeConstraint *> * _columnConstraint;
    // 每行的尺寸约束（聚合该行所有列的 min/max 尺寸），用于统一行高
    NSMutableArray <AMSizeConstraint *> * _rowConstraint;
    // 委托测量得到的每个 cell 的“内容所需尺寸”缓存
    NSMutableDictionary <NSIndexPath *, NSValue *> * _sizeCache;
    // 所有布局属性的二维数组 [section][item]
    NSMutableArray <NSArray <UICollectionViewLayoutAttributes *> *> * _allAttributes;
    // 最终内容总尺寸（供 collectionViewContentSize 返回）
    CGSize  _contentSize;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _columnConstraint = [NSMutableArray array];
        _rowConstraint = [NSMutableArray array];
        _sizeCache = [NSMutableDictionary dictionary];
        _allAttributes = [NSMutableArray array];
        
        _minimumLineSpacing = 1;
        _minimumInteritemSpacing = 1;
        _minimumRowHeight = 35;
        _maximumColumnWidth = 360;
        _fillWidth = YES;
    }
    return self;
}

- (void)setMaximumColumnWidth:(CGFloat)maximumColumnWidth
{
    if (_maximumColumnWidth != maximumColumnWidth) {
        _maximumColumnWidth = maximumColumnWidth;
        [self invalidateLayout];
    }
}

- (void)setMinimumRowHeight:(CGFloat)minimumRowHeight
{
    if (_minimumRowHeight != _minimumRowHeight) {
        _minimumRowHeight = minimumRowHeight;
        [self invalidateLayout];
    }
}

- (void)setFillWidth:(BOOL)fillWidth
{
    if (_fillWidth != fillWidth) {
        _fillWidth = fillWidth;
        [self invalidateLayout];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    if (_minimumLineSpacing != minimumLineSpacing) {
        _minimumLineSpacing = minimumLineSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    if (_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 清空上次布局数据，准备重新计算
    [_columnConstraint removeAllObjects];
    [_rowConstraint removeAllObjects];
    [_sizeCache removeAllObjects];
    [_allAttributes removeAllObjects];
    
    CGSize contentSize = CGSizeZero;
    
    NSInteger sections = self.collectionView.numberOfSections;
    NSInteger columns = 0;
    for (int s = 0; s < sections; s ++) {
        NSInteger col = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:s];
        
        for (int c = 0; c < col; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView
                                                                                                        layout:self
                                                                                        sizeForItemAtIndexPath:indexPath];
            // 在这里, 将所有的 item 所占用的空间都计算出来了.
            _sizeCache[indexPath] = [NSValue valueWithCGSize:size];
        }
        
        if (columns < col) {
            columns = col;
        }
    }
    
    CGFloat totalWidth = 0;
    // 按列聚合：统计该列所有行的内容尺寸，得到该列的最大需要宽度（maxSize.width）
    for (int c = 0; c < columns; c ++) {
        AMSizeConstraint *constraint = [[AMSizeConstraint alloc] init];
        for (int s = 0; s < sections; s ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = _sizeCache[indexPath].CGSizeValue;
            [constraint updateSize:size];
        }
        // 计算总宽（含列间距），用于后续是否需要填满容器
        totalWidth += constraint.maxSize.width + self.minimumInteritemSpacing;
        [_columnConstraint addObject:constraint];
    }
    totalWidth -= self.minimumInteritemSpacing;
    
    // 按行聚合：统计该行所有列的内容尺寸，得到该行的最大需要高度（maxSize.height）
    for (int s = 0; s < sections; s ++) {
        AMSizeConstraint *constraint = [[AMSizeConstraint alloc] init];
        for (int c = 0; c < columns; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = _sizeCache[indexPath].CGSizeValue;
            [constraint updateSize:size];
        }
        [_rowConstraint addObject:constraint];
    }
    
    const CGFloat fullWidth = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size.width;
    BOOL ignoreMaxWidth = NO;

    // 如果总宽小于可用宽且允许填充（fillWidth），则按比例放大各列宽以“填满容器”
    if (totalWidth < fullWidth && self.fillWidth) {
        ignoreMaxWidth = YES;
        const CGFloat spacing = self.minimumInteritemSpacing * (columns - 1);
        for (int c = 0; c < columns; c ++) {
            AMSizeConstraint *constraint = _columnConstraint[c];
            CGSize size = constraint.maxSize;
            size.width = size.width / (totalWidth - spacing) * (fullWidth - spacing);
            [constraint updateSize:size];
        }
    }
    
    const CGPoint initialOffset = CGPointZero;
    CGPoint offset = initialOffset;
    for (int s = 0; s < sections; s ++) {
        NSInteger col = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:s];
        AMSizeConstraint *rowConstraint = _rowConstraint[s];
        const CGFloat height = MAX(rowConstraint.maxSize.height, self.minimumRowHeight);
        
        NSMutableArray<UICollectionViewLayoutAttributes *> *arr = [NSMutableArray arrayWithCapacity:columns];
        for (int c = 0; c < col; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            AMSizeConstraint *colConstraint = _columnConstraint[c];
            // 同列内同宽：列宽取该列的 maxSize.width；若未填充，则受 maximumColumnWidth 限制
            const CGFloat width = MIN(colConstraint.maxSize.width, ignoreMaxWidth ? CGFLOAT_MAX : self.maximumColumnWidth);
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = CGRectMake(offset.x, offset.y, width, height);
            [arr addObject:attr];
            
            offset.x += width + self.minimumInteritemSpacing;
        }
        // 记录内容宽度（去除最后一个间距）
        contentSize.width = MAX(contentSize.width, offset.x - self.minimumInteritemSpacing);
        
        offset.x = initialOffset.x;
        offset.y += height + self.minimumLineSpacing;
        [_allAttributes addObject:arr.copy];
    }
    // 记录内容高度（去除最后一行的行距）
    contentSize.height = offset.y - self.minimumLineSpacing;
    
    _contentSize = contentSize;
}
/*
 实现思路

 - 列内同宽是由布局类 AMMarkdownTableLayout 在 prepareLayout 里实现的：它先对每个单元格调用 sizeForItemAtIndexPath: 计算“内容所需尺寸”，缓存到 _sizeCache 。
 - 然后按列汇总一轮，给每一列建立一个 AMSizeConstraint ，遍历该列的所有行，持续 updateSize: ，得到该列的“最大需要宽度” constraint.maxSize.width 。
 - 在真正排版时（逐行逐列生成 UICollectionViewLayoutAttributes ），每个单元格的 frame 宽度都取该列的 maxSize.width ，并做上限裁剪： width = MIN(colConstraint.maxSize.width, ignoreMaxWidth ? CGFLOAT_MAX : self.maximumColumnWidth) 。因此同一列所有行的单元格宽度一致。
 */

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray <UICollectionViewLayoutAttributes *> * result = [NSMutableArray array];
    [_allAttributes enumerateObjectsUsingBlock:^(NSArray<UICollectionViewLayoutAttributes *> * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        [section enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(rect, item.frame)) {
                [result addObject:item];
            }
        }];
    }];
    return [result copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _allAttributes[indexPath.section][indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size)) {
        return NO;
    }
    // 容器尺寸变化时，如启用填充，需要重新等比例分配列宽
    return self.fillWidth;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = _contentSize;
    return size;
}

@end
