// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import <AntMarkdown/CocoaMarkdown.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AMViewAttachment;
@class AMTextStyles;
@class CMTable;

/**
 * 图片附件构建器协议
 * 用于创建图片类型的文本附件
 */
@protocol AMImageAttachmentBuilder <NSObject>

/**
 * 根据URL和样式构建图片附件
 * @param url 图片URL地址
 * @param title 图片标题（可选）
 * @param styles 文本样式配置
 * @return 构建的图片文本附件
 */
- (NSTextAttachment *)buildWithURL:(NSURL *)url
                             title:(nullable NSString *)title
                            styles:(AMTextStyles *)styles;

@end

/**
 * 表格附件构建器协议
 * 用于创建表格类型的视图附件
 */
@protocol AMTableAttachmentBuilder <NSObject>

/**
 * 根据表格数据和样式构建表格附件
 * @param table 表格数据模型
 * @param styles 文本样式配置
 * @return 构建的表格视图附件
 */
- (NSTextAttachment<AMViewAttachment> *)buildWithTable:(CMTable *)table
                                                styles:(AMTextStyles *)styles;

@end

/**
 * 代码附件构建器协议
 * 用于创建代码块类型的视图附件
 */
@protocol AMCodeAttachmentBuilder <NSObject>

/**
 * 根据代码内容和样式构建代码附件
 * @param code 代码文本内容
 * @param language 编程语言类型（可选）
 * @param styles 文本样式配置
 * @return 构建的代码视图附件
 */
- (NSTextAttachment<AMViewAttachment> *)buildWithCode:(NSString *)code
                                             language:(nullable NSString *)language
                                               styles:(AMTextStyles *)styles;

@end

/**
 * 脚注引用构建器协议
 * 用于创建脚注引用的属性字符串
 */
@protocol AMFootnoteRefBuilder <NSObject>

/**
 * 根据引用信息构建脚注引用字符串
 * @param reference 脚注引用标识
 * @param title 脚注标题
 * @param index 脚注索引
 * @param styles 文本样式配置
 * @return 构建的脚注引用属性字符串
 */
- (NSAttributedString *)buildWithReference:(NSString *)reference
                                     title:(NSString *)title
                                     index:(NSInteger)index
                                    styles:(AMTextStyles *)styles;

@end

@interface AMBuilderBlock : NSObject

+ (id<AMTableAttachmentBuilder>)tableBuilder:(NSTextAttachment<AMViewAttachment> *(^)(CMTable *table, AMTextStyles *styles))block;
+ (id<AMImageAttachmentBuilder>)imageBuilder:(NSTextAttachment *(^)(NSURL *url, NSString * _Nullable title, AMTextStyles *styles))block;
+ (id<AMCodeAttachmentBuilder>)codeBuilder:(NSTextAttachment<AMViewAttachment> *(^)(NSString *code, NSString * _Nullable lang, AMTextStyles *styles))block;
+ (id<AMFootnoteRefBuilder>)footnoteBuilder:(NSAttributedString *(^)(NSString * ref, NSString * title, NSInteger index, AMTextStyles *styles))block;

@end

typedef CMStyleAttributes * _Nonnull (^AMStyleProvider)(NSInteger level);

UIKIT_EXTERN AMStyleProvider AMDefaultProvider(void);

@interface AMTextStyles : CMTextAttributes

+ (instancetype)defaultStyles;
/**
 *  Attributes used to style underline text.
 */
@property (nonatomic) CMStyleAttributes *underlineAttributes;
/**
 *  Attributes used to style strikethrough text.
 */
@property (nonatomic) CMStyleAttributes *strikethroughAttributes;

/**
 *  Attributes used to style foot note reference text.
 */
@property (nonatomic) CMStyleAttributes *footNoteRefAttributes;

/**
 *  Attributes used to style foot note defination text.
 */
@property (nonatomic) CMStyleAttributes *footNoteAttributes;

/**
 *  Attributes used to style table header text.
 */
@property (nonatomic) CMStyleAttributes *tableAttributes;
@property (nonatomic) CMStyleAttributes *tableTitleAttributes;
@property (nonatomic) CMStyleAttributes *tableHeaderAttributes;
@property (nonatomic) CMStyleAttributes *tableCellAttributes;

@property (nonatomic) CMStyleAttributes *listBulletAttributes;

/**
 * when set, the \c orderedListAttributes and \c orderedSublistAttributes is \b ignored
 */
@property (nonatomic, copy, nullable) AMStyleProvider ordererListAttributesProvider;

@property (nonatomic, copy, nullable) AMStyleProvider unordererListAttributesProvider;

/**
 * set class style for html，eg:<span class='highlight'>text</span>
 */
- (void)setAttributes:(CMStyleAttributes *)attributes forClass:(NSString *)className;

- (CMStyleAttributes *)attributesForClass:(NSString *)className;

- (void)addStringAttributes:(NSDictionary<NSAttributedStringKey, id> *)stringAttributes forClass:(NSString *)className;

- (void)addFontAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)fontAttributes forClass:(NSString *)className;

- (void)addParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphAttributes forClass:(NSString *)className;

/**
 * HTML element transformer, you can set custom transformer to instead the default one
 * <s></s> <sup></sup> <sub></sub> <div></div> <mark></mark> <span></span> 
 */
@property (nonatomic, readonly, copy) NSArray <id<CMHTMLElementTransformer> > * elementTransformers;

- (void)addTransformer:(id<CMHTMLElementTransformer>)transformer;

@property (nonatomic, readonly, nullable) id<AMCodeAttachmentBuilder> codeBuilder;

- (void)registerCodeBlockAttachmentBuilder:(id<AMCodeAttachmentBuilder>)builder;

@property (nonatomic, readonly, nullable) id<AMTableAttachmentBuilder> tableBuilder;

- (void)registerTableBlockAttachmentBuilder:(id<AMTableAttachmentBuilder>)builder;

@property (nonatomic, readonly, nullable) id<AMImageAttachmentBuilder> imageBuilder;

- (void)registerImageAttachmentBuilder:(id<AMImageAttachmentBuilder>)builder;

@property (nonatomic, readonly, nullable) id<AMFootnoteRefBuilder> footnoteRefBuilder;

- (void)registerFootnoteRefBuilder:(id<AMFootnoteRefBuilder>)builder;

@property (nonatomic) BOOL highlightCodeOnRender;

/**
 set style object with id
 */
+ (void)setAMStylesWithId:(NSString*)styleId styles:(AMTextStyles*)styles;
/**
 get style object with id
 */
+ (instancetype)getAMStylesWithId:(NSString*)styleId;
/**
 remove style object with id
 */
+ (void)removeAMStylesWithId:(NSString*)styleId;

@end

NS_ASSUME_NONNULL_END
