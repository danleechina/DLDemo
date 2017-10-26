//
//  DLPickerView.m
//  WMPayDayLoan
//
//  Created by LiZhengDa on 2017/10/19.
//  Copyright © 2017年 WUMII. All rights reserved.
//

#import "DLPickerView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DLPickerViewCell()
@property (nonatomic, strong) UIView *customView;
@end

@implementation DLPickerViewCell

- (instancetype)initWithStyle:(DLTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customView = [UIView new];
        [self.containerView addSubview:self.customView];
        self.titleLabel.font = [UIFont systemFontOfSize:23];
        self.titleLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.customView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

@end

static CGFloat DefaultRowHeight = 64;

@interface DLPickerViewInternalMagnifyingView: UIView
@property (nonatomic, weak) UIView *magnifyingView;
@property (nonatomic, assign) CGFloat scale;
@end

@implementation DLPickerViewInternalMagnifyingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scale = 1.04;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.magnifyingView) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(ctx, self.scale, self.scale);
        CGContextTranslateCTM(ctx, -self.frame.origin.x, -self.magnifyingView.frame.size.height/2 + DefaultRowHeight/2);
        [self.magnifyingView drawViewHierarchyInRect:self.magnifyingView.bounds afterScreenUpdates:YES];
    }
}

@end

static SystemSoundID mySound = 1000;

@interface DLPickerView()<UIScrollViewDelegate, DLTableViewDelegate, DLTableViewDataSource>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *topIndicatorLine;
@property (nonatomic, strong) UIView *bottomIndicatorLine;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *cachedCustomViews;
@property (nonatomic, strong) NSMutableArray<DLPickerViewInternalMagnifyingView *> *selectionIndicatorViews;
@property (nonatomic, strong) NSMutableArray<DLTableView *> *tableViews;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *isUserDraggingComponents;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *hasMakeSureNotOutOfRange;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *lastSelectedRow;
@property (nonatomic, assign) BOOL canPlaySound;
@property (nonatomic, assign) BOOL usingPickerViewLikeTabelView;
@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *centerMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *lastCenterRows;
@property (nonatomic, readwrite) NSInteger numberOfComponents;
@property (nonatomic, strong) UITapGestureRecognizer *tapGest;
@property (nonatomic, strong) NSMutableArray<UIView *> *customSelectionIndicatorViews;
@property (nonatomic, strong) UIView *customSelectionIndicatorView;
@property (nonatomic, assign) DLPickerViewSelectionStyle selectionStyle;

@end

@implementation DLPickerView

- (void)setShowsSelectionIndicator:(BOOL)showsSelectionIndicator {
    _showsSelectionIndicator = showsSelectionIndicator;
    self.topIndicatorLine.hidden = !showsSelectionIndicator;
    self.bottomIndicatorLine.hidden = !showsSelectionIndicator;
    for (UIView *view in self.selectionIndicatorViews) {
        view.hidden = !showsSelectionIndicator;
    }
}

- (void)setShowMaskViewsForSystemEffect:(BOOL)showMaskViewsForSystemEffect {
    _showsSelectionIndicator = showMaskViewsForSystemEffect;
    self.topMaskView.hidden = !showMaskViewsForSystemEffect;
    self.centerMaskView.hidden = !showMaskViewsForSystemEffect;
    self.bottomMaskView.hidden = !showMaskViewsForSystemEffect;
}

- (void)setLayoutStyle:(DLPickerViewLayoutStyle)layoutStyle {
    _layoutStyle = layoutStyle;
    if (layoutStyle == DLPickerViewLayoutStyleHorizontal) {
        self.transform = CGAffineTransformMakeRotation(0);
    } else {
        self.transform = CGAffineTransformMakeRotation(3.14159/2 * 3);
    }
}

- (void)setMagnifyingViewScale:(double)magnifyingViewScale {
    _magnifyingViewScale = magnifyingViewScale;
    for (DLPickerViewInternalMagnifyingView *view in self.selectionIndicatorViews) {
        view.scale = self.magnifyingViewScale;
        [view setNeedsDisplay];
    }
}

- (void)setEnableNightMode:(BOOL)enableNightMode {
    _enableNightMode = enableNightMode;
    self.backgroundColor = enableNightMode ? [UIColor blackColor] : [UIColor whiteColor];
}

- (void)setSoundURL:(NSURL *)soundURL {
    _soundURL = soundURL;
    if (_soundURL) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(_soundURL), &mySound);
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    for (UIView *v in self.selectionIndicatorViews) {
        v.backgroundColor = backgroundColor;
    }
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component {
    return [self.dataSource pickerView:self numberOfRowsInComponent:component];
}

