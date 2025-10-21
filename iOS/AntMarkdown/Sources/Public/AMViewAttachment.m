#import "AMViewAttachment.h"
#import "CMImageTextAttachment.h"
#import "AMUtils.h"

NSString *const AMTextAttachmentSizeDidUpdateNotification = @"AMTextAttachmentSizeDidUpdateNotification";

@interface AMViewAttachment ()

@property (nonatomic) CGRect cachedBounds;

@end

@implementation AMViewAttachment
{
    __weak NSTextContainer *_textContainer;
}

@dynamic view;

- (void)dealloc
{
    if([NSThread isMainThread])
    {
        [self.viewIfLoaded removeFromSuperview];
    }
    else
    {
        UIView* view = self.viewIfLoaded;
        dispatch_async(dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }
}

// 默认, fullWidth 是 YES, 也就是说, 默认其实由 View 进行的展示, 应该是占据一行显示的.
- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    self = [super initWithData:nil ofType:nil];
    if (self) {
        self.fullWidth = YES;
    }
    return self;
}

- (__kindof UIView<AMAttachedView> *)view {
    return nil;
}

- (__kindof UIView<AMAttachedView> *)viewIfLoaded
{
    return nil;
}


- (void)setForceNeedsLayout
{
    NSLayoutManager *mgr = _textContainer.layoutManager;
    if (mgr) {
        self.cachedBounds = CGRectNull;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 这里其实是告诉, layout manager, 自己的这块数据发生了改变, 需要重新布局, 重新绘制.
            [mgr setNeedsLayoutForAttachment:self];
            
            NSNotification *noti = [[NSNotification alloc] initWithName:AMTextAttachmentSizeDidUpdateNotification
                                                                 object:mgr.textStorage
                                                               userInfo:@{
                NSAttachmentAttributeName: self,
            }];
            [[NSNotificationQueue defaultQueue] enqueueNotification:noti
                                                       postingStyle:NSPostWhenIdle
                                                       coalesceMask:NSNotificationCoalescingOnSender
                                                           forModes:nil];
        });
    }
}

- (void)setNeedsLayout
{
    if (CGRectIsNull(self.cachedBounds)) {
        return;
    }
    [self setForceNeedsLayout];
}

- (void)setNeedsDisplay
{
    [_textContainer.layoutManager setNeedsDisplayForAttachment:self];
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToAttachment:(AMViewAttachment *)object];
}

// 子类应该去复写这个方法, 因为 View 的调用, 是会触发懒加载的.
- (BOOL)isEqualToAttachment:(AMViewAttachment *)attach
{
    return self.fullWidth == attach.fullWidth && [self.view isEqual:attach.view];
}

- (void)updateAttachmentFromAttachment:(AMViewAttachment *)attach
{
    self.fullWidth = attach.fullWidth;
    self.cachedBounds = CGRectZero;
}

- (NSAttributedString *)attributedString
{
    NSMutableAttributedString *attr = [[NSAttributedString attributedStringWithAttachment:self] mutableCopy];
    /*
     - 独立段落语境： fullWidth == YES 时，附件应占据一整行并与上下文本分离。给整个 [附件 + \n] 施加 NSParagraphStyle ，把它当成单独段落处理。
     - 分段留白： paragraphSpacingBefore = 10 提供上方间距， paragraphSpacing = 0 不额外加下方间距，避免视觉上“挤在上一段下面”。
     - 断行控制：追加 "\n" 并设置 lineBreakStrategy = NSLineBreakStrategyPushOut ，确保后续文本被推到下一行，不与附件同行混排。
     - 缩进归零： firstLineHeadIndent = 0 防止宿主文本的段落缩进影响这一段，避免有效宽度被缩进改变，保证宽度计算一致。
     - 行高稳定： lineSpacing = 0 、 lineHeightMultiple = 1 ，避免继承周围富文本的行高设置而影响布局，保证 sizeThatFits: 与 attachmentBoundsForTextContainer: 的测量结果稳定。
     - 布局一致性：段落样式影响行片段的生成与宽度；统一样式让 layoutManager 把该块当作一个可预测的段落，从而与 _textContainer.lineFragmentPadding 等一起得到一致的可用宽度并缓存到 cachedBounds 。
     */
    if (self.fullWidth) {
        NSParagraphStyle *paragraph = ({
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.paragraphSpacing = 0;
            style.paragraphSpacingBefore = 10;
            style.lineSpacing = 0;
            style.lineHeightMultiple = 1;
            style.lineBreakStrategy = NSLineBreakStrategyPushOut;
            style.firstLineHeadIndent = 0;
            style;
        });
        
        // 给整个 [附件 + \n] 施加 NSParagraphStyle ，把它当成单独段落处理。
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attr.length)];
    }
    return [attr copy];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    /*
     该方法的默认实现会返回视图当前的大小。子类可以重写此方法，根据其子视图的布局需求返回自定义的大小。例如，UISwitch 对象会返回一个固定的大小值，表示开关控件的标准尺寸；而 UIImageView 对象会返回它当前显示的图像的大小。
     需要注意的是，此方法不会改变接收者本身的尺寸。
     */
    return [self.view sizeThatFits:size];
}

// 这种 View Attachment, 就不是 Image 的实现了.
- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex {
    return nil;
}

// 每次获取当前的 Rect 的时候, 会计算一下当前 View 的 sizeFit 来获取这个 View 的所占用的空间大小.
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    
    const CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2;
    
    // 首先用一下之前缓存的数据.
    if (!CGRectIsEmpty(self.cachedBounds) && (!self.fullWidth || self.cachedBounds.size.width == width)) {
        return self.cachedBounds;
    }
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer
                                     proposedLineFragment:lineFrag
                                            glyphPosition:position
                                           characterIndex:charIndex];
    // super 这里, 主要想要拿到的, 其实是 origin 的值.
    // 然后具体长多大, 其实是自己的 View 实现 sizeThatFits 来进行的视线. 
    rect.size = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    if (self.fullWidth) {
        rect.size.width = width;
    }
    self.cachedBounds = rect;
    return rect;
}

@end

@interface AMButtonViewAttachment ()
@property (nonatomic, copy, nullable) ButtonAction buttonAction;
@end

@implementation AMButtonViewAttachment

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    return [self initWithTitle:@"" action:nil];
}

// 这里没有实现 SizeThatFit, 本质上, 是使用了 UIButton 的 SizeThatFit 的实现
- (instancetype)initWithTitle:(NSString *)title action:(ButtonAction)action
{
    self = [super initWithData:nil ofType:nil];
    if (self) {
        self.fullWidth = NO;
        self.buttonAction = action;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithHex_ant_mark:0x1F3B63]
                          forState:UIControlStateNormal];
        [self.button addTarget:self
                        action:@selector(onButton:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.button sizeToFit];
    }
    return self;
}

- (__kindof UIView<AMAttachedView> *)view
{
    return self.button;
}

- (void)onButton:(id)sender
{
    !self.buttonAction ?: self.buttonAction();
}

@end
