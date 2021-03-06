//
//  DTCellFactory.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTCellFactory.h"
#import "DTTableViewModelTransfer.h"
#import "UIView+Loading.h"

@interface DTCellFactory ()

@property (nonatomic,strong) NSMutableDictionary * cellMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * headerMappingsDictionary;
@property (nonatomic,strong) NSMutableDictionary * footerMappingsDictionary;

@end

@implementation DTCellFactory

- (NSMutableDictionary *)cellMappingsDictionary
{
    if (!_cellMappingsDictionary)
        _cellMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _cellMappingsDictionary;
}

-(NSMutableDictionary *)headerMappingsDictionary
{
    if (!_headerMappingsDictionary)
        _headerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _headerMappingsDictionary;
}

-(NSMutableDictionary *)footerMappingsDictionary
{
    if (!_footerMappingsDictionary)
        _footerMappingsDictionary = [[NSMutableDictionary alloc] init];
    return _footerMappingsDictionary;
}

#pragma mark - check for features

-(BOOL)tableViewRespondsToCellClassRegistration
{
    if ([[self.delegate tableView] respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)])
    {
        return YES;
    }
    return NO;
}

-(BOOL)tableViewRespondsToHeaderFooterViewNibRegistration
{
    if ([[self.delegate tableView] respondsToSelector:
         @selector(registerNib:forHeaderFooterViewReuseIdentifier:)])
    {
        return YES;
    }
    return NO;
}

-(void)checkClassForModelTransferProtocolSupport:(Class)class
{
    if (![class conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        NSString * reason = [NSString stringWithFormat:@"class %@ should conform\n"
                             "to DTTableViewModelTransfer protocol",
                             NSStringFromClass(class)];
        NSException * exc =
        [NSException exceptionWithName:@"DTTableViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
}

-(BOOL)nibExistsWIthNibName:(NSString *)nibName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:nibName
                                                     ofType:@"nib"];
    if (path)
    {
        return YES;
    }
    return NO;
}

-(void)throwCannotFindNibExceptionForNibName:(NSString *)nibName
{
    NSString * reason = [NSString stringWithFormat:@"cannot find nib with name: %@",
                         nibName];
    NSException * exc =
    [NSException exceptionWithName:@"DTTableViewManager API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

#pragma mark - class mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:cellClass];
    
    if ([self tableViewRespondsToCellClassRegistration])
    {
        [[self.delegate tableView] registerClass:cellClass
               forCellReuseIdentifier:[self reuseIdentifierForClass:modelClass]];
    }
    
    if ([self nibExistsWIthNibName:NSStringFromClass(cellClass)])
    {
        [self registerNibNamed:NSStringFromClass(cellClass)
                  forCellClass:cellClass
                    modelClass:modelClass];
    }
    
    [self.cellMappingsDictionary setObject:NSStringFromClass(cellClass)
                                    forKey:[self reuseIdentifierForClass:modelClass]];
}

-(void)registerNibNamed:(NSString *)nibName
           forCellClass:(Class)cellClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:cellClass];
    
    if (![self nibExistsWIthNibName:nibName])
    {
        [self throwCannotFindNibExceptionForNibName:nibName];
    }
    
    [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
         forCellReuseIdentifier:[self reuseIdentifierForClass:modelClass]];
    
    [self.cellMappingsDictionary setObject:NSStringFromClass(cellClass)
                                    forKey:[self reuseIdentifierForClass:modelClass]];
}

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(headerClass)
            forHeaderClass:headerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:headerClass];
    
    if (![self nibExistsWIthNibName:nibName])
    {
        [self throwCannotFindNibExceptionForNibName:nibName];
    }
    
    if ([self tableViewRespondsToHeaderFooterViewNibRegistration] &&
        [headerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
 forHeaderFooterViewReuseIdentifier:[self reuseIdentifierForClass:modelClass]];
    }
    
    [self.headerMappingsDictionary setObject:NSStringFromClass(headerClass)
                                      forKey:[self reuseIdentifierForClass:modelClass]];
}

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(footerClass)
            forFooterClass:footerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:footerClass];
    
    if (![self nibExistsWIthNibName:nibName])
    {
        [self throwCannotFindNibExceptionForNibName:nibName];
    }
    
    if ([self tableViewRespondsToHeaderFooterViewNibRegistration] &&
        [footerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [[self.delegate tableView] registerNib:[UINib nibWithNibName:nibName bundle:nil]
 forHeaderFooterViewReuseIdentifier:[self reuseIdentifierForClass:modelClass]];
    }
    
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:[self reuseIdentifierForClass:modelClass]];
}

-(void)setFooterClassMapping:(Class)footerClass forModelClass:(Class)modelClass
{
    [self.footerMappingsDictionary setObject:NSStringFromClass(footerClass)
                                      forKey:[self reuseIdentifierForClass:modelClass]];
}

#pragma mark - reuse

- (UITableViewCell *)reuseCellforModel:(id)model
                        reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell <DTTableViewModelTransfer> * cell =  [[self.delegate tableView] dequeueReusableCellWithIdentifier:
                                                          reuseIdentifier];
    [cell updateWithModel:model];
    return cell;
}