- (CGSize)rowSizeAt:(NSInteger)row forComponent:(NSInteger)component {
    if (self.tableViews.count <= component) {
        return CGSizeZero;
    }
    DLTableView *tableView = self.tableViews[component];
    return CGSizeMake(tableView.frame.size.width,
                      [tableView.tableViewDelegate tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]);
}

- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIView *view = self.cachedCustomViews[[NSString stringWithFormat:@"%ld=%ld", (long)component, (long)row]];
    if (!view.superview) {
        return nil;
    }
    return view;
}

- (DLPickerViewCell *)cellForRow:(NSInteger)row inComponent:(NSInteger)component {
    DLTableView *tableView = self.tableViews[component];
    return (DLPickerViewCell *)[tableView cellForRowAt:[NSIndexPath indexPathForRow:row inSection:0]];
}

- (void)reloadAllComponents {
    self.canPlaySound = NO;
    [self setAppearance];
    for (DLTableView *tableView in self.tableViews) {
        [tableView reloadViews];
    }
}

- (void)reloadComponent:(NSInteger)component {
    if (self.tableViews.count <= component) {
        return;
    }
    [self.tableViews[component] reloadViews];
    [self nowWeCanPlaySound:0.5];
    [self initAppearanceForComponent:component delay:0.05];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    if (self.tableViews.count <= component) {
        return;
    }
    [self.tableViews[component] scrollToRowAt:[NSIndexPath indexPathForRow:row inSection:0] at:DLTableViewScrollPositionMiddle animated:animated];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    if (self.lastSelectedRow.count <= component) {
        return -1;
    }
    return self.lastSelectedRow[component].integerValue;
}

- (NSInteger)lastCenterRowInComponent:(NSInteger)component {
    if (self.lastCenterRows.count <= component) {
        return -1;
    }
    return self.lastCenterRows[component].integerValue;
}

- (DLPickerViewCell *)dequeueReusableCellForComponent:(NSInteger)component withIdentifier:(NSString *)identifier {
    return (DLPickerViewCell *)[self.tableViews[component] dequeueReusableCellWithIdentifier:identifier];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _showsSelectionIndicator = YES;
        _showMaskViewsForSystemEffect = YES;
        _enableScrollSound = YES;
        _layoutStyle = DLPickerViewLayoutStyleHorizontal;
        _magnifyingViewScale = 1.04;
        _enableNightMode = NO;
        
        _containerView = [UIView new];
        _topIndicatorLine = [UIView new];
        _bottomIndicatorLine = [UIView new];
        _cachedCustomViews = [NSMutableDictionary dictionary];
        _selectionIndicatorViews = [NSMutableArray arrayWithCapacity:2];
        _tableViews = [NSMutableArray arrayWithCapacity:2];
        _isUserDraggingComponents = [NSMutableArray arrayWithCapacity:2];
        _hasMakeSureNotOutOfRange = [NSMutableArray arrayWithCapacity:2];
        _lastSelectedRow = [NSMutableArray arrayWithCapacity:2];
        _canPlaySound = NO;
        _usingPickerViewLikeTabelView = NO;
        _topMaskView = [UIView new];
        _centerMaskView = [UIView new];
        _bottomMaskView = [UIView new];
        _lastCenterRows = [NSMutableArray arrayWithCapacity:2];
        _tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
        _tapGest.cancelsTouchesInView = NO;
        
        _numberOfComponents = 0;
        [self addSubview:_containerView];
        [self addSubview:_topIndicatorLine];
        [self addSubview:_bottomIndicatorLine];
        [self addSubview:_topMaskView];
        [self addSubview:_centerMaskView];
        [self addSubview:_bottomMaskView];
        _topIndicatorLine.hidden = NO;
        _bottomIndicatorLine.hidden = NO;
        _topMaskView.userInteractionEnabled = NO;
        _centerMaskView.userInteractionEnabled = NO;
        _bottomMaskView.userInteractionEnabled = NO;
        [self addGestureRecognizer:_tapGest];
        _backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)playSoundEffect {
    if (self.canPlaySound && self.enableScrollSound) {
        AudioServicesPlaySystemSound(mySound);
    }
}

