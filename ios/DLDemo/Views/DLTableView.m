//
//  DLTableView.m
//  WMPayDayLoan
//
//  Created by LiZhengDa on 2017/10/19.
//  Copyright © 2017年 WUMII. All rights reserved.
//

#import "DLTableView.h"

#define DLTableViewCellDidChange @"DLTableViewCellDidChange"


@implementation UIView (DLADD)

- (NSArray<UIView *> *)whichSubviewContains:(CGPoint)point {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for (UIView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            [ret addObject:view];
        }
    }
    return ret.copy;
}

- (void)removeAllSubviews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface DLTableViewCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *selectedBackgroundColorView;
@property (nonatomic, copy) NSString *reuseID;

@end

@implementation DLTableViewCell

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.containerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.selectedBackgroundColorView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customStyle];
    }
    return self;
}

- (instancetype)initWithStyle:(DLTableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self customStyle];
        self.titleLabel.hidden = style == DLTableViewCellStyleCustom;
        self.reuseID = reuseIdentifier;
    }
    return self;
}

- (void)customStyle {
    self.selectedBackgroundColorView = [UIView new];
    self.selectedBackgroundColorView.hidden = YES;
    self.selectedBackgroundColorView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.9];
    self.titleLabel = [UILabel new];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blueColor];
    self.containerView = [UIView new];
    [self.containerView addSubview:self.titleLabel];
    [self addSubview:self.containerView];
    [self addSubview:self.selectedBackgroundColorView];
}

@end

static CGFloat DefaultCellLength = 64;
@interface DLTableView()

@property (nonatomic, strong) NSMutableSet<DLTableViewCell *> *reuseCellsSet;
@property (nonatomic, assign) BOOL isContentSizeLessThanFrameSize;
@property (nonatomic, assign) DLTableViewScrollDirection scrollDirection;
@property (nonatomic, assign) BOOL isPositionForTableFooterViewKnown;
@property (nonatomic, strong) UITapGestureRecognizer *tapGest;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGest;
@property (nonatomic, strong) DLTableViewCell *pressedCell;
@property (nonatomic, assign) CGPoint lastTouchPoint;

@end

@implementation DLTableView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recenterIfNecessary];
    [self tileCellsInVisibleBounds:[self convertRect:self.bounds toView:self.containerView]];
    if (self.layout) {
        self.layout(self);
    }
}

- (DLTableViewCell *)cellForRowAt:(NSIndexPath *)indexPath {
    NSInteger index = [self.visibileCellsIndexPath indexOfObject:indexPath];
    if (index != NSNotFound) {
        return self.visibileCells[index];
    }
    return nil;
}

