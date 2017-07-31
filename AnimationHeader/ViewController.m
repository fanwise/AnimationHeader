//
//  ViewController.m
//  AnimationHeader
//
//  Created by Wei Fan on 31/07/2017.
//  Copyright © 2017 Wei Fan. All rights reserved.
//

#import "ViewController.h"

const CGFloat maxHeaderHeight = 120;
const CGFloat minHeaderHeight = 44;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (nonatomic) CGFloat previousScrollOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.previousScrollOffset = 0;
    [self updateHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.headerHeightConstraint.constant = maxHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"row %li", (long)indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self canAnimateHeader:scrollView]) {
        CGFloat scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset;
        CGFloat absoluteTop = 0;
        CGFloat absoluteBottom = scrollView.contentSize.height - scrollView.frame.size.height;
        
        BOOL isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop;
        BOOL isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom;
        
        CGFloat newHeight = self.headerHeightConstraint.constant;
        if (isScrollingDown) {
            newHeight = fmax(minHeaderHeight, newHeight - fabs(scrollDiff));
        } else if (isScrollingUp) {
            newHeight = fmin(maxHeaderHeight, newHeight + fabs(scrollDiff));
        }
        if (newHeight != self.header.frame.size.height) {
            self.headerHeightConstraint.constant = newHeight;
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.previousScrollOffset);
        }
        [self updateHeader];
        self.previousScrollOffset = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidStopScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidStopScrolling];
    }
}

- (void)scrollViewDidStopScrolling {
    CGFloat range = maxHeaderHeight - minHeaderHeight;
    CGFloat midPoint = minHeaderHeight + (range / 2);
    
    if (self.headerHeightConstraint.constant > midPoint) {
        [self expandHeader];
    } else {
        [self collapseHeader];
    }
}

- (void)collapseHeader {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerHeightConstraint.constant = minHeaderHeight;
        [self updateHeader];
        [self.view layoutIfNeeded];
    }];
}

- (void)expandHeader {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerHeightConstraint.constant = maxHeaderHeight;
        [self updateHeader];
        [self.view layoutIfNeeded];
    }];
}

- (void)updateHeader {
    CGFloat range = maxHeaderHeight - minHeaderHeight;
    CGFloat openAmount = self.headerHeightConstraint.constant - minHeaderHeight;
    CGFloat percentage = openAmount / range;
    self.titleTopConstraint.constant = -openAmount + 24;
    self.logoImageView.alpha = percentage * percentage * percentage;
}

- (BOOL)canAnimateHeader:(UIScrollView *)scrollView {
    CGFloat scrollViewMaxHeight = scrollView.frame.size.height + self.headerHeightConstraint.constant - minHeaderHeight;
    return scrollView.contentSize.height > scrollViewMaxHeight;
}

@end
