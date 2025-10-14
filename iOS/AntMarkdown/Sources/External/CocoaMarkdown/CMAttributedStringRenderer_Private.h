// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMAttributedStringRenderer.h"
#import "CMCascadingAttributeStack.h"
#import "CMParser.h"
#import "CMStack.h"

NS_ASSUME_NONNULL_BEGIN

// 原理这种, 在默认分类里面, 添加私有方法的方式, 在很多地方都会用到了. 
@interface CMAttributedStringRenderer () <CMParserDelegate>
{
@protected
    // 解析与渲染所需的核心对象与缓冲
    CMDocument *_document;
    // 渲染样式属性（字体、颜色、段落样式等），用于级联生效
    CMTextAttributes *_attributes;
    // 栈式管理的样式集合，支持 push/pop 控制嵌套样式
    CMCascadingAttributeStack *_attributeStack;
    // HTML 元素处理栈，用于累积、延迟或转换 HTML 片段
    CMStack *_HTMLStack;
    // HTML 标签名到转换器的映射表（同标签仅保留一个转换器）
    NSMutableDictionary *_tagNameToTransformerMapping;
    // 主渲染输出缓冲区，累积生成的富文本内容
    NSMutableAttributedString *_buffer;
    // 渲染完成后的只读富文本副本
    NSAttributedString *_attributedString;
    // 可点击元素的收集容器（链接、脚注引用等）
    NSMutableArray*    _clickableObjs;
    // 表格单元格专用缓冲区（在表格上下文中使用）
    NSMutableAttributedString * _tableCellBuffer;
	// 段落级样式临时缓存：颜色
	UIColor* paragraphColor;
    // 段落级样式临时缓存：字体
    UIFont* paragraphFont;
    // 段落间距（after）
    CGFloat paragrahpSpace;
    // 段前间距（before）
    CGFloat paragrahpSpaceBofore;
    // 引用层级计数（用于 blockquote 嵌套）
    NSInteger quoteLevel;
}
// 只读访问当前文档对象
@property (readonly) CMDocument *document;
// 只读访问文本样式属性集合
@property (readonly) CMTextAttributes *attributes;
// 只读访问样式栈（用于管理当前生效的样式）
@property (readonly) CMCascadingAttributeStack *attributeStack;
// 只读访问 HTML 处理栈
@property (readonly) CMStack *HTMLStack;
// 只读访问标签到转换器的映射关系
@property (readonly) NSMutableDictionary *tagNameToTransformerMapping;
// 只读访问输出富文本缓冲区
@property (readonly) NSMutableAttributedString *buffer;
// 可点击元素回调代理（位置与内容通知）
@property (nonatomic, weak)id<CMAttributedStringRendererDelegate> delegate;

/// 追加普通字符串到当前缓冲（受样式栈影响）
- (void)appendString:(NSString *)string;

/// 根据图片 URL 与标题创建文本附件（内联图片）
- (NSTextAttachment *)imageAttachmentWithURL:(NSURL *)url title:(NSString *)title;

/// 追加列表项目的符号文本（bullet/编号等），按列表样式属性渲染
- (void)appendBulletString:(NSString *)string;

/// 关闭当前节点对应的块级上下文（如段落、列表、引用等）
- (void)closeBlockForNode:(CMNode *)currentNode;

/// 记录可点击对象信息（类型、数据与标记），用于后续 UI 通知
-(void)addClickableObjects:(CMNodeType)type data:(NSString*)data tag:(NSString*)tag;

/// 获取当前有序列表的下一个序号（考虑嵌套与起始序号）
-(NSInteger)getOrderListNumber;
@end

NS_ASSUME_NONNULL_END
