//
//  PSSpringboardController.m
//  Appstand
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSSpringboardController.h"

@interface PSSpringboardController ()

@end

@implementation PSSpringboardController

@synthesize
delegate = _delegate;

@synthesize
viewControllers = _viewControllers,
selectedViewController = _selectedViewController,
selectedIndex = _selectedIndex;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedIndex = 0;
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) return;
    if (_selectedIndex == selectedIndex) return;
    
    _selectedIndex = selectedIndex;
    self.selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    if ([_selectedViewController isEqual:selectedViewController]) return;
    
    if (!_selectedViewController) {
        _selectedViewController = selectedViewController;
        return;
    }
    
    NSInteger oldIndex = [self.viewControllers indexOfObject:_selectedViewController];
    NSInteger newIndex = [self.viewControllers indexOfObject:selectedViewController];
    
    if ([self.viewControllers containsObject:selectedViewController]) {
        selectedViewController.view.alpha = 1.0;
        selectedViewController.view.frame = self.view.bounds;
        
        if (oldIndex < newIndex) {
            selectedViewController.view.top = selectedViewController.view.height;
        } else {
            selectedViewController.view.top = -selectedViewController.view.height;
        }
        
        
//        CGAffineTransform scaleStart = CGAffineTransformMakeScale(0.01, 0.01);
//        CGAffineTransform scaleEnd = CGAffineTransformMakeScale(1.0, 1.0);
//        selectedViewController.view.transform = scaleStart;
        
        [self transitionFromViewController:_selectedViewController toViewController:selectedViewController duration:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            selectedViewController.view.transform  = scaleEnd;
            
            selectedViewController.view.top = 0.0;
            if (oldIndex < newIndex) {
                _selectedViewController.view.top = -_selectedViewController.view.height;
            } else {
                _selectedViewController.view.top = _selectedViewController.view.height;
            }
            
            [selectedViewController willMoveToParentViewController:self];
//            _selectedViewController.view.alpha = 0.0;
        } completion:^(BOOL finished){
            _selectedViewController = selectedViewController;
            [selectedViewController didMoveToParentViewController:self];
            
            self.selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
        }];
    }
}

- (void)setViewControllers:(NSMutableArray *)viewControllers {
    _viewControllers = viewControllers;
    
    for (UIViewController *vc in viewControllers) {
        [self addChildViewController:vc];
    }
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // By now viewControllers should be set
    self.selectedViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
    [self.view addSubview:self.selectedViewController.view];
    [self.selectedViewController willMoveToParentViewController:self];
    [self.selectedViewController didMoveToParentViewController:self];
    self.selectedViewController.view.frame = self.view.bounds;

}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
