//
//  NSLayoutManager_zh.h
//  （仿 iOS17 SDK）
//  带中文注释版 NSLayoutManager 头文件
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/NSTextContainer.h>
#import <UIKit/NSTextStorage.h>

UIKIT_EXTERN API_AVAILABLE(macos(10.0), ios(7.0)) API_UNAVAILABLE(watchos)
@interface NSLayoutManager : NSObject <NSSecureCoding>

/**************************** 初始化 ****************************/

/// 指定初始化方法。用于设置此实例。NSLayoutManager 初始化时不附带 NSTextStorage。
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// 使用解码器初始化的指定方法。
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;


/*************************** 文本存储 ***************************/

// 获取拥有该布局管理器的 NSTextStorage 对象。
// 避免通过此属性直接设置文本存储。通过 -[NSTextStorage addLayoutManager:] 添加布局管理器时，内部会使用此属性建立绑定。
@property (nullable, assign, NS_NONATOMIC_IOSONLY) NSTextStorage *textStorage;


/**************************** 文本容器 ****************************/

/// 当前布局管理器拥有的 NSTextContainer 对象数组。
@property (readonly, NS_NONATOMIC_IOSONLY) NSArray<NSTextContainer *> *textContainers;

/// 在末尾添加一个文本容器。必须使前一个最后容器之后的所有字形布局失效（即之前因没有容器未布局的部分）。
- (void)addTextContainer:(NSTextContainer *)container;

/// 在指定索引位置插入一个文本容器。必须使从插入点以后到末尾容器的所有字形布局失效。
- (void)insertTextContainer:(NSTextContainer *)container atIndex:(NSUInteger)index;

/// 移除指定位置的文本容器。必须使移除容器及之后的所有容器中的字形布局失效。
- (void)removeTextContainerAtIndex:(NSUInteger)index;

/// 当文本容器几何形状尺寸变化时调用。会使该容器以及后续容器中的所有字形布局失效。
- (void)textContainerChangedGeometry:(NSTextContainer *)container;


/**************************** 代理 ****************************/

@property (nullable, weak, NS_NONATOMIC_IOSONLY) id <NSLayoutManagerDelegate> delegate;


/*********************** 全局布局管理选项 ***********************/

// 若为 YES，则空白字符和其他“不可见”字符会以特殊字形或图形显示。默认 NO。
@property (NS_NONATOMIC_IOSONLY) BOOL showsInvisibleCharacters;

// 若为 YES，则控制字符将以可见形式显示（例如 “^M”）。默认 NO。
@property (NS_NONATOMIC_IOSONLY) BOOL showsControlCharacters;

// 默认情况下，布局管理器使用字体指定的行距（leading）。此属性可关闭该行为，以使用固定行距。
@property (NS_NONATOMIC_IOSONLY) BOOL usesFontLeading;

// 若为 YES，布局管理器可对文本的部分区段执行字形生成和布局，而不必为前面全部内容布局。默认 NO。
// 启用后可显著提高大文本的性能。
@property (NS_NONATOMIC_IOSONLY) BOOL allowsNonContiguousLayout API_AVAILABLE(macos(10.5), ios(7.0));

// 即便允许非连续布局，也不一定使用。此属性返回当前是否存在非连续布局区域。
@property (readonly, NS_NONATOMIC_IOSONLY) BOOL hasNonContiguousLayout API_AVAILABLE(macos(10.5), ios(7.0));

// 若为 YES，会开启内部对可疑内容的安全分析并启用防御行为。默认 NO。
@property BOOL limitsLayoutForSuspiciousContents API_AVAILABLE(macos(10.14), ios(12.0), tvos(12.0)) API_UNAVAILABLE(watchos);

// 若为 YES，当换行时会尝试断字（连字符）。段落可通过 NSParagraphStyle 控制是否使用。默认 NO。
@property BOOL usesDefaultHyphenation API_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0)) API_UNAVAILABLE(watchos);


/************************** 使布局 / 字形失效 **************************/

/// 移除旧字符范围对应的所有字形，调整后续字形的字符索引，并使新字符范围布局失效。
- (void)invalidateGlyphsForCharacterRange:(NSRange)charRange changeInLength:(NSInteger)delta actualCharacterRange:(nullable NSRangePointer)actualCharRange;

/// 使指定字符范围的布局信息失效。若 actualCharRange 非 NULL，则设置为实际失效的字符范围。
- (void)invalidateLayoutForCharacterRange:(NSRange)charRange actualCharacterRange:(nullable NSRangePointer)actualCharRange API_AVAILABLE(macos(10.5), ios(7.0));