- (void)recenterIfNecessary {
    if (!self.enableCycleScroll) {
        return;
    }
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentLength = self.scrollDirection == DLTableViewScrollDirectionVertical ? self.contentSize.height : self.contentSize.width;
    CGFloat centerOffsetXOrY = (contentLength - (self.scrollDirection == DLTableViewScrollDirectionVertical ? self.bounds.size.height : self.bounds.size.width)) / 2;
    CGFloat distanceFromCenterXOrY = fabs((self.scrollDirection == DLTableViewScrollDirectionVertical ? currentOffset.y : currentOffset.x) - centerOffsetXOrY);
    
    if (distanceFromCenterXOrY > contentLength/4) {
        self.contentOffset = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGPointMake(currentOffset.x, centerOffsetXOrY) : CGPointMake(centerOffsetXOrY, currentOffset.y);
        for (DLTableViewCell *cell in self.visibileCells) {
            CGPoint center = [self.containerView convertPoint:cell.center toView:self];
            if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                center.y += (centerOffsetXOrY - currentOffset.y);
            } else {
                center.x += (centerOffsetXOrY - currentOffset.x);
            }
            cell.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)tileCellsInVisibleBounds:(CGRect)visibleBounds {
    BOOL cellChange = NO;
    NSInteger visibleCellsCount = self.visibileCells.count;
    CGFloat minXOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMinY(visibleBounds) : CGRectGetMinX(visibleBounds);
    CGFloat maxXOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMaxY(visibleBounds) : CGRectGetMaxX(visibleBounds);
    
    if (self.visibileCells.count == 0) {
        [self placeNewCellOnNextEdge:minXOrY];
    }
    
    DLTableViewCell *lastCell = self.visibileCells.lastObject;
    CGFloat nextEdge = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMaxY(lastCell.frame): CGRectGetMaxX(lastCell.frame);
    
    while (nextEdge < maxXOrY) {
        nextEdge = [self placeNewCellOnNextEdge:nextEdge];
    }
    
    if (nextEdge == CGFLOAT_MAX) {
        CGSize needContentSize = CGSizeZero;
        if (self.enableCycleScroll || self.tableFooterView == nil) {
            needContentSize = self.scrollDirection == DLTableViewScrollDirectionVertical ?
            CGSizeMake(self.contentSize.width, CGRectGetMaxY(self.visibileCells.lastObject.frame)) :
            CGSizeMake(CGRectGetMaxX(self.visibileCells.lastObject.frame), self.contentSize.height);
        } else if (self.tableFooterView) {
            if (!self.isPositionForTableFooterViewKnown) {
                CGRect frame = self.tableFooterView.frame;
                if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                    frame.origin.y = CGRectGetMaxY(self.visibileCells.lastObject.frame);
                } else {
                    frame.origin.x = CGRectGetMaxX(self.visibileCells.lastObject.frame);
                }
                self.tableFooterView.frame = frame;
                self.isPositionForTableFooterViewKnown = YES;
            }
            needContentSize = self.scrollDirection == DLTableViewScrollDirectionVertical ?
            CGSizeMake(self.contentSize.width, CGRectGetMaxY(self.tableFooterView.frame)) :
            CGSizeMake(CGRectGetMaxX(self.tableFooterView.frame), self.contentSize.height);
        }
        if (needContentSize.height < self.frame.size.height && self.scrollDirection == DLTableViewScrollDirectionVertical) {
            needContentSize.height = self.frame.size.height + 5;
        } else if (needContentSize.width < self.frame.size.width && self.scrollDirection == DLTableViewScrollDirectionHorizontal) {
            needContentSize.width = self.frame.size.width + 5;
        }
        self.contentSize = needContentSize;
    }
    
    DLTableViewCell *headCell = self.visibileCells.firstObject;
    CGFloat previousEdge = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMinY(headCell.frame) : CGRectGetMinX(headCell.frame);
    while (previousEdge > minXOrY) {
        previousEdge = [self placeNewCellOnPreviousEdge:previousEdge];
    }
    
    lastCell = self.visibileCells.lastObject;
    while ((self.scrollDirection == DLTableViewScrollDirectionVertical ? lastCell.frame.origin.y : lastCell.frame.origin.x) > maxXOrY) {
        if (self.visibileCells.count == 1) {
            // don't make visibileCells empty otherwise there is a problem
            break;
        }
        [lastCell removeFromSuperview];
        NSIndexPath *delIndexPath = self.visibileCellsIndexPath.lastObject;
        [self.visibileCellsIndexPath removeLastObject];
        DLTableViewCell *delCell = [self.visibileCells lastObject];
        [self.visibileCells removeLastObject];
        [self.reuseCellsSet addObject:delCell];
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
            [self.tableViewDelegate tableView:self didEndDisplayingCell:delCell forRowAtIndexPath:delIndexPath];
        }
        lastCell = self.visibileCells.lastObject;
        cellChange = YES;
    }
    
    headCell = self.visibileCells.firstObject;
    while ((self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMaxY(headCell.frame) : CGRectGetMaxX(headCell.frame)) < minXOrY) {
        if (self.visibileCells.count == 1) {
            break;
        }
        [headCell removeFromSuperview];
        NSIndexPath *delIndexPath = self.visibileCellsIndexPath.firstObject;
        [self.visibileCellsIndexPath removeObjectAtIndex:0];
        DLTableViewCell *delCell = self.visibileCells.firstObject;
        [self.visibileCells removeObjectAtIndex:0];
        [self.reuseCellsSet addObject:delCell];
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
            [self.tableViewDelegate tableView:self didEndDisplayingCell:delCell forRowAtIndexPath:delIndexPath];
        }
        headCell = self.visibileCells.firstObject;
        cellChange = YES;
    }
    
    if (cellChange || visibleCellsCount != self.visibileCells.count) {
        [NSNotificationCenter.defaultCenter postNotificationName:DLTableViewCellDidChange object:self];
    }
}

