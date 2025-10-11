// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMUtils.h"

@implementation AMUtils
+ (UIColor *)colorWithOctString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    NSArray * components = [cString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,)"]];
    if ([components count] < 3) return [UIColor clearColor];

    NSString *rString = components[0];
    NSString *gString = components[1];
    NSString *bString = components[2];

    NSString *alpha = @"1.0";
    if (components.count>=4) {
        alpha = components[3];
    }
    
    return [UIColor colorWithRed:((float) [rString integerValue] / 255.0f)
                           green:((float) [gString integerValue] / 255.0f)
                            blue:((float) [bString integerValue] / 255.0f)
                           alpha:alpha.floatValue];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor clearColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0x"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8) return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    CGFloat alpha = 1.0;
    if ([cString length] == 8) {
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];
        unsigned int a;
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        alpha = ((float) a / 255.0f);
    }
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}
+ (UIColor *)colorWithString:(NSString *)stringToConvert
{
    NSString *cString = [stringToConvert lowercaseString];
    if ([cString hasPrefix:@"rgb"]) {
        NSString *trimString = [cString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"rgba()"]];
        return [self colorWithOctString:trimString];
    } else if([cString hasPrefix:@"0x"] || [cString hasPrefix:@"#"]) {
        return [self colorWithHexString:cString];
    }

    UIColor *color = [UIColor clearColor];
    NSDictionary *colorMap = @{@"grey":[UIColor grayColor],
                               @"gray":[UIColor grayColor],
                               @"darkgray":[UIColor darkGrayColor],
                               @"lightgray":[UIColor lightGrayColor],
                               @"black":[UIColor blackColor],
                               @"white":[UIColor whiteColor],
                               @"red":[UIColor redColor],
                               @"blue":[UIColor blueColor],
                               @"green":[UIColor greenColor],
                               @"yellow":[UIColor yellowColor],
                               @"brown":[UIColor brownColor],
                               @"orange":[UIColor orangeColor]};
    if (colorMap[cString]) {
        color = colorMap[cString];
    }
    return color;
}
+ (id)JSONValue:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        NSData* data = [object dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            return [self JSONValue:data];
        } else {
            return nil;
        }
    } else if ([object isKindOfClass:[NSData class]]) {
        id result = nil;
        @try {
            NSError* error = nil;
            result = [NSJSONSerialization JSONObjectWithData:object options:0 error:&error];
            if (result == nil) {
                NSLog(@"-JSONValue failed. Error is: %@", error);
            }
        } @catch (NSException *exception) {
            NSLog(@"-JSONValue failed. Exception: %@", exception);
        }
        return result;
    } else {
        return nil;
    }
}
+ (CGSize)screenXY {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        size = CGSizeMake(width, height);
    });
    return size;
}
+ (CGFloat)fontValue:(NSString*)fontStr {
    if (!fontStr.length || [fontStr isEqualToString:@"(null)"]) {
        return 0;
    }
    
    CGFloat fontFloatValue = [fontStr floatValue];
    
    CGFloat ratio = 1;
    
    CGFloat scale = 1;
    scale = [self screenXY].width / 375.f;
    if ([fontStr hasSuffix:@"sip"]) {
        fontFloatValue *= scale;
    }
    else if ([fontStr hasSuffix:@"sp"]) {
        fontFloatValue *= (scale*ratio);
    }
    else if ([fontStr hasSuffix:@"np"]) {
        fontFloatValue *= ratio;
    }
    else if ([fontStr hasSuffix:@"pt"]) {
        fontFloatValue *= ratio;
    }
    
    
    else if ([fontStr hasSuffix:@"dip"]) {
        fontFloatValue *= 1;
    }
    else if ([fontStr hasSuffix:@"pit"]) {
        fontFloatValue *= 1;
    }
    else if ([fontStr hasSuffix:@"apx"]) {
        fontFloatValue *= (1.f/[UIScreen mainScreen].scale);
    }
    else {
        if ([fontStr hasSuffix:@"px"]) {
            fontFloatValue *= 1;
        }
        else if ([fontStr hasSuffix:@"rpx"]) {
            fontFloatValue *= ([self screenXY].width /750.f);
        }
    }
    
    return fontFloatValue;
}
@end