- (void)tapDetected:(UITapGestureRecognizer *)sender {
    for (NSInteger i = 0; i < self.tableViews.count; i ++) {
        DLTableView *tableView = self.tableViews[i];
        CGPoint point = [sender locationInView:tableView];
        UIView *v = [tableView.containerView whichSubviewContains:point].lastObject;
        if (v && [v isKindOfClass:[DLTableViewCell class]]) {
            DLTableViewCell *cell = (DLTableViewCell *)v;
            NSInteger index = [tableView.visibileCells indexOfObject:cell];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = tableView.visibileCellsIndexPath[index];
                if (![self isSelectedOutOfRangeOfIndexPath:tableView indexPath:indexPath]) {
                    [tableView scrollToRowAtIndexPath:indexPath withInternalIndex:index atScrollPosition:DLTableViewScrollPositionMiddle animated:YES complete:nil];
                    tableView.userInteractionEnabled = NO;
                    [DLPickerView cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableUserInteractionRightAwayWithTableView:) object:tableView];
                    [self performSelector:@selector(enableUserInteractionRightAwayWithTableView:) withObject:tableView afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
                }
                break;
            }
        }
    }
}

- (void)enableUserInteractionRightAwayWithTableView:(DLTableView *)tableView {
    tableView.userInteractionEnabled = YES;
}

