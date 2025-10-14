// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "UITextView+AntMarkdown.h"
#import "NSString+AntMarkdown.h"
#import "CocoaMarkdown.h"
#import "AMTextStyles.h"
#import "AMAttributedStringRenderer.h"
#import "AMHTMLTransformer.h"
#import "AMLayoutManager.h"
#import "AMViewAttachment.h"
#import "AMUtils.h"
#import "AMGradientLayer.h"
#import "AMCodeViewAttachment.h"

@interface _AMAnimationDelegate : NSObject <CAAnimationDelegate>
@property (nonatomic, copy) void(^didStartBlock)(CAAnimation *anim);
@property (nonatomic, copy) void(^didEndBlock)(CAAnimation *anim, BOOL flag);
@end

@implementation _AMAnimationDelegate

+ (instancetype)delegateWithStart:(void(^)(CAAnimation *anim))start end:(void(^)(CAAnimation *anim, BOOL flag))end {
    _AMAnimationDelegate *obj = [_AMAnimationDelegate new];
    obj.didStartBlock = start;
    obj.didEndBlock = end;
    return obj;
}

+ (instancetype)delegateWithEnd:(void(^)(CAAnimation *anim, BOOL flag))end {
    _AMAnimationDelegate *obj = [_AMAnimationDelegate new];
    obj.didEndBlock = end;
    return obj;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    !self.didStartBlock ?: self.didStartBlock(anim);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    !self.didEndBlock ?: self.didEndBlock(anim, flag);
}

@end

@implementation UITextView (AntMarkdown)