@implementation UIColor (AMUtils)

+ (instancetype)colorWithHex_ant_mark:(NSUInteger)hexColor {
    NSInteger a,r,g,b;
    a = (hexColor & 0xFF000000) >> 24;
    r = (hexColor & 0x00FF0000) >> 16;
    g = (hexColor & 0x0000FF00) >>  8;
    b = (hexColor & 0x000000FF) >>  0;
    if (a == 0) {
        a = 0xFF;
    }
    return [UIColor colorWithRed:1.0 * r / 255
                           green:1.0 * g / 255
                            blue:1.0 * b / 255
                           alpha:1.0 * a / 255];
}
+ (instancetype)colorWithHex_ant_mark_alpha:(NSUInteger)hexColor {
    NSInteger a,r,g,b;
    a = (hexColor & 0xFF000000) >> 24;
    r = (hexColor & 0x00FF0000) >> 16;
    g = (hexColor & 0x0000FF00) >>  8;
    b = (hexColor & 0x000000FF) >>  0;
    return [UIColor colorWithRed:1.0 * r / 255
                           green:1.0 * g / 255
                            blue:1.0 * b / 255
                           alpha:1.0 * a / 255];
}
+ (instancetype)colorWithCSSString_ant_mark_alpha:(NSString *)cssColor {
    cssColor = [cssColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([cssColor hasPrefix:@"#"]) {
        NSScanner *scaner = [[NSScanner alloc] initWithString:[cssColor substringFromIndex:1]];
      
        if (cssColor.length == 9) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            
            // RGBA to ARGB
            NSInteger a = value & 0xFF;
            value = (value >> 8) | (a << 24);
            return [self colorWithHex_ant_mark_alpha:value];
        }
        if (cssColor.length == 7) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 5) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger a,r,g,b;
            r = (value & 0xF000) >> 12;
            g = (value & 0x0F00) >>  8;
            b = (value & 0x00F0) >>  4;
            a = (value & 0x000F) >>  0;
            value = ((a * 0x11) << 24) | ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark_alpha:value];
        }
        else if (cssColor.length == 4) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger r,g,b;
            r = (value & 0x0F00) >>  8;
            g = (value & 0x00F0) >>  4;
            b = (value & 0x000F) >>  0;
            value = ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
    }
    return nil;
}
+ (instancetype)colorWithCSSString_ant_mark:(NSString *)cssColor
{
    cssColor = [cssColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([cssColor hasPrefix:@"#"]) {
        NSScanner *scaner = [[NSScanner alloc] initWithString:[cssColor substringFromIndex:1]];
        if (cssColor.length == 9) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            
            // RGBA to ARGB
            NSInteger a = value & 0xFF;
            value = (value >> 8) | (a << 24);
            return [self colorWithHex_ant_mark:value];
        }
        if (cssColor.length == 7) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 5) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger a,r,g,b;
            r = (value & 0xF000) >> 12;
            g = (value & 0x0F00) >>  8;
            b = (value & 0x00F0) >>  4;
            a = (value & 0x000F) >>  0;
            value = ((a * 0x11) << 24) | ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 4) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger r,g,b;
            r = (value & 0x0F00) >>  8;
            g = (value & 0x00F0) >>  4;
            b = (value & 0x000F) >>  0;
            value = ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
    }
    return nil;
}

- (instancetype)transparentColor_ant_mark
{
    CGFloat r,g,b,a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:0];
    } else if ([self getWhite:&r alpha:&a]) {
        return [UIColor colorWithWhite:r alpha:0];
    } else {
        return [UIColor clearColor];
    }
}

