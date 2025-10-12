// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CustomAttachmentViewController.h"
#import "UIColor+Random.h"

// 自定义图表 Attachment
/**
 * CustomChartAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入自定义图表。
 * 支持柱状图、饼图等多种图表类型的绘制和显示。
 * 主要用于在文档中展示数据可视化内容。
 * 
 * 使用示例：
 * // 自定义图表附件，不对应标准 Markdown 语法
 * // 通过代码创建并嵌入到富文本中
 * CustomChartAttachment *chart = [[CustomChartAttachment alloc] init];
 */
@interface CustomChartAttachment : NSTextAttachment
@property (nonatomic, strong) NSArray<NSNumber *> *dataPoints;
@property (nonatomic, assign) CGSize chartSize;
@end

@implementation CustomChartAttachment

- (instancetype)initWithDataPoints:(NSArray<NSNumber *> *)dataPoints size:(CGSize)size {
    self = [super init];
    if (self) {
        _dataPoints = dataPoints;
        _chartSize = size;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.chartSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        // 设置背景
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, self.chartSize.width, self.chartSize.height));
        
        // 绘制边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.chartSize.width, self.chartSize.height));
        
        // 绘制随机颜色边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.chartSize.width, self.chartSize.height));
        
        if (self.dataPoints.count > 1) {
            // 计算数据范围
            CGFloat minValue = [[self.dataPoints valueForKeyPath:@"@min.floatValue"] floatValue];
            CGFloat maxValue = [[self.dataPoints valueForKeyPath:@"@max.floatValue"] floatValue];
            CGFloat range = maxValue - minValue;
            
            if (range > 0) {
                // 绘制折线图
                CGContextSetStrokeColorWithColor(ctx, [UIColor systemBlueColor].CGColor);
                CGContextSetLineWidth(ctx, 2.0);
                
                CGFloat padding = 10.0;
                CGFloat chartWidth = self.chartSize.width - 2 * padding;
                CGFloat chartHeight = self.chartSize.height - 2 * padding;
                
                CGContextBeginPath(ctx);
                for (NSUInteger i = 0; i < self.dataPoints.count; i++) {
                    CGFloat x = padding + (chartWidth / (self.dataPoints.count - 1)) * i;
                    CGFloat normalizedValue = ([self.dataPoints[i] floatValue] - minValue) / range;
                    CGFloat y = padding + chartHeight * (1 - normalizedValue);
                    
                    if (i == 0) {
                        CGContextMoveToPoint(ctx, x, y);
                    } else {
                        CGContextAddLineToPoint(ctx, x, y);
                    }
                }
                CGContextStrokePath(ctx);
                
                // 绘制数据点
                CGContextSetFillColorWithColor(ctx, [UIColor systemBlueColor].CGColor);
                for (NSUInteger i = 0; i < self.dataPoints.count; i++) {
                    CGFloat x = padding + (chartWidth / (self.dataPoints.count - 1)) * i;
                    CGFloat normalizedValue = ([self.dataPoints[i] floatValue] - minValue) / range;
                    CGFloat y = padding + chartHeight * (1 - normalizedValue);
                    
                    CGContextFillEllipseInRect(ctx, CGRectMake(x - 3, y - 3, 6, 6));
                }
            }
        }
    }];
    
    self.image = image;
    return image;
}

@end

// 自定义标签 Attachment
/**
 * CustomLabelAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入自定义标签。
 * 支持文本内容、背景色、文字颜色、内边距和字体设置，能够绘制圆角标签样式。
 */
@interface CustomLabelAttachment : NSTextAttachment
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, strong) UIFont *font;
@end

@implementation CustomLabelAttachment

- (instancetype)initWithText:(NSString *)text backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor {
    self = [super init];
    if (self) {
        _text = text;
        _backgroundColor = backgroundColor;
        _textColor = textColor;
        _padding = UIEdgeInsetsMake(4, 8, 4, 8);
        _font = [UIFont systemFontOfSize:14];
        
        // 计算尺寸
        NSDictionary *attributes = @{NSFontAttributeName: _font};
        CGSize textSize = [_text sizeWithAttributes:attributes];
        CGSize totalSize = CGSizeMake(textSize.width + _padding.left + _padding.right,
                                     textSize.height + _padding.top + _padding.bottom);
        
        self.bounds = CGRectMake(0, 0, totalSize.width, totalSize.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    CGSize size = self.bounds.size;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        // 绘制圆角背景
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:4.0];
        CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
        [path fill];
        
        // 绘制文本
        NSDictionary *attributes = @{
            NSFontAttributeName: self.font,
            NSForegroundColorAttributeName: self.textColor
        };
        
        CGRect textRect = CGRectMake(self.padding.left, self.padding.top,
                                   size.width - self.padding.left - self.padding.right,
                                   size.height - self.padding.top - self.padding.bottom);
        
        [self.text drawInRect:textRect withAttributes:attributes];
        
        // 绘制随机颜色边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, size.width, size.height));
    }];
    
    self.image = image;
    return image;
}