- (CGFloat)placeNewCellOnNextEdge:(CGFloat)nextEdge {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (self.visibileCellsIndexPath.count == 0) {
        [self.visibileCellsIndexPath addObject:indexPath];
    } else {
        NSInteger row = self.visibileCellsIndexPath.lastObject.row + 1;
        if (row >= [self.dataSource tableView:self numberOfRowsInSection:0]) {
            if (self.enableCycleScroll) {
                row = 0;
            } else {
                return CGFLOAT_MAX;
            }
        }
        indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.visibileCellsIndexPath addObject:indexPath];
    }
    
    DLTableViewCell *view = [self insertCellWithIndexPath:indexPath];
    CGFloat offsetXOrY = 0;
    if (self.tableHeaderView) {
        if (self.visibileCells.count == 0 && !self.enableCycleScroll) {
            offsetXOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? self.tableHeaderView.height : self.tableHeaderView.width;
        }
    }
    [self.visibileCells addObject:view];
    
    CGRect frame = view.frame;
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        frame.origin.y = nextEdge + offsetXOrY;
        frame.origin.x = 0;
        frame.size.width = self.frame.size.width;
        frame.size.height = DefaultCellLength;
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            frame.size.height = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
        }
    } else {
        frame.origin.y = 0;
        frame.origin.x = nextEdge + offsetXOrY;
        frame.size.width = DefaultCellLength;
        frame.size.height = self.frame.size.height;
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
            frame.size.width = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:indexPath];
        }
    }
    view.frame = frame;
    
    return self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMaxY(frame) : CGRectGetMaxX(frame);
}

- (CGFloat)placeNewCellOnPreviousEdge:(CGFloat)previousEdge {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (self.visibileCellsIndexPath.count == 0) {
        [self.visibileCellsIndexPath addObject:indexPath];
    } else {
        NSInteger row = self.visibileCellsIndexPath.firstObject.row - 1;
        if (row < 0) {
            if (self.enableCycleScroll) {
                row = [self.dataSource tableView:self numberOfRowsInSection:0] - 1;
            } else {
                return -CGFLOAT_MAX;
            }
        }
        indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.visibileCellsIndexPath insertObject:indexPath atIndex:0];
    }
    
    DLTableViewCell *view = [self insertCellWithIndexPath:indexPath];
    [self.visibileCells insertObject:view atIndex:0];
    
    CGRect frame = view.frame;
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        frame.origin.x = 0;
        frame.size.width = self.frame.size.width;
        frame.size.height = DefaultCellLength;
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            frame.size.height = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
        }
        frame.origin.y = previousEdge - frame.size.height;
    } else {
        frame.origin.y = 0;
        frame.size.width = DefaultCellLength;
        frame.size.height = self.frame.size.height;
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
            frame.size.width = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:indexPath];
        }
        frame.origin.x = previousEdge - frame.size.width;
    }
    view.frame = frame;
    
    return self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectGetMinY(frame) : CGRectGetMinX(frame);
}

- (DLTableViewCell *)insertCellWithIndexPath:(NSIndexPath *)indexPath {
    DLTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
    cell.frame = self.scrollDirection == DLTableViewScrollDirectionVertical ? CGRectMake(0, 0, 60, DefaultCellLength) : CGRectMake(0, 0, DefaultCellLength, 60);
    if (self.selectedColor) {
        cell.selectedBackgroundColorView.backgroundColor = self.selectedColor;
    }
    [self.containerView addSubview:cell];
    return cell;
}