- (void)setAppearance {
    self.usingPickerViewLikeTabelView = NO;
    self.containerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.topIndicatorLine.frame = CGRectMake(0, self.frame.size.height/2 - DefaultRowHeight/2 - 1, self.frame.size.width, 1);
    self.bottomIndicatorLine.frame = CGRectMake(0, self.frame.size.height/2 + DefaultRowHeight/2, self.frame.size.width, 1);
    
    self.topMaskView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2 - DefaultRowHeight/2);
    self.centerMaskView.frame = CGRectMake(0, self.frame.size.height/2 - DefaultRowHeight/2, self.frame.size.width, DefaultRowHeight);
    self.bottomMaskView.frame = CGRectMake(0, self.frame.size.height/2 + DefaultRowHeight/2, self.frame.size.width, self.frame.size.height/2 - DefaultRowHeight/2);
    
    if (self.enableNightMode) {
        self.topIndicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.bottomIndicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.topMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.centerMaskView.backgroundColor = [UIColor clearColor];
        self.bottomMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    } else {
        self.topIndicatorLine.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.bottomIndicatorLine.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.topMaskView.backgroundColor = [UIColor colorWithRed: 242.0/255.0 green: 242.0/255.0 blue: 242.0/255.0 alpha:0.55];
        self.centerMaskView.backgroundColor = [UIColor clearColor];
        self.bottomMaskView.backgroundColor = [UIColor colorWithRed: 242.0/255.0 green: 242.0/255.0 blue: 242.0/255.0 alpha:0.55];
    }
    self.numberOfComponents = [self.dataSource numberOfComponentsIn:self];
    for (UIView *v in self.tableViews) {
        [v removeFromSuperview];
    }
    
    [self.tableViews removeAllObjects];
    [self.isUserDraggingComponents removeAllObjects];
    [self.hasMakeSureNotOutOfRange removeAllObjects];
    [self.selectionIndicatorViews removeAllObjects];
    [self.lastSelectedRow removeAllObjects];
    [self.customSelectionIndicatorViews removeAllObjects];
    [self.lastCenterRows removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    for (NSInteger index = 0; index < self.numberOfComponents; index ++) {
        // step 1: basic configure
        DLTableView *tableView = DLTableView.new;
        tableView.tag = index;
        tableView.delegate = self;
        tableView.tableViewDelegate = self;
        tableView.dataSource = self;
        tableView.selectedColor = [UIColor clearColor];
        tableView.backgroundColor =[UIColor clearColor];
        tableView.disableLongPressGest = YES;
        tableView.disableTapGest = YES;
//        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        tableView.layout = ^(DLTableView *tableView) {
            [weakSelf layout:tableView];
        };
        
        // step 2: set if enable cycle scroll
        if ([self.delegate respondsToSelector:@selector(enableCycleScrollIn:forComponent:)]) {
            tableView.enableCycleScroll = [self.delegate enableCycleScrollIn:self forComponent:index];
        } else {
            tableView.enableCycleScroll = NO;
        }
        
        // step 3: set frame
        CGRect frame = tableView.frame;
        if ([self.delegate respondsToSelector:@selector(pickerView:widthForComponent:)]) {
            frame.size.width = [self.delegate pickerView:self widthForComponent:index];
            if (self.tableViews.count > 0) {
                frame.origin.x = CGRectGetMaxX(self.tableViews.lastObject.frame);
            }
        } else {
            frame.size.width = self.frame.size.width / (CGFloat)self.numberOfComponents;
            frame.origin.x = (CGFloat)index * self.frame.size.width / (CGFloat)self.numberOfComponents;
        }
        frame.origin.y = 0;
        frame.size.height = self.frame.size.height;
        tableView.frame = frame;
        
        // step 4: if disable cycle scroll, make sure top and bottom cell can stop at center of tableView
        CGFloat firstCellHeight = DefaultRowHeight;
        CGFloat lastCellHeight = DefaultRowHeight;
        if (!tableView.enableCycleScroll) {
            if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
                firstCellHeight = [self.delegate pickerView:self rowHeightForComponent:tableView.tag];
                lastCellHeight = firstCellHeight;
            } else if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForRow:inComponent:)]) {
                firstCellHeight = [self.delegate pickerView:self rowHeightForRow:0 inComponent:tableView.tag];
                lastCellHeight = [self.delegate pickerView:self rowHeightForRow:[tableView numberOfRowsInSection:0] - 1 inComponent:tableView.tag];
            }
            
            tableView.tableHeaderView = UIView.new;
            tableView.tableFooterView = UIView.new;
            tableView.tableHeaderView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height/2 - firstCellHeight/2);
            tableView.tableFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height/2 - lastCellHeight/2);
            tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
            tableView.tableFooterView.backgroundColor = [UIColor clearColor];
        }
        
        // step 5: in the center of each tableView, there is a magnifying view.
        DLPickerViewInternalMagnifyingView *selectionIndicatorView = DLPickerViewInternalMagnifyingView.new;
        selectionIndicatorView.magnifyingView = self.containerView;
        selectionIndicatorView.backgroundColor = self.backgroundColor;
        selectionIndicatorView.userInteractionEnabled = NO;
        selectionIndicatorView.frame = CGRectMake(frame.origin.x, frame.size.height/2 - firstCellHeight/2, frame.size.width, firstCellHeight);
        selectionIndicatorView.hidden = !(self.showMaskViewsForSystemEffect && self.showsSelectionIndicator);
        
        // TODO: selection style for customing
        
        // step 6: update array and view
        [self.tableViews addObject:tableView];
        [self.isUserDraggingComponents addObject:@NO];
        [self.hasMakeSureNotOutOfRange addObject:@NO];
        [self.lastSelectedRow addObject:@-1];
        [self.lastCenterRows addObject:@-1];
        [self.selectionIndicatorViews addObject:selectionIndicatorView];
        [self.containerView addSubview:tableView];
        [self addSubview:selectionIndicatorView];
    }
    // Make components center
    CGFloat remainSpaceInHorizontal = self.frame.size.width - CGRectGetMaxX(self.tableViews.lastObject.frame);
    if  (remainSpaceInHorizontal > 1) {
        CGFloat offsetX = remainSpaceInHorizontal/2;
        for (UIView *v in self.tableViews) {
            CGRect f = v.frame;
            f.origin.x += offsetX;
            v.frame = f;
        }
        for (UIView *v in self.selectionIndicatorViews) {
            CGRect f = v.frame;
            f.origin.x += offsetX;
            v.frame = f;
        }
    }
    
    // Set customized scale
    for (NSInteger idx = 0; idx < self.selectionIndicatorViews.count; idx ++) {
        DLPickerViewInternalMagnifyingView *indicatorView = self.selectionIndicatorViews[idx];
        if ([self.delegate respondsToSelector:@selector(pickerView:scaleValueForCenterIndicatorInComponent:)]) {
            indicatorView.scale = [self.delegate pickerView:self scaleValueForCenterIndicatorInComponent:idx];
        } else {
            indicatorView.scale = self.magnifyingViewScale;
        }
    }
    for (DLTableView *tableView in self.tableViews) {
        [self initAppearanceForComponent:tableView.tag delay:0.05];
    }
    
    [self makeSureIndicatorViewsShowRightWithDelay:0.15];
    [self nowWeCanPlaySound:0.5];
}