/// 使指定字符或字形范围对应的显示失效（重绘）。这两个方法不会立即触发布局。
- (void)invalidateDisplayForCharacterRange:(NSRange)charRange;
- (void)invalidateDisplayForGlyphRange:(NSRange)glyphRange;

/// 在文本存储编辑过程中由 processEditing 发送。newCharRange 表示最终字符串中显式编辑的范围，invalidatedRange 包含属性校正引起的扩展范围。
- (void)processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange API_AVAILABLE(macos(10.11), ios(7.0));


/************************ 触发字形生成与布局 ************************/

/// 以下方法允许客户端精确指定希望为哪部分文本生成字形或布局（特别在非连续布局中很重要）。
- (void)ensureGlyphsForCharacterRange:(NSRange)charRange;
- (void)ensureGlyphsForGlyphRange:(NSRange)glyphRange;
- (void)ensureLayoutForCharacterRange:(NSRange)charRange;
- (void)ensureLayoutForGlyphRange:(NSRange)glyphRange;
- (void)ensureLayoutForTextContainer:(NSTextContainer *)container;
- (void)ensureLayoutForBoundingRect:(CGRect)bounds inTextContainer:(NSTextContainer *)container;


/************************ 设置字形与字形属性 ************************/

/// 为给定的字形范围设置初始字形与属性。通常由布局生成流程调用。直接调用此方法会使布局与显示失效。
- (void)setGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange API_AVAILABLE(macos(10.11), ios(7.0));


/************************ 获取字形与字形属性 ************************/

/// 返回字形总数。如果不允许非连续布局，此操作会强制为所有字符生成字形。
@property (readonly, NS_NONATOMIC_IOSONLY) NSUInteger numberOfGlyphs;

/// 以下方法用于根据索引获取字形、验证字形索引、获取字形属性等。
- (CGGlyph)CGGlyphAtIndex:(NSUInteger)glyphIndex isValidIndex:(nullable BOOL *)isValidIndex API_AVAILABLE(macos(10.11), ios(7.0));
- (CGGlyph)CGGlyphAtIndex:(NSUInteger)glyphIndex API_AVAILABLE(macos(10.11), ios(7.0));
- (BOOL)isValidGlyphIndex:(NSUInteger)glyphIndex API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0)) API_UNAVAILABLE(watchos);
- (NSGlyphProperty)propertyForGlyphAtIndex:(NSUInteger)glyphIndex API_AVAILABLE(macos(10.5), ios(7.0));
- (NSUInteger)characterIndexForGlyphAtIndex:(NSUInteger)glyphIndex;
- (NSUInteger)glyphIndexForCharacterAtIndex:(NSUInteger)charIndex;
- (NSUInteger)getGlyphsInRange:(NSRange)glyphRange glyphs:(nullable CGGlyph *)glyphBuffer properties:(nullable NSGlyphProperty *)props characterIndexes:(nullable NSUInteger *)charIndexBuffer bidiLevels:(nullable unsigned char *)bidiLevelBuffer API_AVAILABLE(macos(10.5), ios(7.0));


/************************ 设置布局信息 ************************/

/// 将给定字形范围与指定文本容器绑定。布局流程中应首先调用此方法。
- (void)setTextContainer:(NSTextContainer *)container forGlyphRange:(NSRange)glyphRange;

/// 将行片段的边界与字形范围绑定。布局流程中应在设置片段 rect 之后调用。
- (void)setLineFragmentRect:(CGRect)fragmentRect forGlyphRange:(NSRange)glyphRange usedRect:(CGRect)usedRect;

/// 为额外行片段设置边界和容器（用于文档末尾换行）
/// 仅当存在非空额外行片段时调用。
- (void)setExtraLineFragmentRect:(CGRect)fragmentRect usedRect:(CGRect)usedRect textContainer:(NSTextContainer *)container;

/// 为字形范围的起始字形设置位置。通常表示该字形不与前一个字形按名义间距排列。
- (void)setLocation:(CGPoint)location forStartOfGlyphRange:(NSRange)glyphRange;

/// 指定某个字形是否不可见（不绘制）。
- (void)setNotShownAttribute:(BOOL)flag forGlyphAtIndex:(NSUInteger)glyphIndex;

/// 指定某个字形是否绘制在其行片段外部（可能超出行边界）。
- (void)setDrawsOutsideLineFragment:(BOOL)flag forGlyphAtIndex:(NSUInteger)glyphIndex;

