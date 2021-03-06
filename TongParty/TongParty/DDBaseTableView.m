//
//  DDBaseTableView.m
//  TongParty
//
//  Created by 方冬冬 on 2017/9/14.
//  Copyright © 2017年 桐聚. All rights reserved.
//

#import "DDBaseTableView.h"

@interface DDBaseTableView()

@end

@implementation DDBaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.tableFooterView = [UIView new];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/** 注册普通的UITableViewCell*/
- (void)tj_registerCellClass:(Class)cellClass identifier:(NSString *)identifier {
    if (cellClass && identifier.length) {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}
/** 注册一个从xib中加载的UITableViewCell*/
- (void)tj_registerCellNib:(Class)cellNib nibIdentifier:(NSString *)nibIdentifier {
    if (cellNib && nibIdentifier.length) {
        UINib *nib = [UINib nibWithNibName:[cellNib description] bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:nibIdentifier];
    }
}

/** 注册一个普通的UITableViewHeaderFooterView*/
- (void)tj_registerHeaderFooterClass:(Class)headerFooterClass identifier:(NSString *)identifier {
    if (headerFooterClass && identifier.length) {
        [self registerClass:headerFooterClass forHeaderFooterViewReuseIdentifier:identifier];
    }
}
/** 注册一个从xib中加载的UITableViewHeaderFooterView*/
- (void)tj_registerHeaderFooterNib:(Class)headerFooterNib nibIdentifier:(NSString *)nibIdentifier {
    if (headerFooterNib && nibIdentifier.length) {
        UINib *nib = [UINib nibWithNibName:[headerFooterNib description] bundle:nil];
        [self registerNib:nib forHeaderFooterViewReuseIdentifier:nibIdentifier];
    };
}

- (void)tj_updateWithUpdateBlock:(void (^)(DDBaseTableView *tableView))updateBlock {
    if (updateBlock) {
        [self beginUpdates];
        updateBlock(self);
        [self endUpdates];
    }
}
- (UITableViewCell *)tj_cellAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return nil;
    NSInteger sectionNumber = self.numberOfSections;
    NSInteger section = indexPath.section;
    NSInteger rowNumber = [self numberOfRowsInSection:section];
    if (indexPath.section + 1 > sectionNumber || indexPath.section < 0) { // section 越界
        NSLog(@"刷新section: %ld 已经越界, 总组数: %ld", indexPath.section, sectionNumber);
        return nil;
    } else if (indexPath.row + 1 > rowNumber || indexPath.row < 0) { // row 越界
        NSLog(@"刷新row: %ld 已经越界, 总行数: %ld 所在section: %ld", indexPath.row, rowNumber, section);
        return nil;
    }
    return [self cellForRowAtIndexPath:indexPath];
}
/** 刷新单行、动画默认*/
- (void)tj_reloadSingleRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tj_reloadSingleRowAtIndexPath:indexPath animation:None];
}
- (void)tj_reloadSingleRowAtIndexPath:(NSIndexPath *)indexPath animation:(DDBaseTableViewRowAnimation)animation {
    if (!indexPath) return ;
    NSInteger sectionNumber = self.numberOfSections;
    NSInteger section = indexPath.section;
    NSInteger rowNumber = [self numberOfRowsInSection:section];
    if (indexPath.section + 1 > sectionNumber || indexPath.section < 0) { // section 越界
        NSLog(@"刷新section: %ld 已经越界, 总组数: %ld", indexPath.section, sectionNumber);
    } else if (indexPath.row + 1 > rowNumber || indexPath.row < 0) { // row 越界
        NSLog(@"刷新row: %ld 已经越界, 总行数: %ld 所在section: %ld", indexPath.row, rowNumber, section);
    } else {
        [self beginUpdates];
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
}

/** 刷新多行、动画默认*/
- (void)tj_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self tj_reloadRowsAtIndexPaths:indexPaths animation:None];
}
- (void)tj_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animation:(DDBaseTableViewRowAnimation)animation {
    if (!indexPaths.count) return ;
    WeakSelf(weakSelf);
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSIndexPath class]]) {
            [weakSelf tj_reloadSingleRowAtIndexPath:obj animation:animation];
        }
    }];
}

/** 刷新某个section、动画默认*/
- (void)tj_reloadSingleSection:(NSInteger)section {
    [self tj_reloadSingleSection:section animation:None];
}
- (void)tj_reloadSingleSection:(NSInteger)section animation:(DDBaseTableViewRowAnimation)animation {
    NSInteger sectionNumber = self.numberOfSections;
    if (section + 1 > sectionNumber || section < 0) { // section越界
        NSLog(@"刷新section: %ld 已经越界, 总组数: %ld", section, sectionNumber);
    } else {
        [self beginUpdates];
        [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
}

/** 刷新多个section、动画默认*/
- (void)tj_reloadSections:(NSArray <NSNumber *>*)sections {
    [self tj_reloadSections:sections animation:None];
}
- (void)tj_reloadSections:(NSArray<NSNumber *> *)sections animation:(DDBaseTableViewRowAnimation)animation {
    if (!sections.count) return ;
    WeakSelf(weakSelf);
    [sections enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [weakSelf tj_reloadSingleSection:obj.integerValue animation:animation];
        }
    }];
}