- (instancetype)initWithFrame_ant_mark:(CGRect)frame {
    NSTextContainer *container = [[NSTextContainer alloc] init];
    AMLayoutManager *mgr = [AMLayoutManager new];
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    [storage addLayoutManager:mgr];
    [mgr addTextContainer:container];
    
    self = [self initWithFrame:frame textContainer:container];
    if (self) {
        self.editable = NO;
        self.selectable = YES;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        if (@available(iOS 16.0, *)) {
            self.findInteractionEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}
- (instancetype)initWithFrame_ant_mark:(CGRect)frame delegate:(id<CMAttributedStringRendererDelegate>)delegate {
    NSTextContainer *container = [[NSTextContainer alloc] init];
    AMLayoutManager *mgr = [AMLayoutManager new];
    mgr.delegate = delegate;
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    [storage addLayoutManager:mgr];
    [mgr addTextContainer:container];
    
    self = [self initWithFrame:frame textContainer:container];
    if (self) {
        self.editable = NO;
        self.selectable = NO;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        if (@available(iOS 16.0, *)) {
            self.findInteractionEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    
    return self;
}
- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText
{
    [self setAttributedTextPartialUpdate_ant_mark:attributedText animated:NO];
}

// 这个类最最核心的方法, 就是在这里了.
/**
 * 智能增量更新 AttributedString 到 TextView 的核心方法
 * 
 * 功能概述：
 * 1. 差异检测：从末尾向前比较，找到第一个不同的位置，避免全量重绘
 * 2. 增量更新：只更新变化的部分，支持替换、追加、删除三种操作
 * 3. 附件管理：智能处理 AMViewAttachment 和 AMAttachmentUpdatable 附件的生命周期
 * 4. 动画效果：支持渐变显示动画，通过 CALayer mask 实现逐行淡入效果
 * 
 * 核心优化：
 * - 性能：避免全量文本重绘，只更新差异部分
 * - 内存：及时清理不再使用的视图附件
 * - 体验：流畅的渐变动画效果
 * 
 * @param attributedText 新的富文本内容
 * @param animated 是否启用渐变动画效果
 */
// - 每次传入的都是 从开头到当前进度的完整文本
- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText animated:(BOOL)animated {
    NSLog(@"TextView 变化 %@", attributedText.string);
    const NSUInteger textLength = self.textStorage.length;
    
    /*
     * ========================================
     * 增量更新算法图示 (Incremental Update Algorithm)
     * ========================================
     * 
     * 原理：通过从字符串末尾开始比较，找到第一个差异位置，然后只更新变化的部分
     * 
     * 场景1: 追加内容 (Append Content)
     * ┌─────────────────────────────────────────────────────────────┐
     * │ 原文本: "Hello World"                                        │
     * │ 新文本: "Hello World, How are you?"                         │
     * │                    ↑                                        │
     * │                location = 11 (差异开始位置)                  │
     * │                                                             │
     * │ 操作: 在位置11后追加 ", How are you?"                        │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 场景2: 替换内容 (Replace Content)
     * ┌─────────────────────────────────────────────────────────────┐
     * │ 原文本: "Hello World"                                        │
     * │ 新文本: "Hello Universe"                                     │
     * │                ↑                                            │
     * │            location = 6 (差异开始位置)                       │
     * │                                                             │
     * │ 操作: 删除位置6后的"World"，插入"Universe"                   │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 场景3: 删除内容 (Delete Content)
     * ┌─────────────────────────────────────────────────────────────┐
     * │ 原文本: "Hello World, How are you?"                         │
     * │ 新文本: "Hello World"                                        │
     * │                    ↑                                        │
     * │                location = 11 (差异开始位置)                  │
     * │                                                             │
     * │ 操作: 删除位置11后的所有内容                                 │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 算法优势:
     * • 只更新变化部分，避免全量重新渲染
     * • 保持现有格式和附件不变
     * • 支持平滑的动画过渡效果
     * • 优化性能，特别是对长文本的处理
     */
    
    // ========== 第一阶段：差异检测 ==========
    // 从末尾向前遍历，找到第一个不同的位置，这样可以最大化保留相同的前缀部分
    __block NSUInteger location = 0;
    // find the diffrent location,from ending to beginning
    // NSAttributedStringEnumerationReverse 就是从后向前进行的遍历.
    [self.textStorage enumerateAttributesInRange:NSMakeRange(0, MIN(textLength, attributedText.length))
                                         options:NSAttributedStringEnumerationReverse
                                      usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if ([[attributedText attributedSubstringFromRange:range] isEqualToAttributedString:[self.textStorage attributedSubstringFromRange:range]]) {
            location = NSMaxRange(range);
            *stop = YES;
        }
    }];
    
    /*
     * ========================================
     * 文本编辑操作图示 (Text Editing Operations)
     * ========================================
     * 
     * NSTextStorage 编辑生命周期:
     * ┌─────────────────────────────────────────────────────────────┐
     * │ [textStorage beginEditing]                                  │
     * │    ↓                                                        │
     * │ ┌─────────────────────────────────────────────────────────┐ │
     * │ │ 批量编辑操作 (Batch Edit Operations)                    │ │
     * │ │                                                         │ │
     * │ │ • replaceCharactersInRange:withAttributedString:        │ │
     * │ │ • appendAttributedString:                               │ │
     * │ │ • deleteCharactersInRange:                              │ │
     * │ │ • setAttributes:range:                                  │ │
     * │ │                                                         │ │
     * │ │ 优势: 所有操作被合并，只触发一次布局更新                │ │
     * │ └─────────────────────────────────────────────────────────┘ │
     * │    ↓                                                        │
     * │ [textStorage endEditing]                                    │
     * │    ↓                                                        │
     * │ 触发布局管理器重新计算布局                                   │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 附件生命周期管理:
     * ┌─────────────────────────────────────────────────────────────┐
     * │ 旧附件清理 → 文本更新 → 新附件添加 → 视图关联               │
     * │     ↓            ↓           ↓           ↓                  │
     * │ removeFromSuperview  replaceText  addSubview  setAttachment │
     * └─────────────────────────────────────────────────────────────┘
     */
    
    // ========== 第二阶段：增量更新文本内容 ==========
    // 开始编辑 textStorage，所有修改操作都在 beginEditing 和 endEditing 之间进行
    // update at the diffrent point
    [self.textStorage beginEditing];
    
    
    // 2.1 处理新增或替换的内容（新文本比差异点更长的部分）
    if (attributedText.length > location) {
        [attributedText enumerateAttributesInRange:NSMakeRange(location, attributedText.length - location)
                                           options:0
                                        usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSRange currentRange = range;
            // 2.1.1 替换模式：当前 textStorage 长度足够，进行替换操作
            // the length of the string is long enough, replace it
            if (self.textStorage.mutableString.length > range.location) {
                // 获取当前位置的属性信息，用于比较是否需要更新
                NSDictionary<NSAttributedStringKey,id> * currentAttrs = [self.textStorage attributesAtIndex:range.location
                                                                                      longestEffectiveRange:&currentRange
                                                                                                    inRange:NSMakeRange(range.location, MIN(range.length, self.textStorage.length - range.location))];
                NSTextAttachment *oldAttach = currentAttrs[NSAttachmentAttributeName];
                NSTextAttachment *newAttach = attrs[NSAttachmentAttributeName];
                
                // 检查是否需要更新：范围不匹配或属性不匹配
                if ((range.location < currentRange.location || NSMaxRange(range) > NSMaxRange(currentRange)) ||
                    ![currentAttrs includesDictionary_ant_mark:attrs]) {
                    BOOL shouldReplace = YES;
                    
                    // 2.1.2 智能附件更新：如果是可更新的附件，尝试原地更新而不是替换
                    if ([oldAttach conformsToProtocol:@protocol(AMAttachmentUpdatable)]) {
                        id<AMAttachmentUpdatable> attach = (id<AMAttachmentUpdatable>)oldAttach;
                        if ([attach respondsToSelector:@selector(updateAttachmentFromAttachment:)] &&
                            [newAttach isKindOfClass:attach.class]) {
                            // 只有当范围长度不同时才需要替换，否则可以原地更新
                            shouldReplace = currentRange.length != range.length;
                            
                            // 代码视图附件需要在主线程更新
                            if ([attach isKindOfClass:AMCodeViewAttachment.class]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [attach updateAttachmentFromAttachment:newAttach];
                                });
                            } else {
                                [attach updateAttachmentFromAttachment:newAttach];
                            }
                        }
                    }
                    
                    // 2.1.3 执行替换操作
                    if (shouldReplace) {
                        // 清理旧的视图附件
                        if ([oldAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                            id<AMViewAttachment> attach = (id<AMViewAttachment>)oldAttach;
                            UIView<AMViewAttachment> *view = [attach view];
                            if (view.superview == self) {
                                if ([view respondsToSelector:@selector(setAttachment:)]) {
                                    view.attachment = nil;
                                }
                                [view removeFromSuperview];
                            }
                        }
                        
                        // 清理后续所有的视图附件（因为要替换从当前位置到末尾的所有内容）
                        NSRange rangeToReplace = NSMakeRange(range.location, self.textStorage.length - range.location);
                        
                        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                                     inRange:rangeToReplace
                                                     options:0
                                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                            NSTextAttachment *oldAttach = value;
                            if ([oldAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                                id<AMViewAttachment> attach = (id<AMViewAttachment>)oldAttach;
                                UIView<AMViewAttachment> *view = [attach view];
                                if (view.superview == self) {
                                    if ([view respondsToSelector:@selector(setAttachment:)]) {
                                        view.attachment = nil;
                                    }
                                    [view removeFromSuperview];
                                }
                            }
                        }];
                        
                        // 执行文本替换
                        [self.textStorage replaceCharactersInRange:rangeToReplace
                                              withAttributedString:[attributedText attributedSubstringFromRange:range]];
                        
                        // 添加新的视图附件
                        if ([newAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                            id<AMViewAttachment> attach = (id<AMViewAttachment>)newAttach;
                            UIView<AMViewAttachment> *view = [attach view];
                            if (view) {
                                if ([view respondsToSelector:@selector(setAttachment:)]) {
                                    view.attachment = attach;
                                }
                                view.hidden = YES;  // 初始隐藏，等待布局完成后显示
                                if (view.superview != self) {
                                    [self addSubview:view];
                                }
                            }
                        }
                    }
                }
            } else {    
                // 2.1.4 追加模式：当前 textStorage 长度不够，直接追加新内容
                // the length of the string is not long enough, append it
                [self.textStorage appendAttributedString:[attributedText attributedSubstringFromRange:range]];
                
                // 处理追加内容中的视图附件
                NSTextAttachment *newAttach = attrs[NSAttachmentAttributeName];
                if ([newAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                    id<AMViewAttachment> attach = (id<AMViewAttachment>)newAttach;
                    UIView<AMViewAttachment> *view = [attach view];
                    if (view) {
                        if ([view respondsToSelector:@selector(setAttachment:)]) {
                            view.attachment = attach;
                        }
                        view.hidden = YES;  // 初始隐藏，等待布局完成后显示
                        if (view.superview != self) {
                            [self addSubview:view];
                        }
                    }
                }
            }
        }];
    }
    
    // 2.2 处理删除操作：新文本比当前文本短，需要删除多余的部分
    if (attributedText.length < self.textStorage.length) {
        NSRange rangeToDelete = NSMakeRange(attributedText.length, self.textStorage.length - attributedText.length);
        
        // 清理要删除范围内的所有视图附件
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:rangeToDelete
                                     options:0
                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
                id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
                UIView<AMViewAttachment> *view = [attach view];
                if (view.superview == self) {
                    if ([view respondsToSelector:@selector(setAttachment:)]) {
                        view.attachment = nil;
                    }
                    [view removeFromSuperview];
                }
            }
        }];
        
        // 执行删除操作
        [self.textStorage deleteCharactersInRange:rangeToDelete];
    }
    
    // 结束 textStorage 编辑
    [self.textStorage endEditing];
    
    
    /*
     * ========================================
     * 渐变动画效果图示 (Fade Animation Effect)
     * ========================================
     * 
     * 动画原理: 使用 CALayer mask 实现逐行淡入效果
     * 
     * 遮罩层结构:
     * ┌─────────────────────────────────────────────────────────────┐
     * │ UITextView.layer                                            │
     * │ ┌─────────────────────────────────────────────────────────┐ │
     * │ │ mask (CALayer)                                          │ │
     * │ │ ┌─────────────────────────────────────────────────────┐ │ │
     * │ │ │ firstSublayer (黑色，显示已有内容)                  │ │ │
     * │ │ └─────────────────────────────────────────────────────┘ │ │
     * │ │ ┌─────────────────────────────────────────────────────┐ │ │
     * │ │ │ AMGradientLayer (渐变层，显示新增内容)              │ │ │
     * │ │ │ colors: [clear, clear] → [black, clear] → [black, black] │ │
     * │ │ └─────────────────────────────────────────────────────┘ │ │
     * │ └─────────────────────────────────────────────────────────┘ │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 动画时间轴 (0.15秒):
     * ┌─────────────────────────────────────────────────────────────┐
     * │ t=0.0s    t=0.075s   t=0.15s                               │
     * │   │          │         │                                   │
     * │ 完全透明 → 左半显示 → 完全显示                              │
     * │ [⚪⚪⚪] → [⚫⚪⚪] → [⚫⚫⚫]                                │
     * └─────────────────────────────────────────────────────────────┘
     * 
     * 逐行处理逻辑:
     * • 遍历变化区域的每一行文本片段
     * • 为每行创建独立的渐变动画层
     * • 处理视图附件的特殊显示逻辑
     * • 避免重复创建相同位置的动画层
     */
    
    // ========== 第三阶段：动画效果处理 ==========
    animated = false;
    NSInteger totalCount = [attributedText length];
    if (animated) {
        // 3.1 设置遮罩层，用于实现渐变显示效果
        CALayer *mask = self.layer.mask;
        if (!mask) {
            // 创建遮罩层，禁用隐式动画以获得精确控制
            mask = [CALayer layer];
            mask.actions = @{
                KEYPATH(CALayer *, bounds): [NSNull null],
                KEYPATH(CALayer *, position): [NSNull null],
                KEYPATH(CALayer *, frame): [NSNull null],
                KEYPATH(CALayer *, sublayerTransform): [NSNull null],
                @"transition": [NSNull null],
            };
            self.layer.mask = mask;
            
            // 创建黑色子层作为可见区域
            CALayer *sub = [CALayer layer];
            sub.backgroundColor = [UIColor blackColor].CGColor;
            sub.actions = @{
                KEYPATH(CALayer *, bounds): [NSNull null],
                KEYPATH(CALayer *, position): [NSNull null],
                KEYPATH(CALayer *, frame): [NSNull null],
                @"transition": [NSNull null],
            };
            [mask addSublayer:sub];
        }
        
        // 3.2 配置遮罩层的位置和变换
        CALayer *firstSublayer = mask.sublayers.firstObject;
        // make a black canvas，the mask part is not transparent
        mask.frame = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height);
        // sublayer transform - 处理滚动偏移
        mask.sublayerTransform = CATransform3DMakeTranslation(self.contentOffset.x, -self.contentOffset.y, 0);
        
        // 3.3 计算变化区域，用于动画显示
        // compute change area
        NSRange changedRange = NSMakeRange(location, self.textStorage.length - location);
        NSLog(@"=fade= begin animated totalCount = %ld, changedRange = %@",totalCount, NSStringFromRange(changedRange));
        
        // 如果没有变化，直接显示全部内容
        if (changedRange.length == 0) {
            firstSublayer.frame = self.layer.mask.bounds;
        }
        
        // 3.4 检查变化区域是否包含视图附件
        __block BOOL hasViewAttachment = NO;
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:changedRange
                                     options:NSAttributedStringEnumerationReverse
                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
                hasViewAttachment = YES;
                *stop = YES;
            }
        }];
        
        /*
         * ========================================
         * 逐行动画处理图示 (Line-by-Line Animation)
         * ========================================
         * 
         * 文本行布局结构:
         * ┌─────────────────────────────────────────────────────────────┐
         * │ Line 1: "Hello World"           ← 已存在，无需动画           │
         * │ ┌─────────────────────────────────────────────────────────┐ │
         * │ │ Line 2: "How are you?"        ← 新增行，需要动画         │ │
         * │ │ rect: 行片段矩形 (包含行间距)                           │ │
         * │ │ usedRect: 实际文本矩形 (紧贴文字)                       │ │
         * │ │                                                         │ │
         * │ │ 动画策略:                                               │ │
         * │ │ • 创建 AMGradientLayer 覆盖 usedRect                   │ │
         * │ │ • 从左到右的渐变显示效果                                │ │
         * │ │ • 检查是否已存在相同位置的动画层                        │ │
         * │ └─────────────────────────────────────────────────────────┘ │
         * │ Line 3: "Fine, thank you."      ← 新增行，需要动画           │
         * └─────────────────────────────────────────────────────────────┘
         * 
         * 特殊情况处理:
         * • 最后一行: 特殊的渐变逻辑，支持部分显示
         * • 视图附件: 直接显示到行底部，不使用渐变
         * • 重复检测: 避免在相同位置创建多个动画层
         */
        
        // 3.5 逐行处理渐变动画效果
        __block NSInteger lineIndex = 0;
        // traverse area in each line - 遍历变化区域的每一行
        [self.layoutManager enumerateLineFragmentsForGlyphRange:changedRange
                                                     usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
            
            // 处理布局异常情况
            if (!textContainer) {
                rect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil withoutAdditionalLayout:NO];
                usedRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:nil withoutAdditionalLayout:NO];
                if (CGRectEqualToRect(rect, CGRectZero)) {
                    firstSublayer.frame = self.layer.mask.bounds;
                    return;
                }
            }
            lineIndex++;
            
            // 3.5.1 处理最后一行的特殊逻辑
            // it is the last line
            if (NSMaxRange(changedRange) == NSMaxRange(glyphRange)) {
                // 如果包含视图附件，显示到当前行的底部
                if (hasViewAttachment) {
                    CGRect maskRect = CGRectMake(0, 0, rect.size.width, CGRectGetMaxY(rect));
                    firstSublayer.frame = maskRect;
                    return;
                }
                
                // 3.5.2 处理最后一行的渐变效果
                // the front part of the last line is transparent - 最后一行的前半部分透明
                CGRect maskRect = CGRectMake(0, 0, rect.size.width, CGRectGetMinY(rect));
                firstSublayer.frame = maskRect;
                
                // 查找同一行已存在的渐变层
                CALayer *layerInSameLine = nil;
                NSMutableArray* lineSubLayer = [NSMutableArray array];
                
                NSArray *sublayers = [mask.sublayers copy];
                for (CALayer *l in sublayers) {
                    CGRect lineRect = CGRectMake(floor(rect.origin.x), floor(rect.origin.y), ceil(rect.size.width), ceil(rect.size.height+1));
                    lineRect.size.width = ceil(CGRectGetMaxX(usedRect)) - CGRectGetMinX(lineRect);
                    
                    if ([l isKindOfClass:[AMGradientLayer class]]) {
                        if (CGRectContainsRect(lineRect, l.frame)) {
                            [lineSubLayer addObject:l];
                            // 记录同一行中最右边的渐变层
                            if (!layerInSameLine) {
                                layerInSameLine = l;
                            } else if (CGRectGetMaxX(l.frame) > CGRectGetMaxX(layerInSameLine.frame)) {
                                layerInSameLine = l;
                            }
                        } else {
                            // 移除不在当前行的渐变层
                            [l removeFromSuperlayer];
                        }
                    }
                }
                
                // 3.5.3 计算新渐变层的位置
                // make gradient from the begining of the lase line - 从最后一行的开始位置创建渐变
                CGFloat x = rect.origin.x;
                // if there is a gradient layer already, then make gradient from the right of the layer
                // 如果已经有渐变层，则从该层的右边开始创建新的渐变
                if (layerInSameLine) {
                    x = CGRectGetMaxX(layerInSameLine.frame);
                }
                
                
                CGRect newLayerFrame = CGRectMake(x, rect.origin.y,
                                                  CGRectGetMaxX(usedRect) - x,
                                                  rect.size.height);
                
                // 3.5.4 检查是否已存在相同的渐变层，避免重复创建
                BOOL hasSameFadeLayer = NO;
                // if there is a same layer, then drop it
                for (CALayer *l in lineSubLayer) {
                    if ([l isKindOfClass:[AMGradientLayer class]]) {
                        if(CGRectEqualToRect(CGRectIntegral(l.frame), CGRectIntegral(newLayerFrame)))
                        {
                            hasSameFadeLayer = YES;
                            break;
                        }
                    }
                }
                
                NSLog(@"=fade= hasSameFadeLayer = %d, lineHasLayerCount = %ld",hasSameFadeLayer,[lineSubLayer count]);
                
                // 3.5.5 创建新的渐变动画层
                if(!hasSameFadeLayer
                   && newLayerFrame.size.width > 0.001
                   && newLayerFrame.size.height > 0.001)
                {
                    AMGradientLayer *layer = [AMGradientLayer layer];
                    layer.lineIndex = lineIndex;
                    layer.startPoint = CGPointMake(0, 0.5);  // 水平渐变
                    layer.endPoint = CGPointMake(1, 0.5);
                    layer.frame = newLayerFrame;
                    layer.colors = @[(id)[UIColor blueColor].CGColor, (id)[UIColor blueColor].CGColor];
                    
                    @weakify(layer);
                    // 添加淡入动画：透明 -> 半透明 -> 完全显示
                    [layer addAnimation:({
                        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
                        anim.values = @[
                            @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor],      // 完全透明
                            @[(id)[UIColor blueColor].CGColor, (id)[UIColor clearColor].CGColor],       // 左边显示，右边透明
                            @[(id)[UIColor blueColor].CGColor, (id)[UIColor blueColor].CGColor]];       // 完全显示
                        anim.calculationMode = kCAAnimationLinear;
                        anim.fillMode = kCAFillModeBoth;
                        anim.duration = 0.15;  // 动画持续时间
                        anim.removedOnCompletion = YES;
                        // 这里的 delegate, 是一个强引用 
                        anim.delegate = [_AMAnimationDelegate delegateWithEnd:^(CAAnimation *anim, BOOL flag) {
                            @strongify(layer);
                            layer.isFadeComplete = YES;
                            if (flag) {
                                // 动画完成后可以选择移除层（当前注释掉）
                                // [layer removeFromSuperlayer];
                            }
                        }];
                        anim;
                    }) forKey:@"fadeIn"];
                    
                    [mask addSublayer:layer];
                    NSLog(@"=fade= addSublayer = %@, lineIndex = %ld, chRange = %@, text = %@",NSStringFromCGRect(newLayerFrame),lineIndex,NSStringFromRange(changedRange),[[attributedText attributedSubstringFromRange:changedRange] string]);
                }
            }
        }];
    } else {
        // 不需要动画时，移除遮罩层
        self.layer.mask = nil;
    }
}