- (void)initAppearanceForComponent:(NSInteger)component delay:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = 0;
        if ([self.delegate respondsToSelector:@selector(pickerView:initiallySelectedRowForComponent:)]) {
            row = [self.delegate pickerView:self initiallySelectedRowForComponent:component];
            if ([self.delegate respondsToSelector:@selector(pickerView:enableScrollWithinRangeForComponent:)]) {
                if ([self.delegate pickerView:self enableScrollWithinRangeForComponent:component]) {
                    if ([self.delegate respondsToSelector:@selector(pickerView:getRangeForScrollInComponent:)]) {
                        NSRange range = [self.delegate pickerView:self getRangeForScrollInComponent:component];
                        if (row < (NSInteger)range.location) {
                            row = (NSInteger)range.location;
                        } else if (row > (NSInteger)range.location + (NSInteger)range.length - 1) {
                            row = (NSInteger)range.location + (NSInteger)range.length - 1;
                        }
                    }
                }
            }
            [self selectRow:row inComponent:component animated:NO];
        } else {
            if ([self.delegate pickerView:self enableScrollWithinRangeForComponent:component]) {
                if ([self.delegate respondsToSelector:@selector(pickerView:getRangeForScrollInComponent:)]) {
                    if ([self.delegate respondsToSelector:@selector(pickerView:getRangeForScrollInComponent:)]) {
                        NSRange range = [self.delegate pickerView:self getRangeForScrollInComponent:component];
                        row = (NSInteger)range.location;
                    }
                }
            }
            [self selectRow:row inComponent:component animated:NO];
        }
    });
}

- (void)nowWeCanPlaySound:(CGFloat)delay {
    self.canPlaySound = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.canPlaySound = YES;
    });
}

- (void)makeSureIndicatorViewsShowRightWithDelay:(CGFloat)delay {
    if (!self.showMaskViewsForSystemEffect) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger idx = 0; idx < self.tableViews.count; idx ++) {
            [self.selectionIndicatorViews[idx] setNeedsDisplay];
        }
    });
}