- (void)reloadViews {
    if (self.scrollDirection == UIModalTransitionStyleCoverVertical) {
        self.contentSize = CGSizeMake(self.frame.size.width, 10000);
        if (!self.enableCycleScroll) {
            self.contentSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
        }
    } else {
        self.contentSize = CGSizeMake(10000, self.frame.size.height);
        if (!self.enableCycleScroll) {
            self.contentSize = CGSizeMake(CGFLOAT_MAX, self.frame.size.height);
        }
    }
    self.contentOffset = CGPointZero;
    self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    [self.reuseCellsSet removeAllObjects];
    [self.visibileCellsIndexPath removeAllObjects];
    [self.visibileCells removeAllObjects];
    [self.containerView removeAllSubviews];
    self.isPositionForTableFooterViewKnown = NO;
    
    if (!self.enableCycleScroll) {
        if (self.tableFooterView) {
            [self.containerView addSubview:self.tableFooterView];
        }
        if (self.tableHeaderView) {
            [self.containerView addSubview:self.tableHeaderView];
        }
        
        if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
            if (self.tableHeaderView) {
                CGRect frame = self.tableHeaderView.frame;
                frame.origin.x = 0;
                frame.origin.y = 0;
                frame.size.width = self.frame.size.width;
                self.tableHeaderView.frame = frame;
            }
        } else {
            if (self.tableHeaderView) {
                CGRect frame = self.tableHeaderView.frame;
                frame.origin.x = 0;
                frame.origin.y = 0;
                frame.size.height = self.frame.size.height;
                self.tableHeaderView.frame = frame;
            }
        }
        
        if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
            if (self.tableFooterView) {
                CGRect frame = self.tableFooterView.frame;
                frame.origin.x = 0;
                frame.origin.y = -CGFLOAT_MAX;
                frame.size.width = self.frame.size.width;
                self.tableFooterView.frame = frame;
            }
        } else {
            if (self.tableFooterView) {
                CGRect frame = self.tableFooterView.frame;
                frame.origin.x = -CGFLOAT_MAX;
                frame.origin.y = 0;
                frame.size.height = self.frame.size.height;
                self.tableFooterView.frame = frame;
            }
        }
    }
    [self setNeedsLayout];
}

- (void)reloadData {
    for (NSInteger index = 0; index < self.visibileCellsIndexPath.count; index ++) {
        NSIndexPath *indexPath = self.visibileCellsIndexPath[index];
        DLTableViewCell *newCell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
        DLTableViewCell *cell = self.visibileCells[index];
        newCell.frame = cell.frame;
        self.visibileCells[index] = newCell;
        [cell removeFromSuperview];
        [self.containerView addSubview:newCell];
    }
}

- (UITapGestureRecognizer *)tapGest {
    if (_tapGest == nil) {
        _tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
        _tapGest.cancelsTouchesInView = NO;
        [_tapGest requireGestureRecognizerToFail:self.longPressGest];
    }
    return _tapGest;
}

- (UILongPressGestureRecognizer *)longPressGest {
    if (_longPressGest == nil) {
        _longPressGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewLongPressDetected:)];
        _longPressGest.minimumPressDuration = 0.5;
    }
    return _longPressGest;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.visibileCells = [NSMutableArray arrayWithCapacity:10];
        self.visibileCellsIndexPath = [NSMutableArray arrayWithCapacity:10];
        self.reuseCellsSet = [NSMutableSet setWithCapacity:10];
        self.containerView = [UIView new];
        self.isContentSizeLessThanFrameSize = NO;
        [self addSubview:self.containerView];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        [self addGestureRecognizer:self.tapGest];
        [self addGestureRecognizer:self.longPressGest];
        self.lastTouchPoint = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
    }
    return self;
}

- (void)setDisableLongPressGest:(BOOL)disableLongPressGest {
    _disableLongPressGest = disableLongPressGest;
    self.longPressGest.enabled = !disableLongPressGest;
}

- (void)setDisableTapGest:(BOOL)disableTapGest {
    _disableTapGest = disableTapGest;
    self.tapGest.enabled = !disableTapGest;
}

- (void)tableViewTapped:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.containerView];
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIView *v = [self.containerView whichSubviewContains:point].lastObject;
        if (v && [v isKindOfClass:[DLTableViewCell class]]) {
            DLTableViewCell *cell = (DLTableViewCell *)v;
            NSInteger index = [self.visibileCells indexOfObject:cell];
            if (index != NSNotFound) {
                cell.selectedBackgroundColorView.hidden = NO;
                self.pressedCell = cell;
                if (!self.enableCycleScroll) {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                        [self.tableViewDelegate tableView:self didSelectRowAtIndexPath:self.visibileCellsIndexPath[index]];
                    }
                } else {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:withInternalIndex:)]) {
                        [self.tableViewDelegate tableView:self didSelectRowAtIndexPath:self.visibileCellsIndexPath[index] withInternalIndex:index];
                    }
                }
            }
        }
    }
}

