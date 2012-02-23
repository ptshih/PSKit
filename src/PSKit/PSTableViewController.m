//
//  PSTableViewController.m
//  PSKit
//
//  Created by Peter Shih on 2/14/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTableViewController.h"

@interface PSTableViewController (Private)

@end

@implementation PSTableViewController

@synthesize
items = _items,
searchItems = _searchItems,
sectionTitles = _sectionTitles,
selectedIndexes = _selectedIndexes,
cellCache = _cellCache,
contentOffset = _contentOffset,

tableView = _tableView,
pullRefreshView = _pullRefreshView,
searchBar = _searchBar,
loadMoreView = _loadMoreView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        self.searchItems = [NSMutableArray array];
        self.sectionTitles = [NSMutableArray array];
        self.selectedIndexes = [NSMutableDictionary dictionary];
        self.cellCache = [NSMutableArray array];;
        
        // View State
        self.contentOffset = CGPointZero;
        
        _pagingStart = 0;
        _pagingCount = 0;
        _pagingTotal = 0;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Save view state
    self.contentOffset = self.tableView.contentOffset;
    
    if (self.searchBar) self.searchBar.delegate = nil;
    if (self.tableView) self.tableView.delegate = nil, self.tableView.dataSource = nil;
    if (self.pullRefreshView) self.pullRefreshView.delegate = nil;
    
    RELEASE_SAFELY(_tableView);
    RELEASE_SAFELY(_searchBar);
    RELEASE_SAFELY(_pullRefreshView);
    RELEASE_SAFELY(_loadMoreView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {    
    // Delegates
    if (self.searchBar) self.searchBar.delegate = nil;
    if (self.tableView) self.tableView.delegate = nil, self.tableView.dataSource = nil;
    if (self.pullRefreshView) self.pullRefreshView.delegate = nil;
    
    // Views
    RELEASE_SAFELY(_tableView);
    RELEASE_SAFELY(_searchBar);
    RELEASE_SAFELY(_pullRefreshView);
    RELEASE_SAFELY(_loadMoreView);
    
    // Non-Views
    RELEASE_SAFELY(_sectionTitles);
    RELEASE_SAFELY(_selectedIndexes);
    RELEASE_SAFELY(_items);
    RELEASE_SAFELY(_searchItems);
    RELEASE_SAFELY(_cellCache);
    
    [super dealloc];
}

#pragma mark - View
// SUBCLASS CAN OPTIONALLY IMPLEMENT IF THEY WANT A SEARCH BAR
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles {
    [self setupSearchDisplayControllerWithScopeButtonTitles:scopeButtonTitles andPlaceholder:nil];
}

- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder {
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    self.searchBar.delegate = self;
    //  self.searchBar.tintColor = [UIColor darkGrayColor];
    self.searchBar.placeholder = placeholder;
    self.searchBar.barStyle = UIBarStyleBlackOpaque;
    //  self.searchBar.backgroundColor = [UIColor clearColor];
    
    if (scopeButtonTitles) {
        self.searchBar.scopeButtonTitles = scopeButtonTitles;
    }
    
    self.tableView.tableHeaderView = self.searchBar;
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [searchController setDelegate:self];
    [searchController setSearchResultsDelegate:self];
    [searchController setSearchResultsDataSource:self];
}

// SUBCLASS SHOULD CALL THIS
- (void)setupTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle separatorColor:(UIColor *)separatorColor {
    self.tableView = [[[UITableView alloc] initWithFrame:frame style:style] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = separatorStyle;
    self.tableView.separatorColor = separatorColor;
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.backgroundView = nil;
    
    [self.view addSubview:self.tableView];
    
    // Setup optional header/footer
    if ([self respondsToSelector:@selector(setupTableHeader)]) {
        [self setupTableHeader];
    }
    if ([self respondsToSelector:@selector(setupTableFooter)]) {
        [self setupTableFooter];
    }
    if ([self respondsToSelector:@selector(setupLoadMoreView)]) {
        [self setupLoadMoreView];
    }
    
    // Set the active scrollView
    self.activeScrollView = self.tableView;
}

// SUBCLASS CAN OPTIONALLY CALL
- (void)setupPullRefresh {
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.view.frame.size.width, 48.0)] autorelease];
        self.pullRefreshView.scrollView = self.tableView;
        self.pullRefreshView.delegate = self;
        [self.tableView addSubview:self.pullRefreshView];		
    }
}

// This is the automatic load more style
//- (void)setupLoadMoreView {
//    _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
//    _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _loadMoreView.backgroundColor = [UIColor clearColor];
//    
//    UIImageView *bg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_lastcell.png"]] autorelease];
//    bg.autoresizingMask = ~UIViewAutoresizingNone;
//    
//    UILabel *l = [[[UILabel alloc] initWithFrame:_loadMoreView.bounds] autorelease];
//    l.backgroundColor = [UIColor clearColor];
//    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    l.text = @"Loading More...";
//    [PSStyleSheet applyStyle:@"loadMoreLabel" forLabel:l];
//    
//    // Activity
//    UIActivityIndicatorView *av = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
//    av.frame = CGRectMake(12, 12, 20, 20);
//    av.hidesWhenStopped = YES;
//    [av startAnimating];
//    
//    // Add to subview
//    [_loadMoreView addSubview:bg];
//    [_loadMoreView addSubview:l];
//    [_loadMoreView addSubview:av];
//}

#pragma mark - Utility Methods
- (void)resetPaging {
    _pagingStart = 0;
    _pagingTotal = _pagingCount;
}