- (BOOL)makeSureNotScrollOutOfRangeWithScrollView:(UIScrollView *)scrollView needScrollWhenOut:(BOOL)needScrollWhenOut {
    DLTableView *tableView = (DLTableView *)scrollView;
    if ([self.delegate respondsToSelector:@selector(pickerView:enableScrollWithinRangeForComponent:)]) {
        if ([self.delegate pickerView:self enableScrollWithinRangeForComponent:tableView.tag]) {
            if ([self.delegate respondsToSelector:@selector(pickerView:getRangeForScrollInComponent:)]) {
                NSRange range = [self.delegate pickerView:self getRangeForScrollInComponent:tableView.tag];
                NSInteger minIndex = [self getIndexWhichIsTheClosestToCenterWithScrollView:scrollView];
                if (minIndex == -1) {
                    return NO;
                }
                NSIndexPath *centerIndexPath = tableView.visibileCellsIndexPath[minIndex];
                if (centerIndexPath.row < (NSInteger)range.location && needScrollWhenOut) {
                    if ((NSInteger)range.location - centerIndexPath.row < [self numberOfRowsInComponent:scrollView.tag] - ((NSInteger)range.location + (NSInteger)range.length) + centerIndexPath.row) {
                        [tableView scrollToRowAt:[NSIndexPath indexPathForRow:(NSInteger)range.location inSection:0] at:DLTableViewScrollPositionMiddle animated:YES];
                    } else {
                        [tableView scrollToRowAt:[NSIndexPath indexPathForRow:(NSInteger)range.location + (NSInteger)range.length - 1 inSection:0] at:DLTableViewScrollPositionMiddle animated:YES];
                    }
                    return YES;
                } else if (centerIndexPath.row > (NSInteger)range.location + (NSInteger)range.length - 1 && needScrollWhenOut) {
                    if (centerIndexPath.row - (NSInteger)range.location - (NSInteger)range.length - 1 <  [self numberOfRowsInComponent:scrollView.tag] - 1 - centerIndexPath.row + (NSInteger)range.location) {
                        [tableView scrollToRowAt:[NSIndexPath indexPathForRow:(NSInteger)range.location + (NSInteger)range.length - 1 inSection:0] at:DLTableViewScrollPositionMiddle animated:YES];
                    } else {
                        [tableView scrollToRowAt:[NSIndexPath indexPathForRow:(NSInteger)range.location inSection:0] at:DLTableViewScrollPositionMiddle animated:YES];
                    }
                    return YES;
                }
                
                if (centerIndexPath.row < (NSInteger)range.location || centerIndexPath.row > (NSInteger)range.location + (NSInteger)range.length - 1)  {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isSelectedOutOfRangeOfIndexPath:(DLTableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pickerView:enableScrollWithinRangeForComponent:)]) {
        if ([self.delegate pickerView:self enableScrollWithinRangeForComponent:tableView.tag]) {
            if ([self.delegate respondsToSelector:@selector(pickerView:getRangeForScrollInComponent:)]) {
                NSRange range = [self.delegate pickerView:self getRangeForScrollInComponent:tableView.tag];
                if (indexPath.row <  (NSInteger)range.location || indexPath.row > (NSInteger)range.location + (NSInteger)range.length - 1) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)scrollToCenterWithScrollView:(UIScrollView *)scrollView animated:(BOOL)animated {
    if ([self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:NO]) {
        return;
    }
    NSInteger minIndex = [self getIndexWhichIsTheClosestToCenterWithScrollView:scrollView];
    if (minIndex == -1) {
        return;
    }
    DLTableView *tableView = (DLTableView *)scrollView;
    [tableView scrollToRowAtIndexPath:tableView.visibileCellsIndexPath[minIndex] withInternalIndex:minIndex atScrollPosition:DLTableViewScrollPositionMiddle animated:animated complete:nil];
}

- (NSInteger)getIndexWhichIsTheClosestToCenterWithScrollView:(UIScrollView *)scrollView {
    DLTableView *tableView = (DLTableView *)scrollView;
    CGFloat centerY = tableView.contentOffset.y + tableView.frame.size.height/2;
    NSInteger minIndex = -1;
    if (tableView.visibileCells.firstObject) {
        minIndex = 0;
        CGFloat minValue = fabs(tableView.visibileCells.firstObject.frame.origin.y + tableView.visibileCells.firstObject.frame.size.height/2 - centerY);
        for (NSInteger index = 0; index < tableView.visibileCells.count; index ++) {
            DLTableViewCell *cell = tableView.visibileCells[index];
            if (fabs(cell.frame.origin.y + cell.frame.size.height/2 - centerY) < minValue) {
                minValue = fabs(cell.frame.origin.y - centerY);
                minIndex = index;
            }
        }
    }
    return minIndex;
}

- (void)layout:(DLTableView *)tableView {
    [self transformCellLayerWithScrollView:tableView];
    if (!self.isUserDraggingComponents[tableView.tag]) {
        [self triggerSelectedActionIfNeededWithTableView:tableView];
    }
}

- (void)transformCellLayerWithScrollView:(UIScrollView *)scrollView {
    CGFloat currCenterOffset = scrollView.contentOffset.y + scrollView.frame.size.height/2;
    DLTableView *tableView = (DLTableView *)scrollView;
    for (DLTableViewCell *cell in tableView.visibileCells) {
        CGFloat distanceFromCenter = currCenterOffset - cell.frame.origin.y - cell.frame.size.height/2;
        CGFloat disPercent = distanceFromCenter / (scrollView.frame.size.height / 2);
        disPercent = MAX(disPercent, -1);
        disPercent = MIN(disPercent, 1);
        if ([self.delegate respondsToSelector:@selector(pickerView:customScrollEffectForComponent:withPosition:)]) {
            CATransform3D transform = [self.delegate pickerView:self customScrollEffectForComponent:scrollView.tag withPosition:disPercent];
            cell.containerView.layer.transform = transform;
        } else if ([self.delegate respondsToSelector:@selector(pickerView:customCellForComponent:withPosition:andTheCell:)]) {
            [self.delegate pickerView:self customCellForComponent:scrollView.tag withPosition:disPercent andTheCell:(DLPickerViewCell *)cell];
            continue;
        } else {
            CATransform3D rotationPerspectiveTrans = CATransform3DIdentity;
            rotationPerspectiveTrans.m34 = -1 / 500;
            rotationPerspectiveTrans = CATransform3DRotate(rotationPerspectiveTrans, disPercent * 3.14159/180.0 * 65.0, 1, 0, 0);
            cell.containerView.layer.transform = rotationPerspectiveTrans;
        }
    }
}

- (void)triggerSelectedActionIfNeededWithTableView:(DLTableView *)tableView {
    [DLPickerView cancelPreviousPerformRequestsWithTarget:self selector:@selector(triggerSelectedAcionRightAwayWithTableView:) object:tableView];
    [self performSelector:@selector(triggerSelectedAcionRightAwayWithTableView:) withObject:tableView afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
}

- (void)triggerSelectedAcionRightAwayWithTableView:(DLTableView *)tableView {
    NSInteger minIndex = [self getIndexWhichIsTheClosestToCenterWithScrollView:tableView];
    if (minIndex == -1) {
        return;
    }
    NSIndexPath *indexPath = tableView.visibileCellsIndexPath[minIndex];
    if (indexPath.row != self.lastSelectedRow[tableView.tag].integerValue
        && ![self isSelectedOutOfRangeOfIndexPath:tableView indexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
            [self.delegate pickerView:self didSelectRow:indexPath.row inComponent:tableView.tag];
        }
        self.lastSelectedRow[tableView.tag] = @(indexPath.row);
        self.lastCenterRows[tableView.tag] = @(indexPath.row);
    }
}

- (CGFloat)heightForComponent:(NSInteger)component inRow:(NSInteger)row {
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
        return [self.delegate pickerView:self rowHeightForComponent:component];
    }
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForRow:inComponent:)]) {
        return [self.delegate pickerView:self rowHeightForRow:row inComponent:component];
    }
    return DefaultRowHeight;
}

- (void)setSelectionStyle:(DLPickerViewSelectionStyle)selectionStyle {
    _selectionStyle = selectionStyle;
    if (selectionStyle != DLPickerViewSelectionStyleCustom) {
        self.showsSelectionIndicator = YES;
    }
}

- (NSInteger)tableView:(DLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInComponent:tableView.tag];
}

- (DLTableViewCell *)tableView:(DLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.usingPickerViewLikeTabelView) {
        DLPickerViewCell *cell = [self.delegate pickerView:self cellForRow:indexPath.row forComponent:tableView.tag];
        if (cell == nil) {
            NSAssert(NO, @"You should implement at least one method to return title, attributedTitle, view, or cell for row");
        }
        self.usingPickerViewLikeTabelView = YES;
        [self rotateCellContentIfNeedWithCell:cell];
        return cell;
    }
    DLPickerViewCell *temp = (DLPickerViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DLPickViewInternalCell"];
    if (temp == nil) {
        temp = [[DLPickerViewCell alloc] initWithStyle:DLTableViewCellStyleDefault reuseIdentifier:@"DLPickViewInternalCell"];
        [self rotateCellContentIfNeedWithCell:temp];
        if (self.enableNightMode) {
            temp.titleLabel.textColor = [UIColor whiteColor];
        } else {
            temp.titleLabel.textColor = [UIColor blackColor];
        }
    }
    DLPickerViewCell *cell = temp;
    cell.containerView.layer.drawsAsynchronously = YES;
    UIView *cachedCustomView = self.cachedCustomViews[[NSString stringWithFormat:@"%ld=%ld", (long)tableView.tag, (long)indexPath.row]];
    if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
        NSAttributedString *attrTitle = [self.delegate pickerView:self attributedTitleForRow:indexPath.row forComponent:tableView.tag];
        cell.titleLabel.hidden = NO;
        cell.customView.hidden = YES;
        cell.titleLabel.text = nil;
        cell.titleLabel.attributedText = attrTitle;
    } else if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        NSString *title = [self.delegate pickerView:self titleForRow:indexPath.row forComponent:tableView.tag];
        cell.titleLabel.hidden = NO;
        cell.customView.hidden = YES;
        cell.titleLabel.attributedText = nil;
        cell.titleLabel.text = title;
    } else if ([self.delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]) {
        UIView *view = [self.delegate pickerView:self viewForRow:indexPath.row forComponent:tableView.tag reusing:cachedCustomView];
        if (cachedCustomView != view) {
            // FIXME: if there are too many rows in the component, memory usage will be high.
            self.cachedCustomViews[[NSString stringWithFormat:@"%ld=%ld", (long)tableView.tag, (long)indexPath.row]] = view;
        }
        cell.titleLabel.hidden = YES;
        cell.customView.hidden = NO;
        [cell.customView removeAllSubviews];
        [cell.customView addSubview:view];
    } else if ([self.delegate respondsToSelector:@selector(pickerView:cellForRow:forComponent:)]) {
        DLPickerViewCell *icell = [self.delegate pickerView:self cellForRow:indexPath.row forComponent:tableView.tag];
        self.usingPickerViewLikeTabelView = YES;
        return icell;
    } else {
        NSAssert(NO, @"You should implement at least one method to return title, attributedTitle, view, or cell for row");
    }
    return cell;
}