//This method should return nil if no class is registered
-(UIView *)reuseHeaderFooterViewForModel:(id)model
                           reuseIdentifier:(NSString *)reuseIdentifier
{
   if ([UITableViewHeaderFooterView class])
   {
       UIView <DTTableViewModelTransfer> * view =
       [[self.delegate tableView] dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
       
       [view updateWithModel:model];
       
       return view;
   }
    return nil;
}

#pragma mark - actions

- (UITableViewCell *)cellForModel:(NSObject *)model
{
    NSString * reuseIdentifier = [self reuseIdentifierForClass:[model class]];
    
    UITableViewCell *cell = [self reuseCellforModel:model
                                     reuseIdentifier:reuseIdentifier];

    return cell ? cell : [self cellWithModel:model reuseIdentifier:reuseIdentifier];
}

-(UIView *)headerViewForModel:(id)model
{
    NSString * reuseIdentifier = [self reuseIdentifierForClass:[model class]];
    
    UIView * view = [self reuseHeaderFooterViewForModel:model
                                         reuseIdentifier:reuseIdentifier];
    return view ? view : [self headerViewFromXibForModel:model];
}

-(UIView *)footerViewForModel:(id)model
{
    NSString * reuseIdentifier = [self reuseIdentifierForClass:[model class]];
    
    UIView * view = [self reuseHeaderFooterViewForModel:model
                                         reuseIdentifier:reuseIdentifier];
    
    return view? view : [self footerViewFromXibForModel:model];
}

- (Class)cellClassForModel:(NSObject *)model
{
    NSString *modelClassName = [self reuseIdentifierForClass:[model class]];
    if ([self.cellMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.cellMappingsDictionary objectForKey:modelClassName]);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have cell mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

-(Class)headerClassForModel:(id)model
{
    NSString *modelClassName = [self reuseIdentifierForClass:[model class]];
    if ([self.headerMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.headerMappingsDictionary objectForKey:modelClassName]);
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have header mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

-(Class)footerClassForModel:(id)model
{
    NSString *modelClassName = [self reuseIdentifierForClass:[model class]];
    if ([self.footerMappingsDictionary objectForKey:modelClassName])
    {
        return NSClassFromString([self.footerMappingsDictionary objectForKey:modelClassName]);
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"DTCellFactory does not have footer mapping for %@ class",
                            [model class]];
        @throw [NSException exceptionWithName:@"API misuse"
                                       reason:reason userInfo:nil];
    }
}

#pragma mark -

// http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW34

-(NSString *)reuseIdentifierForClass:(Class)class
{
    NSString * classString = NSStringFromClass(class);
    
    if ([classString isEqualToString:@"__NSCFConstantString"] ||
        [classString isEqualToString:@"__NSCFString"] ||
        class == [NSMutableString class])
    {
        return @"NSString";
    }
    if ([classString isEqualToString:@"__NSCFNumber"] ||
        [classString isEqualToString:@"__NSCFBoolean"])
    {
        return @"NSNumber";
    }
    if ([classString isEqualToString:@"__NSDictionaryI"] ||
        [classString isEqualToString:@"__NSDictionaryM"] ||
        class == [NSMutableDictionary class])
    {
        return @"NSDictionary";
    }
    if ([classString isEqualToString:@"__NSArrayI"] ||
        [classString isEqualToString:@"__NSArrayM"] ||
        class == [NSMutableArray class])
    {
        return @"NSArray";
    }
    return classString;
}

-(void)throwModelProtocolExceptionForClass:(Class)class
{
    NSString *reason = [NSString stringWithFormat:@"class '%@' does not conform to DTTableViewModelProtocol",
                        class];
    @throw [NSException exceptionWithName:@"API misuse"
                                   reason:reason userInfo:nil];
}

- (UITableViewCell *)cellWithModel:(id)model reuseIdentifier:(NSString *)reuseIdentifier
{
    Class cellClass = [self cellClassForModel:model];
    
    if ([cellClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UITableViewCell<DTTableViewModelTransfer> * cell;

        cell = [(UITableViewCell <DTTableViewModelTransfer>  *)[cellClass alloc]
                                                initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:reuseIdentifier];
        [cell updateWithModel:model];
        
        return cell;
    }
    
    [self throwModelProtocolExceptionForClass:cellClass];
    return nil;
}

-(UIView *)headerViewFromXibForModel:(id)model
{
    Class headerClass = [self headerClassForModel:model];
    
    if([headerClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UIView <DTTableViewModelTransfer> * headerView;
        
        headerView = [headerClass loadFromXib];
        [headerView updateWithModel:model];
        
        return headerView;
    }
    
    [self throwModelProtocolExceptionForClass:headerClass];
    return nil;
}

-(UIView *)footerViewFromXibForModel:(id)model
{
    Class footerClass = [self footerClassForModel:model];
    
    if([footerClass conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        UIView <DTTableViewModelTransfer> * footerView;
        
        footerView = [footerClass loadFromXib];
        [footerView updateWithModel:model];
        
        return footerView;
    }
    [self throwModelProtocolExceptionForClass:footerClass];
    return nil;
}

@end
