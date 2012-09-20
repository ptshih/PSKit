//
//  PSCurtainController.m
//  PSKit
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCurtainController.h"

@interface PSCurtainController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) UIView *activeView;
@property (nonatomic, assign) CGFloat topOffset;

@end

@implementation PSCurtainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return RGBACOLOR(0, 0, 0, 0);
}

- (UIColor *)rowBackgroundColorForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    return CELL_BG_COLOR;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tv;
    tv.delegate = self;
    tv.dataSource = self;
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tv.scrollEnabled = NO;
    tv.backgroundColor = [UIColor clearColor];
    tv.backgroundView = nil;
    [self.view addSubview:tv];
    [tv reloadData];
    
    
//    if ([[FBSession activeSession] state] != FBSessionStateOpen) {
//        UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.curtainView.width, 52)];
//        userView.backgroundColor = [UIColor colorWithWhite:0.188 alpha:1.000];
//        [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginFacebook:)]];
//        
//        UIImageView *fb = [[UIImageView alloc] initWithFrame:CGRectMake(8, 14, 24, 24)];
//        [fb setImage:[UIImage imageNamed:@"IconFacebookSquare"]];
//        [userView addSubview:fb];
//        
//        UILabel *login = [UILabel labelWithText:@"Login with Facebook" style:@"h3LightLabel"];
//        login.frame = CGRectMake(43.0, 0, userView.width - 43.0, userView.height);
//        [userView addSubview:login];
//        
//        self.curtainView.tableHeaderView = userView;
//    }
    
//    CGFloat tableHeight = self.curtainView.contentSize.height;
//    self.curtainView.height = tableHeight;
//    self.curtainView.top -= self.curtainView.height;
//    [self.view addSubview:self.curtainView];
//    
//    [self.overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurtainFromTap:)]];
}

#pragma mark - Facebook

//- (void)loginFacebook:(UITapGestureRecognizer *)gr {
//    if ([[FBSession activeSession] state] == FBSessionStateOpen) {
//        
//    } else {
//        [FBSession sessionOpenWithPermissions:@[@"publish_stream"] completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//            if (session.isOpen) {
//                self.curtainView.tableHeaderView = nil;
//                [self.curtainView reloadData];
//                CGFloat tableHeight = self.curtainView.contentSize.height;
//                self.curtainView.height = tableHeight;
//            }
//        }];
//    }
//}

#pragma mark - Curtain

- (void)toggleFromView:(UIView *)view belowView:(UIView *)belowView animated:(BOOL)animated {
    if (self.activeView) {
        [self hideCurtain:animated];
    } else {
        [self showFromView:view belowView:belowView animated:animated];
    }
}


- (void)showFromView:(UIView *)view belowView:(UIView *)belowView animated:(BOOL)animated {
    self.activeView = view;
    self.topOffset = belowView.height;
    
    self.view.width = self.activeView.width;
    self.view.height = self.tableView.contentSize.height;
    self.view.top = -self.view.height + self.topOffset;
    
    self.overlayView.width = self.activeView.width;
    self.overlayView.height = self.activeView.height - belowView.height;
    self.overlayView.top = self.topOffset;
    
    [self.activeView insertSubview:self.overlayView belowSubview:belowView];
    [self.activeView insertSubview:self.view belowSubview:belowView];
    [self showCurtain:animated];
}


- (void)showCurtain:(BOOL)animated {
    [self showCurtain:animated completionBlock:NULL];
}

- (void)showCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    
    self.overlayView.alpha = 0.0;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.overlayView.alpha = 0.6;
        self.view.top = self.topOffset;
    } completion:^(BOOL finished){
        if (completionBlock) {
            completionBlock();
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)hideCurtain:(BOOL)animated {
    [self hideCurtain:animated completionBlock:NULL];
}

- (void)hideCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.2 : 0.0;
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.overlayView.alpha = 0.0;
        self.view.top = -self.view.height + self.topOffset;
    } completion:^(BOOL finished){
        [self.overlayView removeFromSuperview];
        [self.view removeFromSuperview];
        self.activeView = nil;
        
        if (completionBlock) {
            completionBlock();
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

#pragma mark - Custom TableView Methods

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    // Subclass should/may implement
    return [PSCell class];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate numberOfRowsInCurtainController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 2.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 2.0)];
//    v.backgroundColor = [UIColor darkGrayColor];
//    return v;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = CELL_BG_COLOR;
}

- (void)tableView:(UITableView *)tableView configureCell:(PSCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    id item = [self.delegate curtainController:self rowAtIndex:indexPath.row];
    cell.imageView.image = [item valueForKey:@"icon"];
    cell.textLabel.text = [item valueForKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        cellClass = [UITableViewCell class];
    }
    NSString *reuseIdentifier = NSStringFromClass(cellClass);
    
    id cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self hideCurtain:YES completionBlock:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(curtainController:selectedRowAtIndex:)]) {
            [self.delegate curtainController:self selectedRowAtIndex:indexPath.row];
        }
    }];
}

#pragma mark - GR

- (void)hideCurtainFromTap:(UITapGestureRecognizer *)gr {
    [self hideCurtain:YES];
}


@end