@end

// 自定义进度条 Attachment
/**
 * CustomProgressAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入自定义进度条。
 * 支持进度值（0.0-1.0）、尺寸、进度色和轨道色设置，能够绘制可视化的进度条。
 * 
 * 使用示例：
 * // 自定义进度条附件，不对应标准 Markdown 语法
 * // 通过代码创建并嵌入到富文本中
 * CustomProgressAttachment *progress = [[CustomProgressAttachment alloc] init];
 * progress.progress = 0.75; // 75% 完成度
 */
@interface CustomProgressAttachment : NSTextAttachment
@property (nonatomic, assign) CGFloat progress; // 0.0 - 1.0
@property (nonatomic, assign) CGSize progressSize;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *trackColor;
@end

@implementation CustomProgressAttachment

- (instancetype)initWithProgress:(CGFloat)progress size:(CGSize)size {
    self = [super init];
    if (self) {
        _progress = MAX(0.0, MIN(1.0, progress));
        _progressSize = size;
        _progressColor = [UIColor systemBlueColor];
        _trackColor = [UIColor systemGray5Color];
        self.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.progressSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        CGFloat cornerRadius = self.progressSize.height / 2.0;
        
        // 绘制背景轨道
        UIBezierPath *trackPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.progressSize.width, self.progressSize.height) cornerRadius:cornerRadius];
        CGContextSetFillColorWithColor(ctx, self.trackColor.CGColor);
        [trackPath fill];
        
        // 绘制进度
        if (self.progress > 0) {
            CGFloat progressWidth = self.progressSize.width * self.progress;
            UIBezierPath *progressPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, progressWidth, self.progressSize.height) cornerRadius:cornerRadius];
            CGContextSetFillColorWithColor(ctx, self.progressColor.CGColor);
            [progressPath fill];
        }
        
        // 绘制百分比文字
        NSString *percentText = [NSString stringWithFormat:@"%.0f%%", self.progress * 100];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:10],
            NSForegroundColorAttributeName: [UIColor labelColor]
        };
        CGSize textSize = [percentText sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake((self.progressSize.width - textSize.width) / 2,
                                   (self.progressSize.height - textSize.height) / 2,
                                   textSize.width, textSize.height);
        [percentText drawInRect:textRect withAttributes:attributes];
         
         // 绘制随机颜色边框
         CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
         CGContextSetLineWidth(ctx, 2.0);
         CGContextStrokeRect(ctx, CGRectMake(0, 0, self.progressSize.width, self.progressSize.height));
    }];
    
    self.image = image;
    return image;
}

@end

// 自定义星级评分 Attachment
/**
 * CustomStarRatingAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入星级评分显示。
 * 支持1-5星评分设置和自定义尺寸，能够绘制可视化的星级评分图标。
 * 
 * 使用示例：
 * // 自定义星级评分附件，不对应标准 Markdown 语法
 * // 通过代码创建并嵌入到富文本中
 * CustomStarRatingAttachment *rating = [[CustomStarRatingAttachment alloc] init];
 * rating.rating = 4; // 4 星评分
 */
@interface CustomStarRatingAttachment : NSTextAttachment
@property (nonatomic, assign) NSInteger rating; // 1-5
@property (nonatomic, assign) CGSize starSize;
@end

@implementation CustomStarRatingAttachment

- (instancetype)initWithRating:(NSInteger)rating {
    self = [super init];
    if (self) {
        _rating = MAX(1, MIN(5, rating));
        _starSize = CGSizeMake(100, 20);
        self.bounds = CGRectMake(0, 0, _starSize.width, _starSize.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.starSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        CGFloat starWidth = self.starSize.width / 5.0;
        CGFloat starHeight = self.starSize.height;
        
        for (NSInteger i = 0; i < 5; i++) {
            CGFloat x = i * starWidth;
            UIColor *color = (i < self.rating) ? [UIColor systemYellowColor] : [UIColor systemGray4Color];
            
            // 绘制星形
            UIBezierPath *starPath = [self starPathInRect:CGRectMake(x + 2, 2, starWidth - 4, starHeight - 4)];
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            [starPath fill];
        }
        
        // 绘制随机颜色边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.starSize.width, self.starSize.height));
    }];
    
    self.image = image;
    return image;
}

