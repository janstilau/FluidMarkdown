
//
//  UITextView_zh.h
//  带中文注释版 UITextView 头文件
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextInput.h>
#import <UIKit/NSLayoutManager.h>

NS_ASSUME_NONNULL_BEGIN

/// UITextView：可滚动的多行文本视图，支持富文本、选择、输入和布局管理
UIKIT_EXTERN API_AVAILABLE(ios(2.0)) API_UNAVAILABLE(watchos) NS_SWIFT_UI_ACTOR
@interface UITextView : UIScrollView <UITextInput, UIContentSizeCategoryAdjusting, UILetterformAwareAdjusting>

/// 代理对象
@property(nullable,nonatomic,weak) id<UITextViewDelegate> delegate;

/// 文本内容
@property(null_resettable,nonatomic,copy) NSString *text;

/// 字体
@property(nullable,nonatomic,strong) UIFont *font;

/// 文本颜色
@property(nullable,nonatomic,strong) UIColor *textColor;

/// 文本对齐方式，默认左对齐
@property(nonatomic) NSTextAlignment textAlignment;

/// 选中范围
@property(nonatomic) NSRange selectedRange;

/// 是否可编辑
@property(nonatomic,getter=isEditable) BOOL editable API_UNAVAILABLE(tvos);

/// 是否可选择，控制用户是否能选择文本和交互链接或附件
@property(nonatomic,getter=isSelectable) BOOL selectable API_AVAILABLE(ios(7.0));

/// 数据检测类型（电话、网址等）
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes API_AVAILABLE(ios(3.0)) API_UNAVAILABLE(tvos);

/// 是否允许编辑属性（富文本属性）
@property(nonatomic) BOOL allowsEditingTextAttributes API_AVAILABLE(ios(6.0));

/// 富文本内容
@property(null_resettable,copy) NSAttributedString *attributedText API_AVAILABLE(ios(6.0));

/// 当前输入属性（键入属性）
@property(nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *typingAttributes API_AVAILABLE(ios(6.0));

/// 滚动到指定文本范围
- (void)scrollRangeToVisible:(NSRange)range;

/// 输入视图（键盘或自定义视图）
@property (nullable, readwrite, strong) UIView *inputView;

/// 输入附件视图
@property (nullable, readwrite, strong) UIView *inputAccessoryView API_UNAVAILABLE(visionos);

/// 插入文本时是否清空原内容
@property(nonatomic) BOOL clearsOnInsertion API_AVAILABLE(ios(6.0));

/// 使用指定 NSTextContainer 初始化 UITextView
- (instancetype)initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer API_AVAILABLE(ios(7.0)) NS_DESIGNATED_INITIALIZER;

/// 指定是否使用 TextKit 2 NSTextLayoutManager
+ (instancetype)textViewUsingTextLayoutManager:(BOOL)usingTextLayoutManager API_AVAILABLE(ios(16.0), tvos(16.0)) API_UNAVAILABLE(watchos);

/// 从归档初始化
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 获取文本容器
@property(nonatomic, readonly) NSTextContainer *textContainer API_AVAILABLE(ios(7.0));

/// 文本容器内边距
@property(nonatomic, assign) UIEdgeInsets textContainerInset API_AVAILABLE(ios(7.0));

/// TextKit 2 布局管理器
@property(nonatomic, nullable, readonly) NSTextLayoutManager *textLayoutManager API_AVAILABLE(ios(16.0), tvos(16.0)) API_UNAVAILABLE(watchos);

/// TextKit 1 布局管理器（兼容旧代码）
@property(nonatomic, readonly) NSLayoutManager *layoutManager API_AVAILABLE(ios(7.0));

/// 文本存储
@property(nonatomic, readonly, strong) NSTextStorage *textStorage API_AVAILABLE(ios(7.0));

/// 链接样式属性
@property(null_resettable, nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *linkTextAttributes API_AVAILABLE(ios(7.0));

/// 是否使用标准文本缩放
@property (nonatomic) BOOL usesStandardTextScaling API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos);

/// 内置查找交互
@property (nonatomic, nullable, readonly) UIFindInteraction *findInteraction API_AVAILABLE(ios(16.0)) API_UNAVAILABLE(watchos, tvos);

/// 是否启用内置查找交互
@property (nonatomic, readwrite, getter=isFindInteractionEnabled) BOOL findInteractionEnabled API_AVAILABLE(ios(16.0)) API_UNAVAILABLE(watchos, tvos);

/// 边框样式
@property (nonatomic) UITextViewBorderStyle borderStyle API_AVAILABLE(ios(17.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 文本高亮属性
@property (nonatomic, copy, null_resettable) NSDictionary<NSAttributedStringKey, id> *textHighlightAttributes API_AVAILABLE(ios(18.0), tvos(18.0), visionos(2.0)) API_UNAVAILABLE(watchos);

/// 绘制文本高亮背景
- (void)drawTextHighlightBackgroundForTextRange:(NSTextRange *)textRange origin:(CGPoint)origin API_AVAILABLE(ios(18.0), tvos(18.0), visionos(2.0)) API_UNAVAILABLE(watchos);

/// Writing Tools 是否活跃
@property(nonatomic,readonly,getter=isWritingToolsActive) BOOL writingToolsActive API_AVAILABLE(ios(18.0), visionos(2.4)) API_UNAVAILABLE(tvos, watchos);

@property UIWritingToolsBehavior writingToolsBehavior API_AVAILABLE(ios(18.0), visionos(2.4)) API_UNAVAILABLE(tvos, watchos);

@property UIWritingToolsResultOptions allowedWritingToolsResultOptions API_AVAILABLE(ios(18.0), visionos(2.4)) API_UNAVAILABLE(tvos, watchos);

@property(nonatomic,readonly) Class subclassForWritingToolsCoordinator API_AVAILABLE(ios(18.2), visionos(2.4)) API_UNAVAILABLE(tvos, watchos);

@property(nonatomic,readonly) UIWritingToolsCoordinator *writingToolsCoordinator API_AVAILABLE(ios(18.2), visionos(2.4)) API_UNAVAILABLE(tvos, watchos);

/// 编辑属性允许时的格式化配置
@property(nonatomic, nullable, readwrite, copy) UITextFormattingViewControllerConfiguration *textFormattingConfiguration API_AVAILABLE(ios(18.0)) API_UNAVAILABLE(visionos, macCatalyst) API_UNAVAILABLE(watchos, tvos);

@end

NS_ASSUME_NONNULL_END