/** 删除单行、动画默认*/
- (void)tj_deleteSingleRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tj_deleteSingleRowAtIndexPath:indexPath animation:Fade];
}
- (void)tj_deleteSingleRowAtIndexPath:(NSIndexPath *)indexPath animation:(DDBaseTableViewRowAnimation)animation {
    if (!indexPath) return ;
    NSInteger sectionNumber = self.numberOfSections;
    NSInteger section = indexPath.section;
    NSInteger rowNumber = [self numberOfRowsInSection:section];
    
    NSLog(@"sectionNumber %ld  section%ld rowNumber%ld",sectionNumber, section , rowNumber);
    if (indexPath.section + 1 > sectionNumber || indexPath.section < 0) { // section 越界
        NSLog(@"删除section: %ld 已经越界, 总组数: %ld", indexPath.section, sectionNumber);
    } else if (indexPath.row + 1 > rowNumber || indexPath.row < 0) { // row 越界
        NSLog(@"删除row: %ld 已经越界, 总行数: %ld 所在section: %ld", indexPath.row, rowNumber, section);
    } else {
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
}

/** 删除多行、动画默认*/
- (void)tj_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self tj_deleteRowsAtIndexPaths:indexPaths animation:Fade];
}
- (void)tj_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animation:(DDBaseTableViewRowAnimation)animation {
    if (!indexPaths.count) return ;
    WeakSelf(weakSelf);
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSIndexPath class]]) {
            [weakSelf tj_deleteSingleRowAtIndexPath:obj animation:animation];
        }
    }];
}

/** 删除某个section、动画默认*/
- (void)tj_deleteSingleSection:(NSInteger)section {
    
    [self tj_deleteSingleSection:section animation:Fade];
}
- (void)tj_deleteSingleSection:(NSInteger)section animation:(DDBaseTableViewRowAnimation)animation {
    NSInteger sectionNumber = self.numberOfSections;
    if (section + 1 > sectionNumber || section < 0) { // section 越界
        NSLog(@"刷新section: %ld 已经越界, 总组数: %ld", section, sectionNumber);
    } else {
        [self beginUpdates];
        [self deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
}

/** 删除多个section*/
- (void)tj_deleteSections:(NSArray *)sections {
    [self tj_deleteSections:sections animation:Fade];
}
- (void)tj_deleteSections:(NSArray<NSNumber *> *)sections animation:(DDBaseTableViewRowAnimation)animation {
    if (!sections.count) return ;
    WeakSelf(weakSelf);
    [sections enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [weakSelf tj_deleteSingleSection:obj.integerValue animation:animation];
        }
    }];
}

/** 增加单行 动画无*/
- (void)tj_insertSingleRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tj_insertSingleRowAtIndexPath:indexPath animation:None];
}
/** 增加单行，动画自定义*/
- (void)tj_insertSingleRowAtIndexPath:(NSIndexPath *)indexPath animation:(DDBaseTableViewRowAnimation)animation {
    if (!indexPath) return ;
    NSInteger sectionNumber = self.numberOfSections;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger rowNumber = [self numberOfRowsInSection:section];
    if (section > sectionNumber || section < 0) {
        // section 越界
        NSLog(@"section 越界 : %ld", section);
    } else if (row > rowNumber || row < 0) {
        NSLog(@"row 越界 : %ld", row);
    } else {
        [self beginUpdates];
        [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
    
}

/** 增加单section，动画无*/
- (void)tj_insertSingleSection:(NSInteger)section {
    [self tj_insertSingleSection:section animation:None];
}
/** 增加单section，动画自定义*/
- (void)tj_insertSingleSection:(NSInteger)section animation:(DDBaseTableViewRowAnimation)animation {
    NSInteger sectionNumber = self.numberOfSections;
    if (section + 1 > sectionNumber || section < 0) {
        // section越界
        NSLog(@" section 越界 : %ld", section);
    } else {
        [self beginUpdates];
        [self insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:(UITableViewRowAnimation)animation];
        [self endUpdates];
    }
}

/** 增加多行，动画无*/
- (void)tj_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self tj_insertRowsAtIndexPaths:indexPaths animation:None];
}
/** 增加多行，动画自定义*/
- (void)tj_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animation:(DDBaseTableViewRowAnimation)animation {
    if (indexPaths.count == 0) return ;
    WeakSelf(weakSelf);
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSIndexPath class]]) {
            [weakSelf tj_insertSingleRowAtIndexPath:obj animation:animation];
        }
    }];
}

/** 增加多section，动画无*/
- (void)tj_insertSections:(NSArray <NSNumber *>*)sections {
    [self tj_insertSections:sections animation:None];
}
/** 增加多section，动画默认*/
- (void)tj_insertSections:(NSArray <NSNumber *>*)sections animation:(DDBaseTableViewRowAnimation)animation {
    if (sections.count == 0) return ;
    WeakSelf(weakSelf);
    [sections enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [weakSelf tj_insertSingleSection:obj.integerValue animation:animation];
        }
    }];
}

/** 当有输入框的时候 点击tableview空白处，隐藏键盘*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id view = [super hitTest:point withEvent:event];
    if (![view isKindOfClass:[UITextField class]]) {
        [self endEditing:YES];
    }
    return view;
}


@end