- (UIBezierPath *)starPathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat centerX = CGRectGetMidX(rect);
    CGFloat centerY = CGRectGetMidY(rect);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2.0;
    
    // 简化的星形路径
    for (NSInteger i = 0; i < 10; i++) {
        CGFloat angle = (M_PI * 2 * i) / 10.0 - M_PI_2;
        CGFloat r = (i % 2 == 0) ? radius : radius * 0.5;
        CGFloat x = centerX + r * cos(angle);
        CGFloat y = centerY + r * sin(angle);
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(x, y)];
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }
    [path closePath];
    
    return path;
}

@end

// 自定义二维码 Attachment
/**
 * CustomQRCodeAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入二维码显示。
 * 支持自定义二维码文本内容和尺寸，能够绘制模拟的二维码图案（简化版）。
 * 
 * 使用示例：
 * // 自定义二维码附件，不对应标准 Markdown 语法
 * // 通过代码创建并嵌入到富文本中
 * CustomQRCodeAttachment *qr = [[CustomQRCodeAttachment alloc] init];
 * qr.text = @"https://example.com"; // 二维码内容
 */
@interface CustomQRCodeAttachment : NSTextAttachment
@property (nonatomic, strong) NSString *qrText;
@property (nonatomic, assign) CGSize qrSize;
@end

@implementation CustomQRCodeAttachment

- (instancetype)initWithText:(NSString *)text size:(CGSize)size {
    self = [super init];
    if (self) {
        _qrText = text;
        _qrSize = size;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.qrSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        // 绘制白色背景
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, self.qrSize.width, self.qrSize.height));
        
        // 绘制边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.qrSize.width, self.qrSize.height));
        
        // 模拟二维码图案（简化版）
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGFloat blockSize = 4.0;
        
        // 绘制角落的定位标记
        [self drawPositionMarkerInContext:ctx at:CGPointMake(8, 8) size:blockSize * 7];
        [self drawPositionMarkerInContext:ctx at:CGPointMake(self.qrSize.width - 8 - blockSize * 7, 8) size:blockSize * 7];
        [self drawPositionMarkerInContext:ctx at:CGPointMake(8, self.qrSize.height - 8 - blockSize * 7) size:blockSize * 7];
        
        // 绘制一些随机的数据块
        for (NSInteger i = 0; i < 20; i++) {
            CGFloat x = arc4random_uniform((uint32_t)(self.qrSize.width - blockSize));
            CGFloat y = arc4random_uniform((uint32_t)(self.qrSize.height - blockSize));
            CGContextFillRect(ctx, CGRectMake(x, y, blockSize, blockSize));
        }
        
        // 绘制文本标签
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:8],
            NSForegroundColorAttributeName: [UIColor blackColor]
        };
        NSString *label = [NSString stringWithFormat:@"QR: %@", self.qrText];
        [label drawAtPoint:CGPointMake(4, self.qrSize.height - 16) withAttributes:attributes];
        
        // 绘制随机颜色边框（覆盖原有边框）
        CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.qrSize.width, self.qrSize.height));
    }];
    
    self.image = image;
    return image;
}

- (void)drawPositionMarkerInContext:(CGContextRef)ctx at:(CGPoint)origin size:(CGFloat)size {
    // 外框
    CGContextFillRect(ctx, CGRectMake(origin.x, origin.y, size, size));
    // 内部白色
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(origin.x + 4, origin.y + 4, size - 8, size - 8));
    // 中心黑点
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(origin.x + 8, origin.y + 8, size - 16, size - 16));
}

@end

// 自定义徽章 Attachment
/**
 * CustomBadgeAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入徽章显示。
 * 支持自定义徽章文本、颜色和尺寸，能够绘制圆形或椭圆形的徽章样式。
 * 
 * 使用示例：
 * // 自定义徽章附件，不对应标准 Markdown 语法
 * // 通过代码创建并嵌入到富文本中
 * CustomBadgeAttachment *badge = [[CustomBadgeAttachment alloc] init];
 * badge.text = @"NEW"; // 徽章文本
 */