- (void)tableViewLongPressDetected:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.containerView];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            UIView *v = [self.containerView whichSubviewContains:point].lastObject;
            if ([v isKindOfClass:[DLTableViewCell class]]) {
                DLTableViewCell *cell = (DLTableViewCell *)v;
                cell.selectedBackgroundColorView.hidden = NO;
                self.pressedCell = cell;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.pressedCell) {
                DLTableViewCell *cell = self.pressedCell;
                if (!CGRectContainsPoint(self.pressedCell.frame, point)) {
                    [UIView animateWithDuration:0.5 animations:^{
                        cell.selectedBackgroundColorView.alpha = 0;
                    } completion:^(BOOL finished) {
                        cell.selectedBackgroundColorView.hidden = YES;
                        cell.selectedBackgroundColorView.alpha = 1;
                    }];
                    self.pressedCell = nil;
                } else if (!CGPointEqualToPoint(self.lastTouchPoint, CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX))) {
                    if (self.scrollDirection == DLTableViewScrollDirectionVertical ? fabs(self.lastTouchPoint.y - point.y) > 5 : fabs(self.lastTouchPoint.x - point.x) > 5) {
                        [UIView animateWithDuration:0.5 animations:^{
                            cell.selectedBackgroundColorView.alpha = 0;
                        } completion:^(BOOL finished) {
                            cell.selectedBackgroundColorView.hidden = YES;
                            cell.selectedBackgroundColorView.alpha = 1;
                        }];
                        self.pressedCell = nil;
                    }
                }
            }
            break;
        }
        default: {
            if (self.pressedCell) {
                DLTableViewCell *cell = self.pressedCell;
                NSInteger index = [self.visibileCells indexOfObject:cell];
                if (index != NSNotFound) {
                    cell.selectedBackgroundColorView.hidden = NO;
                    self.pressedCell = cell;
                    if (!self.enableCycleScroll) {
                        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                            [self.tableViewDelegate tableView:self didSelectRowAtIndexPath:self.visibileCellsIndexPath[index]];
                        }
                    } else {
                        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:withInternalIndex:)]) {
                            [self.tableViewDelegate tableView:self didSelectRowAtIndexPath:self.visibileCellsIndexPath[index] withInternalIndex:index];
                        }
                    }
                }
            }
            break;
        }
    }
    self.lastTouchPoint = point;
}

- (void)deselectRowAt:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self deselectRowAtIndexPath:indexPath withInternalIndex:-1 animated:animated];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger idx = index;
    if (idx == -1) {
        for (NSInteger i = 0; i < self.visibileCellsIndexPath.count; i ++) {
            NSIndexPath *ip = self.visibileCellsIndexPath[i];
            if (indexPath.row == ip.row && indexPath.section == ip.section) {
                idx = i;
                break;
            }
        }
    }
    if (idx != -1) {
        DLTableViewCell *cell = self.visibileCells[idx];
        cell.selectedBackgroundColorView.hidden = NO;
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                cell.selectedBackgroundColorView.alpha = 0;
            } completion:^(BOOL finished) {
                cell.selectedBackgroundColorView.hidden = YES;
                cell.selectedBackgroundColorView.alpha = 1;
            }];
        }
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (DLTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    DLTableViewCell *theCell = nil;
    for (DLTableViewCell *cell in self.reuseCellsSet) {
        if ([cell.reuseID isEqualToString:identifier]) {
            theCell = cell;
            break;
        }
    }
    if (theCell) {
        [self.reuseCellsSet removeObject:theCell];
    }
    return theCell;
}

-(void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index atScrollPosition:(DLTableViewScrollPosition)scrollPosition animated:(BOOL)animated complete:(void(^)(BOOL finished))complete {
    CGPoint finialOffset = [self getOffsetAtIndexPath:indexPath withInternalIndex:index atScrollPosition:scrollPosition];
    [self setContentOffset:finialOffset animated:animated];
}

- (void)scrollToRowAt:(NSIndexPath *)indexPath at:(DLTableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    [self scrollToRowAtIndexPath:indexPath withInternalIndex:-1 atScrollPosition:scrollPosition animated:animated complete:nil];
}

- (CGPoint)getOffsetAtIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index atScrollPosition:(DLTableViewScrollPosition)scrollPosition {
    CGPoint finialOffset = CGPointZero;
    if (self.enableCycleScroll) {
        finialOffset = [self getOffsetForIndexPath:indexPath withInternalIndex:index];
    } else {
        finialOffset = [self getOffsetWithNoCycleForIndexPath:indexPath];
    }
    switch (scrollPosition) {
        case DLTableViewScrollPositionBottom: {
            CGFloat cellLength = DefaultCellLength;
            if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                    cellLength = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
                }
                finialOffset.y -= (self.frame.size.height - cellLength);
            } else {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                    cellLength = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:indexPath];
                }
                finialOffset.x -= (self.frame.size.width - cellLength);
            }
            break;
        }
        case DLTableViewScrollPositionMiddle: {
            CGFloat cellLength = DefaultCellLength;
            if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                    cellLength = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
                }
                finialOffset.y -= (self.frame.size.height/2 - cellLength/2);
            } else {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                    cellLength = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:indexPath];
                }
                finialOffset.x -= (self.frame.size.width/2 - cellLength/2);
            }
            break;
        }
        case DLTableViewScrollPositionTop: {
            break;
        }
    }
    if (!self.enableCycleScroll) {
        finialOffset = [self restraintWithOffSet:finialOffset];
    }
    return finialOffset;
}