- (void)rotateCellContentIfNeedWithCell:(DLPickerViewCell *)cell {
    if (self.layoutStyle == DLPickerViewLayoutStyleHorizontal) {
        for (UIView *v in cell.containerView.subviews) {
            v.transform = CGAffineTransformMakeRotation(0);
        }
    } else {
        for (UIView *v in cell.containerView.subviews) {
            v.transform = CGAffineTransformMakeRotation(3.14159/2);
        }
    }
}

- (CGFloat)tableView:(DLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForComponent:tableView.tag inRow:indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.hasMakeSureNotOutOfRange[scrollView.tag].boolValue
        && !self.isUserDraggingComponents[scrollView.tag].boolValue
        && [self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:YES]) {
        self.hasMakeSureNotOutOfRange[scrollView.tag] = @YES;
    }
    
    if ([self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:NO] && self.isUserDraggingComponents[scrollView.tag].boolValue) {
        id<UIScrollViewDelegate> delegate = scrollView.delegate;
        scrollView.delegate = nil;
        CGPoint offset = scrollView.contentOffset;
        offset.y += 1/60.0 * [scrollView.panGestureRecognizer velocityInView:scrollView.superview].y * 0.9;
        scrollView.contentOffset = offset;
        scrollView.delegate = delegate;
    }
    
    DLTableView *tableView = (DLTableView *)scrollView;
    [self.selectionIndicatorViews[tableView.tag] setNeedsDisplay];
    NSInteger minIndex = [self getIndexWhichIsTheClosestToCenterWithScrollView:scrollView];
    if (minIndex == -1) {
        return;
    }
    NSIndexPath *centerIndexPath = tableView.visibileCellsIndexPath[minIndex];
    if (self.lastCenterRows[tableView.tag].integerValue != centerIndexPath.row) {
        [self playSoundEffect];
        self.lastCenterRows[tableView.tag] = @(centerIndexPath.row);
    }
    // scrollview will stop scrolling right away when scrollview disappeared from screen.
    [self doSomeEndWorkWithScrollView:scrollView];
    if ([self.delegate respondsToSelector:@selector(pickerView:componentDidScroll:)]) {
        [self.delegate pickerView:self componentDidScroll:scrollView.tag];
    }
    if ([self.delegate respondsToSelector:@selector(pickerView:centerRowDidChangedForComponent:toRowNumber:)]) {
        [self.delegate pickerView:self centerRowDidChangedForComponent:scrollView.tag toRowNumber:centerIndexPath.row];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isUserDraggingComponents[scrollView.tag] = @YES;
    if (self.scrollStartOrEndAction) {
        self.scrollStartOrEndAction(scrollView.tag, YES);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:YES]) {
        (*targetContentOffset) = scrollView.contentOffset;
    } else {
        DLTableView *tableView = (DLTableView *)scrollView;
        NSInteger minIndex = [self getIndexWhichIsTheClosestToCenterWithScrollView:scrollView];
        if (minIndex == -1) {
            return;
        }
        // the row is 0, so the height for rows should be equal
        CGFloat height = [self heightForComponent:tableView.tag inRow:0];
        CGRect cellFrame = tableView.visibileCells[minIndex].frame;
        CGFloat offsetToCenter = scrollView.bounds.size.height/2 - ((cellFrame.origin.y + cellFrame.size.height/2) - scrollView.contentOffset.y);
        CGFloat distance = (*targetContentOffset).y - scrollView.contentOffset.y;
        distance = (NSInteger)(distance/height) * height - offsetToCenter;
        (*targetContentOffset).y = distance + scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserDraggingComponents[scrollView.tag] = @NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.hasMakeSureNotOutOfRange[scrollView.tag].boolValue
        && [self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:YES]) {
        self.hasMakeSureNotOutOfRange[scrollView.tag] = @YES;
        return;
    }
    
    self.hasMakeSureNotOutOfRange[scrollView.tag] = @NO;
    [self makeSureIndicatorViewsShowRightWithDelay:0.05];
}

