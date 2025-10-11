//
//  NSTextStorage_zh.h
//  带中文注释版 NSTextStorage 头文件
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/NSLayoutManager.h>

NS_ASSUME_NONNULL_BEGIN

/// NSTextStorage 编辑类型
typedef NS_OPTIONS(NSUInteger, NSTextStorageEditActions) {
    NSTextStorageEditedAttributes = (1 << 0),   // 属性被修改
    NSTextStorageEditedCharacters = (1 << 1)    // 字符被修改
} API_AVAILABLE(macos(10.11), ios(7.0)) API_UNAVAILABLE(watchos);


/*
 子类化提示：
 NSTextStorage 是 NSMutableAttributedString 的半抽象子类，实现了编辑管理（beginEditing/endEditing）、属性验证、代理处理以及布局通知。
 子类需要自行实现实际的 attributed string 存储，需要重写两个 NSMutableAttributedString 原语方法和两个 NSAttributedString 原语方法：
 
 - (NSString *)string;
 - (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;
 - (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
 - (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;
 
 修改后应调用 -edited:range:changeInLength: 来触发其余流程。
*/

UIKIT_EXTERN API_AVAILABLE(macos(10.0), ios(7.0)) API_UNAVAILABLE(watchos)
@interface NSTextStorage : NSMutableAttributedString <NSSecureCoding>

/**************************** 布局管理器 ****************************/

/// 当前 NSTextStorage 拥有的 NSLayoutManager 数组
@property (readonly, copy, NS_NONATOMIC_IOSONLY) NSArray<NSLayoutManager *> *layoutManagers;

/// 添加布局管理器，同时设置 layoutManager.textStorage 为自己
- (void)addLayoutManager:(NSLayoutManager *)aLayoutManager;

/// 移除布局管理器，同时设置 layoutManager.textStorage 为 nil
- (void)removeLayoutManager:(NSLayoutManager *)aLayoutManager;


/**************************** 待处理编辑信息 ****************************/

/// 当前待处理的编辑类型掩码（属性或字符或两者）
@property (readonly, NS_NONATOMIC_IOSONLY) NSTextStorageEditActions editedMask;

/// 当前待处理的编辑范围。无待处理时为 {NSNotFound, 0}
@property (readonly, NS_NONATOMIC_IOSONLY) NSRange editedRange;

/// 待处理编辑的长度变化
@property (readonly, NS_NONATOMIC_IOSONLY) NSInteger changeInLength;


/**************************** 代理 ****************************/

@property (nullable, weak, NS_NONATOMIC_IOSONLY) id <NSTextStorageDelegate> delegate;


/**************************** 编辑管理 ****************************/

/// 通知 NSTextStorage 已编辑。子类修改原文后必须调用
- (void)edited:(NSTextStorageEditActions)editedMask
         range:(NSRange)editedRange
  changeInLength:(NSInteger)delta;

/// 处理编辑：通知 delegate、修正属性、通知布局管理器
- (void)processEditing;


/**************************** 属性修正 ****************************/

/// 是否延迟修正无效属性。UIKit 默认延迟，抽象类及自定义子类不延迟
@property (readonly, NS_NONATOMIC_IOSONLY) BOOL fixesAttributesLazily;

/// 标记需要验证的属性范围，如果是延迟模式会记录，非延迟则立即调用 fixAttributesInRange:
- (void)invalidateAttributesInRange:(NSRange)range;

/// 确保指定范围内的属性已经被验证
- (void)ensureAttributesAreFixedInRange:(NSRange)range;


/**************************** NSTextStorageObserving ****************************/

/// 观察 NSTextStorage 的对象
@property (nullable, weak, NS_NONATOMIC_IOSONLY) id <NSTextStorageObserving> textStorageObserver API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0)) API_UNAVAILABLE(watchos);

@end


/**** NSTextStorage 代理方法 ****/

API_UNAVAILABLE(watchos)
@protocol NSTextStorageDelegate <NSObject>
@optional

/// 即将处理编辑，代理可修改字符或属性
- (void)textStorage:(NSTextStorage *)textStorage
  willProcessEditing:(NSTextStorageEditActions)editedMask
               range:(NSRange)editedRange
       changeInLength:(NSInteger)delta API_AVAILABLE(macos(10.11), ios(7.0));

/// 已处理编辑，代理可修改属性
- (void)textStorage:(NSTextStorage *)textStorage
   didProcessEditing:(NSTextStorageEditActions)editedMask
               range:(NSRange)editedRange
       changeInLength:(NSInteger)delta API_AVAILABLE(macos(10.11), ios(7.0));

@end


/**** 通知 ****/

UIKIT_EXTERN NSNotificationName const NSTextStorageWillProcessEditingNotification API_AVAILABLE(macos(10.0), ios(7.0)) API_UNAVAILABLE(watchos);
UIKIT_EXTERN NSNotificationName const NSTextStorageDidProcessEditingNotification API_AVAILABLE(macos(10.0), ios(7.0)) API_UNAVAILABLE(watchos);


/**** NSTextStorageObserving 协议 ****/

API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0)) API_UNAVAILABLE(watchos)
@protocol NSTextStorageObserving <NSObject>

/// 观察的 NSTextStorage
@property (nullable, strong, NS_NONATOMIC_IOSONLY) NSTextStorage *textStorage;

/// 在文本存储处理编辑后回调
- (void)processEditingForTextStorage:(NSTextStorage *)textStorage
                              edited:(NSTextStorageEditActions)editMask
                               range:(NSRange)newCharRange
                      changeInLength:(NSInteger)delta
                     invalidatedRange:(NSRange)invalidatedCharRange;

/// 事务性编辑
- (void)performEditingTransactionForTextStorage:(NSTextStorage *)textStorage
                                      usingBlock:(void (NS_NOESCAPE ^)(void))transaction;

@end

NS_ASSUME_NONNULL_END