@interface CustomBadgeAttachment : NSTextAttachment
@property (nonatomic, strong) NSString *badgeText;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, assign) CGSize badgeSize;
@end

@implementation CustomBadgeAttachment

- (instancetype)initWithText:(NSString *)text color:(UIColor *)color {
    self = [super init];
    if (self) {
        _badgeText = text;
        _badgeColor = color;
        
        // 计算徽章尺寸
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
        CGSize textSize = [_badgeText sizeWithAttributes:attributes];
        _badgeSize = CGSizeMake(MAX(textSize.width + 16, 24), 20);
        
        self.bounds = CGRectMake(0, 0, _badgeSize.width, _badgeSize.height);
    }
    return self;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.badgeSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        
        // 绘制圆角矩形背景
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.badgeSize.width, self.badgeSize.height) cornerRadius:10];
        CGContextSetFillColorWithColor(ctx, self.badgeColor.CGColor);
        [path fill];
        
        // 绘制文本
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        CGSize textSize = [self.badgeText sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake((self.badgeSize.width - textSize.width) / 2,
                                   (self.badgeSize.height - textSize.height) / 2,
                                   textSize.width, textSize.height);
        
        [self.badgeText drawInRect:textRect withAttributes:attributes];
        
        // 绘制随机颜色边框
        CGContextSetStrokeColorWithColor(ctx, [UIColor randomColor].CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, CGRectMake(0, 0, self.badgeSize.width, self.badgeSize.height));
    }];
    
    self.image = image;
    return image;
}

@end

@interface CustomAttachmentViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation CustomAttachmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"自定义 Attachment 演示";
    
    [self setupTextView];
    [self setupContent];
}