/// 对应附件字形时，设置附件在布局中的尺寸。
- (void)setAttachmentSize:(CGSize)attachmentSize forGlyphRange:(NSRange)glyphRange;


/************************ 获取布局信息 ************************/

/// （通过参数或返回值）获取当前第一个尚未布局的字符或字形的索引。
- (void)getFirstUnlaidCharacterIndex:(nullable NSUInteger *)charIndex glyphIndex:(nullable NSUInteger *)glyphIndex;
- (NSUInteger)firstUnlaidCharacterIndex;
- (NSUInteger)firstUnlaidGlyphIndex;

/// 返回包含指定字形的文本容器，并可返回该容器中该字形所属的完整范围。
- (nullable NSTextContainer *)textContainerForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange;
- (nullable NSTextContainer *)textContainerForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange withoutAdditionalLayout:(BOOL)flag API_AVAILABLE(macos(10.0), ios(9.0));

/// 返回指定文本容器的已使用矩形（不触发行或字形生成）。
- (CGRect)usedRectForTextContainer:(NSTextContainer *)container;

/// 返回指定字形所在行片段的矩形，并可返回该片段所覆盖的字形范围。
- (CGRect)lineFragmentRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange;
- (CGRect)lineFragmentRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange withoutAdditionalLayout:(BOOL)flag API_AVAILABLE(macos(10.0), ios(9.0));

/// 返回指定字形所在行片段中已使用区域的矩形，并可返回该片段所覆盖的字形范围。
- (CGRect)lineFragmentUsedRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange;
- (CGRect)lineFragmentUsedRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(nullable NSRangePointer)effectiveGlyphRange withoutAdditionalLayout:(BOOL)flag API_AVAILABLE(macos(10.0), ios(9.0));

/// 返回额外行片段的边界与使用矩形，以及其所属文本容器。
@property (readonly, NS_NONATOMIC_IOSONLY) CGRect extraLineFragmentRect;
@property (readonly, NS_NONATOMIC_IOSONLY) CGRect extraLineFragmentUsedRect;
@property (nullable, readonly, NS_NONATOMIC_IOSONLY) NSTextContainer *extraLineFragmentTextContainer;

/// 返回指定字形在其行片段内的位置（相对于片段起点）。若未显式设置位置，则从前一个位置推算获得。
- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex;

/// 返回某字形是否被标记为不绘制。
- (BOOL)notShownAttributeForGlyphAtIndex:(NSUInteger)glyphIndex;

/// 返回某字形是否会绘制在其行片段外部。
- (BOOL)drawsOutsideLineFragmentForGlyphAtIndex:(NSUInteger)glyphIndex;

/// 若某字形对应附件，返回附件布局尺寸；若未设置尺寸，则返回 {-1, -1}。
- (CGSize)attachmentSizeForGlyphAtIndex:(NSUInteger)glyphIndex;

/// 返回某行片段中被截断的字形范围；若无截断则返回 {NSNotFound, 0}。
- (NSRange)truncatedGlyphRangeInLineFragmentForGlyphAtIndex:(NSUInteger)glyphIndex API_AVAILABLE(macos(10.11), ios(7.0));


/************************ 高级查询 ************************/

/// 返回给定字符范围对应的字形范围；若 actualCharRange 非 NULL，则填入对应字符的实际范围。
- (NSRange)glyphRangeForCharacterRange:(NSRange)charRange actualCharacterRange:(nullable NSRangePointer)actualCharRange;

/// 返回给定字形范围对应的字符范围；若 actualGlyphRange 非 NULL，则填入实际字形范围。
- (NSRange)characterRangeForGlyphRange:(NSRange)glyphRange actualGlyphRange:(nullable NSRangePointer)actualGlyphRange;

/// 返回已经布局到指定文本容器的字符对应的字形范围（此方法性能较低）。
- (NSRange)glyphRangeForTextContainer:(NSTextContainer *)container;

/// 返回包含指定字形、其起始位置在前一个显式位置处、直到下一个显式位置之前的字形区间。
- (NSRange)rangeOfNominallySpacedGlyphsContainingIndex:(NSUInteger)glyphIndex;

/// 返回包围给定字形范围在指定文本容器中的最小矩形（交集后计算）。用于将字形范围映射为显示矩形。
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;

/// 返回一个连续字形范围，该范围至少包括所有部分或完全落入给定边界矩形的字形（即用于显示这些字形所需的最小连续范围）。
- (NSRange)glyphRangeForBoundingRect:(CGRect)bounds inTextContainer:(NSTextContainer *)container;
- (NSRange)glyphRangeForBoundingRectWithoutAdditionalLayout:(CGRect)bounds inTextContainer:(NSTextContainer *)container;

