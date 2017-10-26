//
//  DLTableView.h
//  WMPayDayLoan
//
//  Created by LiZhengDa on 2017/10/19.
//  Copyright © 2017年 WUMII. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    DLTableViewScrollDirectionVertical,
    DLTableViewScrollDirectionHorizontal,
} DLTableViewScrollDirection;

typedef enum : NSUInteger {
    DLTableViewScrollPositionTop,
    DLTableViewScrollPositionMiddle,
    DLTableViewScrollPositionBottom,
} DLTableViewScrollPosition;

typedef enum : NSUInteger {
    DLTableViewCellStyleCustom,
    DLTableViewCellStyleDefault,
} DLTableViewCellStyle;

@class DLTableView;
@class DLTableViewCell;
@protocol DLTableViewDelegate<UIScrollViewDelegate>
@optional
- (void)tableView:(DLTableView *)tableView didEndDisplayingCell:(DLTableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)tableView:(DLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(DLTableView *)tableView widthForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(DLTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(DLTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index;
@end

@protocol DLTableViewDataSource<NSObject>

@required

- (NSInteger)tableView:(DLTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (DLTableViewCell *)tableView:(DLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DLTableViewCell : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *containerView;
- (instancetype)initWithStyle:(DLTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface DLTableView : UIScrollView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) id<DLTableViewDelegate> tableViewDelegate;
@property (nonatomic, weak) id<DLTableViewDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray<DLTableViewCell *> *visibileCells;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *visibileCellsIndexPath;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, copy) void(^layout)(DLTableView *tableView);
@property (nonatomic, assign) BOOL disableLongPressGest;
@property (nonatomic, assign) BOOL disableTapGest;
@property (nonatomic, assign) BOOL enableCycleScroll;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

- (DLTableViewCell *)cellForRowAt:(NSIndexPath *)indexPath;
- (DLTableViewCell *)insertCellWithIndexPath:(NSIndexPath *)indexPath;
- (void)reloadViews;
- (void)reloadData;
- (void)deselectRowAt:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (DLTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)scrollToRowAt:(NSIndexPath *)indexPath at:(DLTableViewScrollPosition)scrollPosition animated:(BOOL)animated;
-(void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index atScrollPosition:(DLTableViewScrollPosition)scrollPosition animated:(BOOL)animated complete:(void(^)(BOOL finished))complete;
- (CGPoint)getOffsetWithNoCycleForIndexPath:(NSIndexPath *)indexPath;
- (CGPoint)restraintWithOffSetXOrY:(CGFloat)offSetXOrY;
- (CGPoint)restraintWithOffSet:(CGPoint)offSet;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

@interface UIView(DLADD)
- (NSArray<UIView *> *)whichSubviewContains:(CGPoint)point;
- (void)removeAllSubviews;
@end