- (void)doSomeEndWorkWithScrollView:(UIScrollView *)scrollView {
    [DLPickerView cancelPreviousPerformRequestsWithTarget:self selector:@selector(triggerDoSomeEndWorkWithScrollView:) object:scrollView];
    [self performSelector:@selector(triggerDoSomeEndWorkWithScrollView:) withObject:scrollView afterDelay:0.25 inModes:@[NSRunLoopCommonModes]];
}

- (void)triggerDoSomeEndWorkWithScrollView:(UIScrollView *)scrollView {
    if (self.isUserDraggingComponents[scrollView.tag].boolValue) {
        [self doSomeEndWorkWithScrollView:scrollView];
        return;
    }
    if ((!self.hasMakeSureNotOutOfRange[scrollView.tag].boolValue)
        && [self makeSureNotScrollOutOfRangeWithScrollView:scrollView needScrollWhenOut:YES]) {
        self.hasMakeSureNotOutOfRange[scrollView.tag] = @YES;
        return;
    }
    
    [self scrollToCenterWithScrollView:scrollView animated:YES];
    [self makeSureIndicatorViewsShowRightWithDelay:0.05];
    if (self.scrollStartOrEndAction) {
        self.scrollStartOrEndAction(scrollView.tag, NO);
    }
}

@end
