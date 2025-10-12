// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AMViewAttachment.h>

@class CMTable;
@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

/**
 * 表格视图协议
 * 定义表格视图组件需要实现的基本接口
 */
@protocol AMTableView <NSObject>

/**
 * 表格数据模型
 */
@property (nonatomic) CMTable *table;

@optional
/**
 * 使用样式初始化表格视图（可选实现）
 * @param styles 文本样式配置
 * @return 初始化的表格视图实例
 */
- (instancetype)initWithStyles:(AMTextStyles *)styles;

/**
 * 计算表格视图所需尺寸（可选实现）
 * @param size 限制尺寸
 * @param table 表格数据模型
 * @param styles 样式配置
 * @return 计算得出的尺寸
 */
+ (CGSize)sizeThatFits:(CGSize)size table:(CMTable *)table styles:(AMTextStyles *)styles;

@end

/**
 * AMTableViewAttachment 是 AMViewAttachment 的子类，用于在富文本中嵌入表格视图。
 * 支持多行多列的表格数据显示，包括表头、表格边框和单元格样式设置。
 * 主要用于 Markdown 表格语法的渲染，提供完整的表格显示功能。
 * 
 * 对应的 Markdown 语法示例：
 * ```
 * | 姓名 | 年龄 | 城市 |
 * |------|------|------|
 * | 张三 | 25   | 北京 |
 * | 李四 | 30   | 上海 |
 * | 王五 | 28   | 广州 |
 * 
 * | 左对齐 | 居中对齐 | 右对齐 |
 * |:-------|:--------:|-------:|
 * | 内容1  |   内容2  |  内容3 |
 * | 数据A  |   数据B  |  数据C |
 * ```
 */
@interface AMTableViewAttachment : AMViewAttachment
@property (nonatomic, readonly, nullable) UIView<AMTableView> *view;
@property (nonatomic) BOOL partialUpdate;
@property (nonatomic) CMTable *table;
@property (nonatomic, readonly, nullable) AMTextStyles *styles;

+ (Class<AMTableView>)tableViewClass;    // Default is AMMarkdownTableView

- (instancetype)initWithTable:(CMTable *)table styles:(AMTextStyles *)styles;

@end

NS_ASSUME_NONNULL_END