- (void)setupTextView {
    self.textView = [[UITextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.editable = NO;
    self.textView.backgroundColor = [UIColor systemBackgroundColor];
    
    [self.view addSubview:self.textView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

- (void)setupContent {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    // 添加标题
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"自定义 NSTextAttachment 演示\n\n" 
                                                                attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20]}];
    [attributedString appendAttributedString:title];
    
    // 添加图表说明
    NSAttributedString *chartDescription = [[NSAttributedString alloc] initWithString:@"这是一个自定义的图表 Attachment：\n" 
                                                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:chartDescription];
    
    // 创建图表 Attachment
    NSArray *dataPoints = @[@10, @25, @15, @30, @20, @35, @28];
    CustomChartAttachment *chartAttachment = [[CustomChartAttachment alloc] initWithDataPoints:dataPoints size:CGSizeMake(300, 450)];
    NSAttributedString *chartString = [NSAttributedString attributedStringWithAttachment:chartAttachment];
    [attributedString appendAttributedString:chartString];
    
    // 添加换行和标签说明
    NSAttributedString *labelDescription = [[NSAttributedString alloc] initWithString:@"\n\n下面是一些自定义的标签 Attachment：\n" 
                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:labelDescription];
    
    // 创建不同样式的标签 Attachment
    NSArray *labels = @[
        @{@"text": @"重要", @"bg": [UIColor systemRedColor], @"fg": [UIColor whiteColor]},
        @{@"text": @"新功能", @"bg": [UIColor systemBlueColor], @"fg": [UIColor whiteColor]},
        @{@"text": @"已完成", @"bg": [UIColor systemGreenColor], @"fg": [UIColor whiteColor]},
        @{@"text": @"待处理", @"bg": [UIColor systemOrangeColor], @"fg": [UIColor whiteColor]}
    ];
    
    for (NSDictionary *labelInfo in labels) {
        CustomLabelAttachment *labelAttachment = [[CustomLabelAttachment alloc] 
                                                initWithText:labelInfo[@"text"] 
                                                backgroundColor:labelInfo[@"bg"] 
                                                textColor:labelInfo[@"fg"]];
        NSAttributedString *labelString = [NSAttributedString attributedStringWithAttachment:labelAttachment];
        [attributedString appendAttributedString:labelString];
        
        // 添加空格分隔
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
        [attributedString appendAttributedString:space];
    }
    
    // 添加说明文本
    NSAttributedString *explanation = [[NSAttributedString alloc] initWithString:@"\n\n这些自定义 Attachment 演示了如何：\n• 创建自定义的图表渲染\n• 实现带样式的标签\n• 将非文本内容无缝集成到文本流中\n• 使用 UIGraphicsImageRenderer 进行自定义绘制" 
                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor secondaryLabelColor]}];
    [attributedString appendAttributedString:explanation];
    
    // 添加进度条演示
    NSAttributedString *progressDescription = [[NSAttributedString alloc] initWithString:@"\n\n进度条 Attachment 演示：\n" 
                                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:progressDescription];
    
    NSArray *progressValues = @[@0.3, @0.6, @0.85];
    NSArray *progressLabels = @[@"项目进度", @"学习进度", @"完成度"];
    
    for (NSInteger i = 0; i < progressValues.count; i++) {
        NSString *label = [NSString stringWithFormat:@"%@: ", progressLabels[i]];
        NSAttributedString *labelString = [[NSAttributedString alloc] initWithString:label attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        [attributedString appendAttributedString:labelString];
        
        CustomProgressAttachment *progressAttachment = [[CustomProgressAttachment alloc] initWithProgress:[progressValues[i] floatValue] size:CGSizeMake(120, 16)];
        NSAttributedString *progressString = [NSAttributedString attributedStringWithAttachment:progressAttachment];
        [attributedString appendAttributedString:progressString];
        
        NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
        [attributedString appendAttributedString:newline];
    }
    
    // 添加星级评分演示
    NSAttributedString *starDescription = [[NSAttributedString alloc] initWithString:@"\n星级评分 Attachment 演示：\n" 
                                                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:starDescription];
    
    NSArray *ratings = @[@3, @4, @5];
    NSArray *ratingLabels = @[@"用户体验", @"功能完整性", @"整体满意度"];
    
    for (NSInteger i = 0; i < ratings.count; i++) {
        NSString *label = [NSString stringWithFormat:@"%@: ", ratingLabels[i]];
        NSAttributedString *labelString = [[NSAttributedString alloc] initWithString:label attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        [attributedString appendAttributedString:labelString];
        
        CustomStarRatingAttachment *starAttachment = [[CustomStarRatingAttachment alloc] initWithRating:[ratings[i] integerValue]];
        NSAttributedString *starString = [NSAttributedString attributedStringWithAttachment:starAttachment];
        [attributedString appendAttributedString:starString];
        
        NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
        [attributedString appendAttributedString:newline];
    }
    
    // 添加二维码演示
    NSAttributedString *qrDescription = [[NSAttributedString alloc] initWithString:@"\n二维码 Attachment 演示：\n" 
                                                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:qrDescription];
    
    CustomQRCodeAttachment *qrAttachment = [[CustomQRCodeAttachment alloc] initWithText:@"Hello World" size:CGSizeMake(80, 80)];
    NSAttributedString *qrString = [NSAttributedString attributedStringWithAttachment:qrAttachment];
    [attributedString appendAttributedString:qrString];
    
    // 添加徽章演示
    NSAttributedString *badgeDescription = [[NSAttributedString alloc] initWithString:@"\n\n徽章 Attachment 演示：\n" 
                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attributedString appendAttributedString:badgeDescription];
    
    NSArray *badges = @[
        @{@"text": @"HOT", @"color": [UIColor systemOrangeColor]},
        @{@"text": @"VIP", @"color": [UIColor systemPurpleColor]},
        @{@"text": @"SALE", @"color": [UIColor systemGreenColor]},
        @{@"text": @"NEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEW", @"color": [UIColor systemRedColor]}
    ];
    
    for (NSDictionary *badgeInfo in badges) {
        CustomBadgeAttachment *badgeAttachment = [[CustomBadgeAttachment alloc] 
                                                initWithText:badgeInfo[@"text"] 
                                                color:badgeInfo[@"color"]];
        NSAttributedString *badgeString = [NSAttributedString attributedStringWithAttachment:badgeAttachment];
        [attributedString appendAttributedString:badgeString];
        
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
        [attributedString appendAttributedString:space];
    }
    
    // 添加总结说明
    NSAttributedString *summary = [[NSAttributedString alloc] initWithString:@"\n\n✨ 更多自定义 Attachment 特性：\n• 进度条：动态显示完成百分比\n• 星级评分：可视化评分系统\n• 二维码：模拟二维码生成\n• 徽章：各种状态标识\n• 所有组件都支持自定义样式和尺寸" 
                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor secondaryLabelColor]}];
    [attributedString appendAttributedString:summary];
    
    self.textView.attributedText = attributedString;
}

@end
