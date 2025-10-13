// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.


#import "MenuViewController.h"
#import "StreamPreviewViewController.h"
#import "AIChatViewController.h"
#import "StreamFlueViewController.h"


@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = @[@"stream print preview", @"AI conversation scenario simulation", @"Stream Flue Demo"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    CGFloat yOffset = -200; // 全局偏移量，方便调整

    // 1️⃣ 创建 NSTextStorage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@"Hello TextKit!Hello TextKit!Hello TextKit!"];
    NSLog(@"textStorage %p", textStorage);

    // 2️⃣ 创建第一个 NSLayoutManager
    NSLayoutManager *layoutManager1 = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager1];
    NSLog(@"layoutManager1 %p", layoutManager1);

    // 3️⃣ 创建两个 NSTextContainer
    NSTextContainer *container1 = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, 200)];
    NSTextContainer *container2 = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, 200)];
    [layoutManager1 addTextContainer:container1];
    [layoutManager1 addTextContainer:container2];
    NSLog(@"container1 %p", container1);
    NSLog(@"container2 %p", container2);

    // 4️⃣ 创建第一个和第二个 UITextView
    UITextView *textView1 = [[UITextView alloc] initWithFrame:CGRectMake(20, 50 - yOffset, 200, 200) textContainer:container1];
    UITextView *textView2 = [[UITextView alloc] initWithFrame:CGRectMake(240, 50 - yOffset, 200, 200) textContainer:container2];
    textView1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    textView2.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
    [self.view addSubview:textView1];
    [self.view addSubview:textView2];
    NSLog(@"textView1 %p, textContainer %p, layoutManager %p, textStorage %p", textView1, textView1.textContainer, textView1.layoutManager, textView1.textStorage);
    NSLog(@"textView2 %p, textContainer %p, layoutManager %p, textStorage %p", textView2, textView2.textContainer, textView2.layoutManager, textView2.textStorage);

    // 5️⃣ 创建第二个 NSLayoutManager
    NSLayoutManager *layoutManager2 = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager2];
    NSLog(@"layoutManager2 %p", layoutManager2);

    // 6️⃣ 创建新的 NSTextContainer
    NSTextContainer *container3 = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, 200)];
    NSTextContainer *container4 = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, 200)];
    [layoutManager2 addTextContainer:container3];
    [layoutManager2 addTextContainer:container4];
    NSLog(@"container3 %p", container3);
    NSLog(@"container4 %p", container4);

    // 7️⃣ 创建第三个和第四个 UITextView
    UITextView *textView3 = [[UITextView alloc] initWithFrame:CGRectMake(20, 300 - yOffset, 200, 200) textContainer:container3];
    UITextView *textView4 = [[UITextView alloc] initWithFrame:CGRectMake(240, 300 - yOffset, 200, 200) textContainer:container4];
    textView3.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
    textView4.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.3];
    [self.view addSubview:textView3];
    [self.view addSubview:textView4];
    NSLog(@"textView3 %p, textContainer %p, layoutManager %p, textStorage %p", textView3, textView3.textContainer, textView3.layoutManager, textView3.textStorage);
    NSLog(@"textView4 %p, textContainer %p, layoutManager %p, textStorage %p", textView4, textView4.textContainer, textView4.layoutManager, textView4.textStorage);

    // 8️⃣ 修改文本，四个 UITextView 都会自动更新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:@"Updated TextKit for all 4 TextViews!"];
        NSLog(@"After update:");
        NSLog(@"textView1: %@, container %p, layoutManager %p, textStorage %p", textView1.text, textView1.textContainer, textView1.layoutManager, textView1.textStorage);
        NSLog(@"textView2: %@, container %p, layoutManager %p, textStorage %p", textView2.text, textView2.textContainer, textView2.layoutManager, textView2.textStorage);
        NSLog(@"textView3: %@, container %p, layoutManager %p, textStorage %p", textView3.text, textView3.textContainer, textView3.layoutManager, textView3.textStorage);
        NSLog(@"textView4: %@, container %p, layoutManager %p, textStorage %p", textView4.text, textView4.textContainer, textView4.layoutManager, textView4.textStorage);
    });
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.menuItems[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        StreamPreviewViewController *previewVC = [[StreamPreviewViewController alloc] init];
        [self.navigationController pushViewController:previewVC animated:YES];
    } else if (indexPath.row == 1) {
        AIChatViewController *chatVC = [[AIChatViewController alloc] init];
        [self.navigationController pushViewController:chatVC animated:YES];
    } else if (indexPath.row == 2) {
        StreamFlueViewController *streamFlueVC = [[StreamFlueViewController alloc] init];
        [self.navigationController pushViewController:streamFlueVC animated:YES];
    }
}
@end