- (CGPoint)getOffsetForIndexPath:(NSIndexPath *)indexPath withInternalIndex:(NSInteger)index {
    if (index != -1) {
        return self.visibileCells[index].frame.origin;
    }
    
    for (NSInteger i = 0; i < self.visibileCellsIndexPath.count; i ++) {
        NSIndexPath *index = self.visibileCellsIndexPath[i];
        if (index.row == indexPath.row && index.section == indexPath.section) {
            return self.visibileCells[i].frame.origin;
        }
    }
    
    NSIndexPath *headIndexPath = self.visibileCellsIndexPath.firstObject;
    NSIndexPath *lastIndexPath = self.visibileCellsIndexPath.lastObject;
    if (!headIndexPath || !lastIndexPath) {
        return CGPointZero;
    }
    
    NSInteger rowsCount = [self numberOfRowsInSection:indexPath.section];
    
    long distance1FromHead = labs(indexPath.row - headIndexPath.row);
    long distance2FromHead = rowsCount - labs(indexPath.row - headIndexPath.row);
    long distanceFromHead = distance1FromHead;
    if (distance2FromHead < distance1FromHead) {
        distanceFromHead = distance2FromHead;
    }
    
    long distance1FromLast = labs(indexPath.row - lastIndexPath.row);
    long distance2FromLast = rowsCount - labs(indexPath.row - lastIndexPath.row);
    long distanceFromLast = distance1FromLast;
    if (distance2FromLast < distance1FromLast) {
        distanceFromLast = distance2FromLast;
    }
    
    BOOL isAdd = NO;
    DLTableViewCell *startCell = self.visibileCells.firstObject;
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    
    if (distanceFromLast < distanceFromHead) {
        startCell = self.visibileCells.lastObject;
        tmpIndexPath = self.visibileCellsIndexPath.lastObject;
        isAdd = YES;
    } else {
        startCell = self.visibileCells.firstObject;
        tmpIndexPath = self.visibileCellsIndexPath.firstObject;
        isAdd = NO;
    }
    
    CGFloat xOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? startCell.frame.origin.y : startCell.frame.origin.x;
    while (YES) {
        if (isAdd) {
            tmpIndexPath = [NSIndexPath indexPathForRow:tmpIndexPath.row + 1 inSection:tmpIndexPath.section];
        } else {
            tmpIndexPath = [NSIndexPath indexPathForRow:tmpIndexPath.row - 1 inSection:tmpIndexPath.section];
        }
        if (tmpIndexPath.row < 0) {
            tmpIndexPath = [NSIndexPath indexPathForRow:rowsCount - 1 inSection:tmpIndexPath.section];
        } else if (tmpIndexPath.row > rowsCount - 1) {
            tmpIndexPath = [NSIndexPath indexPathForRow:0 inSection:tmpIndexPath.section];
        }
        if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
            if (isAdd) {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                    xOrY += [self.tableViewDelegate tableView:self heightForRowAtIndexPath:tmpIndexPath];
                } else {
                    xOrY += DefaultCellLength;
                }
            } else {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                    xOrY -= [self.tableViewDelegate tableView:self heightForRowAtIndexPath:tmpIndexPath];
                } else {
                    xOrY -= DefaultCellLength;
                }
            }
        } else {
            if (isAdd) {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                    xOrY += [self.tableViewDelegate tableView:self widthForRowAtIndexPath:tmpIndexPath];
                } else {
                    xOrY += DefaultCellLength;
                }
            } else {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                    xOrY -= [self.tableViewDelegate tableView:self widthForRowAtIndexPath:tmpIndexPath];
                } else {
                    xOrY -= DefaultCellLength;
                }
            }
        }
        if (tmpIndexPath.row == indexPath.row && tmpIndexPath.section == indexPath.section) {
            break;
        }
    }
    
    CGPoint finialOffset = CGPointZero;
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        finialOffset = CGPointMake(0, xOrY);
    } else {
        finialOffset = CGPointMake(xOrY, 0);
    }
    return finialOffset;
}