//- (void)reloadDataSafely {
//    [_cellCache makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:NO]];
//    [self.tableView reloadData];
//    [_cellCache makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:YES]];
//}

#pragma mark - PSStateMachine
- (BOOL)dataIsAvailable {
    // Is this a searchResultsTable or just Table?
    NSArray *items = (self.tableView == self.searchDisplayController.searchResultsTableView) ? self.searchItems : self.items;
    
    // Check numSections
    if ([items count] > 0) {
        // Has more than 1 section, now check each section for numRows
        for (NSArray *section in items) {
            if ([section count] > 0) {
                // Found a non-empty section
                return YES;
            }
        }
        // All sections are empty
        return NO;
    } else {
        // Has no sections
        return NO;
    }
}

- (void)dataSourceShouldLoadObjects:(id)objects animated:(BOOL)animated {
    self.items = objects;
    
    BOOL hasData = NO;
    for (NSArray *rows in self.items) {
        if ([rows count] > 0) {
            hasData = YES;
            break;
        }
    }
    
#warning animated is broken
    if (animated) animated = NO;
    if (hasData && animated) {
        // Delete all existing data
        NSIndexSet *newSectionIndexSet = nil;
        NSIndexSet *deleteSectionIndexSet = nil;
        NSMutableArray *newRowIndexPaths = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *deleteRowIndexPaths = [NSMutableArray arrayWithCapacity:1];
        //  NSMutableArray *updateRowIndexPaths = [NSMutableArray arrayWithCapacity:1];
        
        // Delete all sections
        if ([self.items count] > 0) {
            deleteSectionIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.items count])];
        }
        
        // Delete all rows
        for (int section = 0; section < [self.items count]; section++) {
            for (int row = 0; row < [[self.items objectAtIndex:section] count]; row++) {
                [deleteRowIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        
        // Set new items
        self.items = objects;
        
        // Add new sections
        newSectionIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [objects count])];
        
        // Add new rows
        for (int section = 0; section < [self.items count]; section++) {
            for (int row = 0; row < [[self.items objectAtIndex:section] count]; row++) {
                [newRowIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        
        //
        // BEGIN TABLEVIEW ANIMATION BLOCK
        //
        [_cellCache makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:NO]];
        [self.tableView beginUpdates];
        
        // These are the sections that need to be inserted
        if (deleteSectionIndexSet) {
            [self.tableView deleteSections:deleteSectionIndexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (newSectionIndexSet) {
            [self.tableView insertSections:newSectionIndexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        
        // These are the rows that need to be deleted
        if ([deleteRowIndexPaths count] > 0) {
            [self.tableView deleteRowsAtIndexPaths:deleteRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        // These are the new rows that need to be inserted
        if ([newRowIndexPaths count] > 0) {
            [self.tableView insertRowsAtIndexPaths:newRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.tableView endUpdates];
        [_cellCache makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:YES]];
        //
        // END TABLEVIEW ANIMATION BLOCK
        //
    } else {
        [self.tableView reloadData];
    }
}

- (void)dataSourceShouldLoadMoreObjects:(id)objects forSection:(NSInteger)section shouldAnimate:(BOOL)shouldAnimate {
    
    // This is a load more
    NSMutableArray *newRowIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    int rowStart = [[self.items objectAtIndex:section] count]; // row starting offset for inserting
    [[self.items objectAtIndex:section] addObjectsFromArray:objects];
    for (int row = rowStart; row < [[self.items objectAtIndex:section] count]; row++) {
        [newRowIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    if (shouldAnimate) {
        //
        // BEGIN TABLEVIEW ANIMATION BLOCK
        //
        [self.tableView beginUpdates];
        
        // These are the new rows that need to be inserted
        if ([newRowIndexPaths count] > 0) {
            [self.tableView insertRowsAtIndexPaths:newRowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.tableView endUpdates];
        //
        // END TABLEVIEW ANIMATION BLOCK
        //
    } else {
        [self.tableView reloadData];
    }
}

- (void)loadMore {
    self.reloading = YES;
}

#pragma mark - Custom TableView Methods
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    // Subclass should/may implement
    return [PSCell class];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
    // Return whether the cell at the specified index path is selected or not
    NSNumber *selectedIndex = [_selectedIndexes objectForKey:indexPath];
    return selectedIndex == nil ? NO : [selectedIndex boolValue];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath withObject:(id)object {
    // subclass should implement
    return NO;
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    id cell = nil;
    NSString *reuseIdentifier = [cellClass reuseIdentifier];
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil) { 
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        [_cellCache addObject:cell];
    }
    
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchItems count];
    } else {
        return [_items count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[_searchItems objectAtIndex:section] count];
    } else {
        return [[_items objectAtIndex:section] count];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self respondsToSelector:@selector(rowBackgroundViewForIndexPath:selected:)]) {
        cell.backgroundView = [self rowBackgroundViewForIndexPath:indexPath selected:NO];
        cell.selectedBackgroundView = [self rowBackgroundViewForIndexPath:indexPath selected:YES];
    }
}

#pragma mark - UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // SUBCLASS MUST IMPLEMENT
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    //  [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    tableView.rowHeight = self.tableView.rowHeight;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorColor = self.tableView.separatorColor;
    tableView.separatorStyle = self.tableView.separatorStyle;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    //  [tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    // Subclass may implement
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    // Subclass may implement
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidEndDragging:scrollView
                                                   willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[PSURLCache sharedCache] suspend];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidScroll:scrollView];
    }
}

#pragma mark - PSPullRefreshViewDelegate
- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {
    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateRefreshing];
}

- (void)endRefresh {
    [super endRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateIdle];
}

@end