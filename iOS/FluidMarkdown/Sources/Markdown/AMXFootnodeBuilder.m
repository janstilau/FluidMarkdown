// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXFootnodeBuilder.h"
#import <AntMarkdown/AMUtils.h>


/**
 * AMXFootNoteAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入脚注引用。
 * 支持脚注编号显示和脚注内容的关联，提供点击跳转到脚注详情的功能。
 * 主要用于 Markdown 脚注语法的渲染，支持文档中的引用和注释系统。
 * 
 * 对应的 Markdown 语法示例：
 * ```
 * 这是一段包含脚注的文本[^1]，还有另一个脚注[^note2]。
 * 
 * 这里是带有自定义标识的脚注[^custom-footnote]。
 * 
 * [^1]: 这是第一个脚注的内容。
 * [^note2]: 这是第二个脚注的详细说明。
 * [^custom-footnote]: 这是自定义脚注的内容，可以包含更多信息。
 * 
 * ```
 */

/*
 •    脚注定义可以出现在文档的任意位置，只要它在首次被引用之后；
 •    渲染时，解析器会自动把所有脚注统一显示在文章底部（渲染器负责收集和展示）；
 •    因此 位置不影响显示效果，但过早定义会影响可读性。
 */
@interface AMXFootNoteAttachment : NSTextAttachment

@property(nonatomic,assign) NSInteger noteIndex;
@property(nonatomic,copy) NSString *noteTitle;

@end

@implementation AMXFootNoteAttachment

- (BOOL)isEqual:(id)object
{
    if([super isEqual:object])
        return YES;
    
    if(![object isKindOfClass:[self class]])
    {
        return NO;
    }
    AMXFootNoteAttachment* other = (AMXFootNoteAttachment*)object;
    if(self.noteIndex == other.noteIndex && ( self.noteTitle == other.noteTitle || [self.noteTitle isEqualToString:other.noteTitle] ))
    {
        return YES;
    }
    return NO;
}

@end

@implementation AMXFootnodeBuilder

- (NSAttributedString *)buildWithReference:(NSString *)reference
                                     title:(NSString *)title
                                     index:(NSInteger)index
                                    styles:(AMTextStyles *)styles{
    return [AMXFootnodeBuilder footnoteWithTitle:title index:index styles:styles];
}

// 这里是实际根据 title 生成脚注图片的地方.
// 这里生成的脚注, 其实是圆圈的那一部分.
+ (NSAttributedString *)footnoteWithTitle:(NSString *)title index:(NSInteger)index styles:(AMTextStyles*)styles{

    if (!(title && [title isKindOfClass:[NSString class]] && ![@"" isEqualToString:title])) {
        return nil;
    }
    
    __block UIImage *image = nil;
    if ([title isEqualToString:@"”"]) {
        image = [UIImage imageNamed:@"CardUIPlugins.bundle/footnote"];
    }else {
        if(![NSThread currentThread].isMainThread) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            APTMainCall(0, __FUNCTION__, 0, 0, ^{
                image = [AMXFootnodeBuilder convertTitleToImage:title styles:styles];
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
            dispatch_semaphore_wait(semaphore, waitTime);
        }
        else
        {
            image = [AMXFootnodeBuilder convertTitleToImage:title styles:styles];
        }
    }
    
    AMXFootNoteAttachment *textAttachment = [[AMXFootNoteAttachment alloc] init];
    textAttachment.noteIndex = index;
    textAttachment.noteTitle = title;
    
    textAttachment.image = image;
    UIFont *font = [UIFont systemFontOfSize:AUFVS(15.0)];
    
    CGFloat yOffset = (font.capHeight - image.size.height) / 2.0;
    textAttachment.bounds = CGRectMake(0, yOffset, image.size.width, image.size.height);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSString *zeroWidthSpace = @"\u200B"; 
    CGFloat desiredLeftMargin = 4.0;
    CGSize zeroWidthSize = [zeroWidthSpace sizeWithAttributes:@{NSFontAttributeName: font}];
    CGFloat kernValue = desiredLeftMargin - zeroWidthSize.width;
    NSAttributedString *spaceString = [[NSAttributedString alloc]
                                       initWithString:zeroWidthSpace
                                       attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor clearColor],
        NSKernAttributeName: @(kernValue)
    }];
    [attributedString appendAttributedString:spaceString];
    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"action://type=footnote&index=%ld&title=%@",index,title]];
    if (url) {
        [attributedString addAttribute:NSLinkAttributeName
                                 value:url
                                 range:NSMakeRange(attributedString.length-1, 1)];
    }
    return [attributedString copy];
}

// 就是使用 UILabel 的显示来变化的图片.
// 因为使用到了 UIKit, 所以这里就必须在主线程里面执行了.
+ (UIImage*)convertTitleToImage:(NSString*)title styles:(AMTextStyles*)styles
{
    CGFloat labelSize = styles.footNoteAttributes.stringAttributes[@"labelSize"] ? [styles.footNoteAttributes.stringAttributes[@"labelSize"] floatValue] : 18.f;
    UIFont* textFont = styles.footNoteAttributes.stringAttributes[NSFontAttributeName] ? ((UIFont*)styles.footNoteAttributes.stringAttributes[NSFontAttributeName])  : [UIFont boldSystemFontOfSize:AUFVS(11.0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, labelSize, labelSize)];
    label.backgroundColor = styles.footNoteAttributes.stringAttributes[NSBackgroundColorAttributeName] ? : [AMUtils colorWithString:@"#1677ff1e"];
    label.layer.cornerRadius = 9;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;

    label.textColor = styles.footNoteAttributes.stringAttributes[NSForegroundColorAttributeName] ? : [AMUtils colorWithString:@"#0e489a"];
    label.font = textFont;
    label.text = title;

    [label layoutIfNeeded];
    return [AMXFootnodeBuilder imageFromView:label];
}

+ (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