@end

@implementation UIImage (AMUtils)

+ (instancetype)imageWithGradient_ant_mark:(NSArray<UIColor *> *)colors
                                 locations:(NSArray<NSNumber *> *)locations
                                      size:(CGSize)size
                                 direction:(CGFloat)direction {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *arr = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:(id)obj.CGColor];
    }];
    
    CGFloat stackLocs[10] = {0};
    CGFloat *locs = stackLocs;
    BOOL needMalloc = locations.count > 10;
    if (locations.count) {
        locs = needMalloc ? malloc(locations.count * sizeof(CGFloat)) : stackLocs;
        [locations enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            locs[idx] = [obj doubleValue];
        }];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)arr, locs);
    
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rect];
    UIBezierPath* rectangleRotatedPath = [rectanglePath copy];
    CGAffineTransform transform = CGAffineTransformMakeRotation(-direction / 180 * M_PI + M_PI_2);
    [rectangleRotatedPath applyTransform: transform];
    CGRect rectangleBounds = CGPathGetPathBoundingBox(rectangleRotatedPath.CGPath);
    transform = CGAffineTransformInvert(transform);
    
    startPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
    endPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    if (needMalloc) {
        free(locs);
    }
    
    return image;
}

+ (instancetype)imageNamed_ant_mark:(NSString *)name
{
    static dispatch_once_t onceToken;
    static NSBundle *bundle = nil;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [[NSBundle bundleForClass:[AMUtils class]] pathForResource:@"AntMarkdown" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [main pathForResource:@"AntMarkdown"
                                          ofType:@"bundle"];
        }
        bundle = main;
        if (resourcePath) {
            bundle = [NSBundle bundleWithPath:resourcePath] ?: main;
        }
    });
    UIImage * image = [self imageNamed:name
                              inBundle:bundle
         compatibleWithTraitCollection:nil] ?: [self imageNamed:[NSString stringWithFormat:@"AntMarkdown.bundle/%@", name]];
    return image;
}
+ (instancetype)imageNamed_ant_bundle:(NSString *)bundlePath name:(NSString*)name
{
    
    NSString* resourcePath = [[NSBundle mainBundle] pathForResource:bundlePath ofType:@"bundle"];
    if (!resourcePath) {
        return nil;
    }
    NSBundle* bundle = [NSBundle bundleWithPath:resourcePath];
    UIImage *image = [UIImage imageNamed:name
                                inBundle:bundle
           compatibleWithTraitCollection:nil];
    return image;
}
@end

@implementation NSArray (AMUtils)

- (NSArray<id> *)mapWithBlock_ant_mark:(id  _Nonnull (NS_NOESCAPE ^)(id _Nonnull))block {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:block(obj)];
    }];
    return [arr copy];
}

@end

@implementation NSParagraphStyle (AMUtils)

- (BOOL)isEqualToDiffableObject:(NSParagraphStyle *)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    if (![self isEqual:object]) {
        NSMutableParagraphStyle *style = [self mutableCopy];
        style.lineBreakMode = object.lineBreakMode;
        return [style isEqual:object];
    }
    return YES;
}

@end

@implementation NSDictionary (AMUtils)