/// 返回给定点所在文本容器中的字形索引；若该点不在任何字形上，则返回最近字形的索引。若 partialFraction 非 NULL，则返回在该字形与下一个字形之间的距离比例。
- (NSUInteger)glyphIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container fractionOfDistanceThroughGlyph:(nullable CGFloat *)partialFraction;
- (NSUInteger)glyphIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container;
- (CGFloat)fractionOfDistanceThroughGlyphForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container;

/// 返回给定点对应的字符索引；若该点不在任何字符上，则返回最近字符索引。考虑到字符可能合并为一个字形（如 ligature），此方法更精细。
- (NSUInteger)characterIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container fractionOfDistanceBetweenInsertionPoints:(nullable CGFloat *)partialFraction;

/// 获取某行片段的所有文本插入点（insertion points）。调用者提供该片段内的一个字符索引、是否使用备用插入点、是否按显示顺序，
/// 返回插入点个数，同时填充 positions 与 charIndexes 数组表示它们的位置与对应字符索引。
- (NSUInteger)getLineFragmentInsertionPointsForCharacterAtIndex:(NSUInteger)charIndex alternatePositions:(BOOL)aFlag inDisplayOrder:(BOOL)dFlag positions:(nullable CGFloat *)positions characterIndexes:(nullable NSUInteger *)charIndexes;

/// 枚举所有与指定字形范围相交的行片段，按行片段回调其矩形、使用矩形、所属文本容器与字形子范围。
- (void)enumerateLineFragmentsForGlyphRange:(NSRange)glyphRange usingBlock:(void (^)(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop))block API_AVAILABLE(macos(10.11), ios(7.0));

/// 枚举指定字形范围在指定文本容器中所有包围矩形（包括选中范围时的矩形）。若提供 selectedRange，则返回用于绘制选中的矩形；
/// 若不需要选中效果，则传 {NSNotFound, 0}。此方法仅做最少工作以返回包围矩形。
- (void)enumerateEnclosingRectsForGlyphRange:(NSRange)glyphRange withinSelectedGlyphRange:(NSRange)selectedRange inTextContainer:(NSTextContainer *)textContainer usingBlock:(void (^)(CGRect rect, BOOL *stop))block API_AVAILABLE(macos(10.11), ios(7.0));


/************************ 绘制支持 ************************/

/// 以下方法是绘制原语（primitive）方法。可重写以绘制附加内容或替换文本绘制，但不改变布局计算。
/// - drawBackgroundForGlyphRange:atPoint: 绘制背景色、选中与标记区，以及诸如表格背景、边框之类的块级装饰。
/// - drawGlyphsForGlyphRange:atPoint: 绘制实际字形、附件、下划线、删除线等。所绘制字形必须属于同一个文本容器。
- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;
- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;

/// 此为字形渲染原语方法。按指定位置将字形绘制进 CGContext。positions 为用户空间坐标系下的位置，
/// CGContext 已按字体、textMatrix 与属性配置好。font 参数表示当前绘图所用字体，可能与属性字典中 NSFontAttributeName 不同。
- (void)showCGGlyphs:(const CGGlyph *)glyphs positions:(const CGPoint *)positions count:(NSInteger)glyphCount font:(UIFont *)font textMatrix:(CGAffineTransform)textMatrix attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes inContext:(CGContextRef)CGContext API_AVAILABLE(macos(10.15), ios(13.0), tvos(13.0)) API_UNAVAILABLE(watchos);

/// 本方法由 drawBackgroundForGlyphRange:atPoint: 用于实际填充背景矩形。rectArray 为要填充的矩形数组，
/// charRange 对应字符范围，color 为填充色。默认实现简单填充。若你重写此方法，若修改绘图状态需恢复它。
- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color API_AVAILABLE(macos(10.6), ios(7.0));

/// 以下两组方法分别用于绘制下划线与计算应划线范围：
/// drawUnderlineForGlyphRange:… 实际绘制线条；
/// underlineGlyphRange:… 将给定范围切分成多个子范围，然后调用 drawUnderline…。
- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;
- (void)underlineGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;

/// 以下两组方法与上述下划线方法类似，但用于绘制删除线（strikethrough）。
- (void)drawStrikethroughForGlyphRange:(NSRange)glyphRange strikethroughType:(NSUnderlineStyle)strikethroughVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;
- (void)strikethroughGlyphRange:(NSRange)glyphRange strikethroughType:(NSUnderlineStyle)strikethroughVal lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;

@end