- (CGPoint)getOffsetWithNoCycleForIndexPath:(NSIndexPath *)indexPath {
    BOOL flag = NO;
    CGFloat xOrY = 0;
    for (NSInteger i = 0; i <self.visibileCellsIndexPath.count; i ++) {
        NSIndexPath *index = self.visibileCellsIndexPath[i];
        if (index.row == indexPath.row && index.section == indexPath.section) {
            xOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? self.visibileCells[i].frame.origin.y : self.visibileCells[i].frame.origin.x;
            flag = YES;
            break;
        }
    }
    
    if (!flag) {
        NSIndexPath *headIndexPath = self.visibileCellsIndexPath.firstObject;
        NSIndexPath *lastIndexPath = self.visibileCellsIndexPath.lastObject;

        if (indexPath.row < headIndexPath.row) {
            // -
            xOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? self.visibileCells.firstObject.frame.origin.y : self.visibileCells.firstObject.frame.origin.x;
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:headIndexPath.row inSection:headIndexPath.section];
            
            while (indexPath.row < tmpIndexPath.row) {
                tmpIndexPath = [NSIndexPath indexPathForRow:tmpIndexPath.row - 1 inSection:tmpIndexPath.section];
                CGFloat subValue = DefaultCellLength;
                if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                        subValue = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:tmpIndexPath.row inSection:0]];
                    }
                } else {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                        subValue = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:[NSIndexPath indexPathForRow:tmpIndexPath.row inSection:0]];
                    }
                }
                xOrY -= subValue;
            }
        } else {
            // +
            xOrY = self.scrollDirection == DLTableViewScrollDirectionVertical ? self.visibileCells.lastObject.frame.origin.y : self.visibileCells.lastObject.frame.origin.x;
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:lastIndexPath.row inSection:lastIndexPath.section];
            
            while (indexPath.row > tmpIndexPath.row) {
                tmpIndexPath = [NSIndexPath indexPathForRow:tmpIndexPath.row + 1 inSection:tmpIndexPath.section];
                CGFloat addValue = DefaultCellLength;
                if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                        addValue = [self.tableViewDelegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:tmpIndexPath.row inSection:0]];
                    }
                } else {
                    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:widthForRowAtIndexPath:)]) {
                        addValue = [self.tableViewDelegate tableView:self widthForRowAtIndexPath:[NSIndexPath indexPathForRow:tmpIndexPath.row inSection:0]];
                    }
                }
                xOrY += addValue;
            }
        }
    }
    CGPoint finialOffset = CGPointMake(xOrY, 0);
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        finialOffset = CGPointMake(0, xOrY);
    }
    return finialOffset;
}

- (CGPoint)restraintWithOffSetXOrY:(CGFloat)offSetXOrY {
    CGFloat xOrY = offSetXOrY;
    CGPoint finialOffset = CGPointZero;
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        if (xOrY < 0) {
            xOrY = 0;
        } else if (xOrY > self.contentSize.height - self.frame.size.height) {
            xOrY = self.contentSize.height - self.frame.size.height;
        }
        finialOffset = CGPointMake(0, xOrY);
    } else {
        if (xOrY < 0) {
            xOrY = 0;
        } else if( xOrY > self.contentSize.width - self.frame.size.width) {
            xOrY = self.contentSize.width - self.frame.size.width;
        }
        finialOffset = CGPointMake(xOrY, 0);
    }
    return finialOffset;
}

- (CGPoint)restraintWithOffSet:(CGPoint)offSet {
    CGFloat xOrY = offSet.x;
    if (self.scrollDirection == DLTableViewScrollDirectionVertical) {
        xOrY = offSet.y;
    }
    return [self restraintWithOffSetXOrY:xOrY];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableView:self numberOfRowsInSection:section];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