/**
 * 判断当前字典是否包含另一个字典的所有键值对（深度比较）
 * 
 * 功能概述：
 * 这是一个用于字典包含关系检查的核心方法，主要用于 AntMarkdown 框架中的属性差异检测和增量更新优化。
 * 该方法会递归地比较两个字典，确保当前字典包含目标字典的所有键值对。
 * 
 * 应用场景：
 * 1. 富文本属性差异检测：在 setAttributedTextPartialUpdate_ant_mark 方法中用于判断文本属性是否发生变化
 * 2. 增量渲染优化：避免不必要的文本重绘，只更新真正发生变化的部分
 * 3. 嵌套字典比较：支持多层嵌套的字典结构比较
 * 
 * 比较策略：
 * 1. 数量检查：如果目标字典的键值对数量大于当前字典，直接返回 NO
 * 2. 递归比较：对于嵌套字典，递归调用自身进行深度比较
 * 3. 协议优先：优先使用 AMDiffable 协议的自定义比较方法
 * 4. 默认比较：使用 NSObject 的 isEqual: 方法进行标准比较
 * 5. 并发枚举：使用 NSEnumerationConcurrent 提高大字典的比较性能
 * 
 * 性能优化：
 * - 早期退出：一旦发现不匹配的键值对，立即停止遍历
 * - 并发处理：利用多核处理器并行比较多个键值对
 * - 智能比较：根据对象类型选择最合适的比较方法
 * 
 * @param otherDictionary 要检查的目标字典，当前字典应该包含该字典的所有键值对
 * @return YES 表示当前字典包含目标字典的所有键值对；NO 表示不包含或存在差异
 * 
 * @note 该方法支持嵌套字典的递归比较，对于实现了 AMDiffable 协议的对象会使用自定义比较逻辑
 * @warning 如果目标字典为 nil，方法会返回 YES（空字典被认为包含在任何字典中）
 * 
 * 示例用法：
 * ```objc
 * NSDictionary *currentAttrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
 * NSDictionary *newAttrs = @{NSFontAttributeName: font};
 * BOOL contains = [currentAttrs includesDictionary_ant_mark:newAttrs]; // YES
 * ```
 */
- (BOOL)includesDictionary_ant_mark:(NSDictionary *)otherDictionary
{
    // 快速检查：如果目标字典的键值对数量大于当前字典，肯定不包含
    if (otherDictionary.count > self.count) {
        return NO;
    }
    
    // 使用 block 变量跟踪比较结果，支持在并发枚举中修改
    __block BOOL included = YES;
    
    // 并发枚举目标字典的所有键值对，提高大字典的比较性能
    [otherDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                             usingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        // 获取当前字典中对应键的值
        id obj = self[key];
        
        // 情况1：值是嵌套字典，需要递归比较
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary * dict = obj;
            // 确保当前字典中对应的值也是字典类型
            if ([dict isKindOfClass:[NSDictionary class]]) {
                // 递归调用自身，深度比较嵌套字典
                if (![dict includesDictionary_ant_mark:value]) {
                    included = NO;
                    *stop = YES; // 发现不匹配，立即停止枚举
                }
            } else {
                // 类型不匹配：目标是字典，但当前值不是字典
                included = NO;
                *stop = YES;
            }
        } else {
            // 情况2：值是普通对象，进行对象比较
            
            // 优先使用 AMDiffable 协议的自定义比较方法
            // 这对于复杂对象（如 NSParagraphStyle）提供了更精确的比较逻辑
            if ([obj conformsToProtocol:@protocol(AMDiffable)] && [value conformsToProtocol:@protocol(AMDiffable)]) {
                if (![(id<AMDiffable>)obj isEqualToDiffableObject:(id<AMDiffable>)value]) {
                    included = NO;
                    *stop = YES;
                }
            }
            // 使用标准的 NSObject isEqual: 方法进行比较
            else if (![obj isEqual:value]) {
                included = NO;
                *stop = YES;
            }
        }
    }];
    
    return included;
}
- (NSString *)stringForKey_ap:(id)aKey {
    return [self stringForKey_ap:aKey defaultValue:@""];
}
- (NSString *)stringOrEmptyStringForKey_ap:(id)akey {
    return [self stringForKey_ap:akey defaultValue:@""];
}
- (NSString *)stringForKey_ap:(id)aKey defaultValue:(NSString *)defaultValue {
    id object = [self objectForKey:aKey];
    if (!object || object == [NSNull null]) {
        return defaultValue;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }
    return [object description];
}

@end
