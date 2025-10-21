// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "LatexCoverageViewController.h"
#import "AMXMarkdownTextView.h"
#import "AMXRenderService.h"
#import "AMXMarkdownStyle.h"

@interface LatexCoverageViewController () <UITableViewDelegate, UITableViewDataSource, AMXMarkdownTextViewDelegate>
@end

static NSString * const kLatexStyleId = @"latex-test";
static CGFloat const kCellHorizontalPadding = 16.0;

@implementation LatexCoverageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"LaTeX 覆盖测试";
    self.cachedSize = [NSMutableDictionary dictionary];

    // 注册 Markdown 样式，确保渲染引擎有样式配置
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:kLatexStyleId];

    [self loadLatexCases];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)loadLatexCases {
    NSMutableArray<NSDictionary *> *items = [NSMutableArray array];
    NSBundle *bundle = [NSBundle mainBundle];

    // 搜索所有 txt 文件，再筛选以 "latex" 开头的用例
    NSArray<NSString *> *txtPaths = [bundle pathsForResourcesOfType:@"txt" inDirectory:nil];
    NSCharacterSet *slashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"]; // 用于拆分路径

    for (NSString *path in txtPaths) {
        NSString *name = path.lastPathComponent;
        if (!name || name.length == 0) { continue; }
        NSString *lower = name.lowercaseString;
        if (![lower hasPrefix:@"latex"]) { continue; }

        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (content.length == 0 || error) { continue; }

        // 用例名称展示时不带扩展名
        NSString *displayName = [name stringByDeletingPathExtension];
        [items addObject:@{ @"name": displayName ?: name, @"content": content }];
    }

    // 按文件名自然排序（假定 latex1, latex2...）
    self.cases = [items sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull a, NSDictionary * _Nonnull b) {
        NSString *na = a[@"name"] ?: @"";
        NSString *nb = b[@"name"] ?: @"";
        return [na compare:nb options:NSNumericSearch];
    }];
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"latex.case.cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.tag = 1001;
        titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        titleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        [cell.contentView addSubview:titleLabel];

        AMXMarkdownTextView *markdownView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectZero];
        markdownView.tag = 2001;
        markdownView.styleId = kLatexStyleId;
        markdownView.textColor = [UIColor blackColor];
        markdownView.font = [UIFont systemFontOfSize:16];
        markdownView.textViewDelegate = self;
        markdownView.textContainerInset = UIEdgeInsetsZero;
        markdownView.textContainer.lineFragmentPadding = 0;
        [cell.contentView addSubview:markdownView];
    }

    NSDictionary *item = self.cases[indexPath.row];
    NSString *name = item[@"name"]; 
    NSString *content = item[@"content"]; 

    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    AMXMarkdownTextView *markdownView = (AMXMarkdownTextView *)[cell.contentView viewWithTag:2001];

    CGFloat width = self.view.bounds.size.width - 2 * kCellHorizontalPadding;
    CGSize contentSize = [self sizeForContent:content width:width];

    titleLabel.text = [NSString stringWithFormat:@"%@", name];
    titleLabel.frame = CGRectMake(kCellHorizontalPadding, 8, width, 18);

    markdownView.frame = CGRectMake(kCellHorizontalPadding, CGRectGetMaxY(titleLabel.frame) + 6, width, contentSize.height);
    [markdownView renderCompleteContent:content];

    return cell;
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.cases[indexPath.row];
    NSString *content = item[@"content"];
    CGFloat width = self.view.bounds.size.width - 2 * kCellHorizontalPadding;
    CGSize contentSize = [self sizeForContent:content width:width];
    // 标题 + 间距 + 内容 + 下边距
    return 8 + 18 + 6 + contentSize.height + 10;
}

- (CGSize)sizeForContent:(NSString *)markdown width:(CGFloat)width {
    NSNumber *key = @(markdown.hash);
    NSValue *cached = self.cachedSize[key];
    if (cached) { return cached.CGSizeValue; }
    CGSize size = [AMXMarkdownTextView caculateContentSize:markdown constrainSize:CGSizeMake(width, CGFLOAT_MAX) styleId:kLatexStyleId];
    self.cachedSize[key] = [NSValue valueWithCGSize:size];
    return size;
}

#pragma mark - AMXMarkdownTextViewDelegate (可按需扩展)
- (void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements {
    // 可用于统计曝光元素，例如数学公式、表格等
}

- (void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString {
    // 点按回调，可用于观察渲染对象
}

@end