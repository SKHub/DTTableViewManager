//
//  SearchController.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.06.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SearchController.h"

@implementation SearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Capitals" ofType:@"plist"];
    NSArray * continents = [NSArray arrayWithContentsOfFile:path];
    
    for (int section=0;section <[continents count]; section ++)
    {
        NSDictionary * continent = continents[section];
        NSDictionary * capitals = [[continents[section] allValues] lastObject];
        for (NSString * country in [capitals allKeys])
        {
            [self addTableItem:[Example exampleWithText:capitals[country]
                                             andDetails:country]
                     toSection:section];
        }
        [self.sectionHeaderTitles addObject:[[continent allKeys] lastObject]];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}


@end
