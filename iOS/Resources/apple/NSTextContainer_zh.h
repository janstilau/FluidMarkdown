//
//  NSTextContainer_zh.h
//  带中文注释版 NSTextContainer 头文件
//

#import <Foundation/Foundation.h>
#import <UIKit/NSParagraphStyle.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/NSLayoutManager.h>

@class UIBezierPath;
@class NSTextLayoutManager;

#if UIKIT_HAS_UIFOUNDATION_SYMBOLS && !TARGET_OS_OSX
NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UIKIT_EXTERN API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos)
@interface NSTextContainer : NSObject <NSSecureCoding>

/**************************** 初始化 ****************************/

/// 指定初始化方法，指定文本容器大小
- (instancetype)initWithSize:(CGSize)size NS_DESIGNATED_INITIALIZER API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 使用解码器初始化
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 返回拥有该文本容器的 NSTextLayoutManager（布局管理器）。当非 nil 时，-layoutManager 应为 nil
@property (weak, nullable, readonly, NS_NONATOMIC_IOSONLY) NSTextLayoutManager *textLayoutManager API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);


/**************************** 容器几何属性 ****************************/

/// 文本容器尺寸。默认 CGSizeZero，表示容器无限制
@property (NS_NONATOMIC_IOSONLY) CGSize size API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 换行模式，决定文本容器最后一行行为。默认 NSLineBreakByWordWrapping
@property (NS_NONATOMIC_IOSONLY) NSLineBreakMode lineBreakMode API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);


/**************************** 布局约束属性 ****************************/

/// 行片段 rect 内左右边距，布局管理器用它确定可用内容宽度。默认 5.0
@property (NS_NONATOMIC_IOSONLY) CGFloat lineFragmentPadding;

/// 最大可显示行数，布局管理器用它计算文本容器最多行数。默认 0 表示无限
@property (NS_NONATOMIC_IOSONLY) NSUInteger maximumNumberOfLines API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);


/**************************** 行片段 ****************************/

/// 返回文本容器中与 proposedRect 相交的行片段 rect，并计算剩余 rect 用于下一次布局
/// proposedRect：拟布局矩形
/// characterIndex：对应文本存储的字符索引
/// baseWritingDirection：水平行进方向（左到右或右到左）
/// remainingRect：剩余矩形，用于迭代布局
- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect
                                  atIndex:(NSUInteger)characterIndex
                          writingDirection:(NSWritingDirection)baseWritingDirection
                              remainingRect:(nullable CGRect *)remainingRect API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 若为 YES，则文本容器是简单矩形（-size 决定），可用于布局优化
@property (getter=isSimpleRectangularTextContainer, readonly, NS_NONATOMIC_IOSONLY) BOOL simpleRectangularTextContainer API_AVAILABLE(macos(10.0), ios(9.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);


/**************************** 与视图同步 ****************************/

/// 文本视图宽高变化是否影响文本容器大小。默认 NO
@property (NS_NONATOMIC_IOSONLY) BOOL widthTracksTextView;
@property (NS_NONATOMIC_IOSONLY) BOOL heightTracksTextView;

@end


/**************************** NSTextContainer 私有扩展 ****************************/

@interface NSTextContainer () <NSTextLayoutOrientationProvider>

/// 返回拥有该文本容器的 NSLayoutManager
@property (nullable, assign, NS_NONATOMIC_IOSONLY) NSLayoutManager *layoutManager API_AVAILABLE(macos(10.0), ios(9.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 替换文本容器的布局管理器，保留原有 NSTextContainers，不会导致 dealloc
- (void)replaceLayoutManager:(NSLayoutManager *)newLayoutManager NS_SWIFT_NAME(replaceLayoutManager(_:)) API_AVAILABLE(macos(10.0), ios(9.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

/// 排除路径数组，文本不会布局到这些路径内
@property (copy, NS_NONATOMIC_IOSONLY) NSArray<UIBezierPath *> *exclusionPaths API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), visionos(1.0)) API_UNAVAILABLE(watchos);

@end

NS_HEADER_AUDIT_END(nullability, sendability)
#endif