- (void)setAttributedText_ant_mark:(NSAttributedString *)attributedText {
    
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                                    inRange:NSMakeRange(0, self.attributedText.length)
                                    options:0
                                 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
            id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
            UIView<AMViewAttachment> *view = [attach view];
            if (view.superview == self) {
                if ([view respondsToSelector:@selector(setAttachment:)]) {
                    view.attachment = nil;
                }
                [view removeFromSuperview];
            }
        }
    }];
    
    self.layer.mask = nil;
    
    [self setAttributedText:attributedText];
    
    [attributedText enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
            id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
            UIView<AMViewAttachment> *view = [attach view];
            if (view) {
                if ([view respondsToSelector:@selector(setAttachment:)]) {
                    view.attachment = attach;
                }
                view.hidden = YES;
                if (view.superview != self) {
                    [self addSubview:view];
                }
            }
        }
    }];
}

- (void)setMarkdownText_ant_mark:(NSString *)text {
    [self setMarkdownText_ant_mark:text styles:[AMTextStyles defaultStyles]];
}

- (void)setMarkdownText_ant_mark:(NSString *)text styles:(AMTextStyles *)styles {
    [self setAttributedText_ant_mark:[text markdownToAttributedStringWithStyles_ant_mark:styles]];
}

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles
{
    [self setMarkdownTextPartialUpdate_ant_mark:text styles:styles animated:NO];
}

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles animated:(BOOL)animated
{
    [self setAttributedTextPartialUpdate_ant_mark:[text markdownToAttributedStringWithStyles_ant_mark:styles] animated:animated];
}

@end
