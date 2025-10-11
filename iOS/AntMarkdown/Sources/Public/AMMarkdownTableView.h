// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <AntMarkdown/AMTableViewAttachment.h>

@class CMTableCell;

NS_ASSUME_NONNULL_BEGIN

/**
 * Markdown 表格单元格协议
 * 定义表格单元格需要实现的基本接口
 */
@protocol AMMarkdownTableCell <NSObject>

/**
 * 单元格数据模型
 */
@property (nonatomic, nullable) CMTableCell *cellData;

/**
 * 计算单元格在指定宽度约束下的尺寸
 * @param cell 单元格数据模型
 * @param width 宽度约束
 * @return 计算得出的单元格尺寸
 */
+ (CGSize)sizeForCell:(CMTableCell *)cell
     constrainedWidth:(CGFloat)width;

@end

@interface AMMarkdownLabelTableCell : UICollectionViewCell <AMMarkdownTableCell>
@property (nonatomic) UILabel * label;
@property (nonatomic) UIEdgeInsets contentInsets;

+ (CGSize)sizeForCell:(CMTableCell *)cell;

@end

@interface AMMarkdownTableCell : UICollectionViewCell <AMMarkdownTableCell>
@property (nonatomic) UITextView *textview;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) BOOL partialUpdate;

+ (CGSize)sizeForCell:(CMTableCell *)cell;

@end

@interface AMMarkdownTableView : UIView <AMTableView, AMAttachedView>
@property (nonatomic) CGFloat maximumColumnWidth;
@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<UIView *> *tableOperationViews;
@property (nonatomic) BOOL partialUpdate;

@property (nonatomic) UIColor *borderColor;

- (instancetype)initWithStyles:(AMTextStyles *)styles NS_DESIGNATED_INITIALIZER;

- (void)didSelectTableCell:(UICollectionView<AMMarkdownTableCell> *)cell content:(CMTableCell *)content;

/**
 * Default is \c AMMarkdownLabelTableCell
 */
+ (Class<AMMarkdownTableCell>)cellClass;

@end

NS_ASSUME_NONNULL_END
