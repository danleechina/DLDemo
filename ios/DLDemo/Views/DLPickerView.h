//
//  DLPickerView.h
//  WMPayDayLoan
//
//  Created by LiZhengDa on 2017/10/19.
//  Copyright © 2017年 WUMII. All rights reserved.
//

#import "DLTableView.h"

@class DLPickerView;
@class DLPickerViewCell;

@protocol DLPickerViewDataSource<NSObject>

- (NSInteger)numberOfComponentsIn:(DLPickerView *)pickerView;
- (NSInteger)pickerView:(DLPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol DLPickerViewDelegate <NSObject>
@optional
- (CGFloat)pickerView:(DLPickerView *)pickerView widthForComponent:(NSInteger)component ;
- (CGFloat)pickerView:(DLPickerView *)pickerView rowHeightForComponent:(NSInteger)component ;
- (NSString *)pickerView:(DLPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component ;
- (NSAttributedString *)pickerView:(DLPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component ;
- (UIView *)pickerView:(DLPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusing:(UIView *)view ;
- (void)pickerView:(DLPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (DLPickerViewCell *)pickerView:(DLPickerView *)pickerView cellForRow:(NSInteger)row forComponent:(NSInteger)component ;
- (BOOL)enableCycleScrollIn:(DLPickerView *)pickerView forComponent:(NSInteger)component ;
- (CGFloat)pickerView:(DLPickerView *)pickerView rowHeightForRow:(NSInteger)row inComponent:(NSInteger)component ;
- (BOOL)pickerView:(DLPickerView *)pickerView enableScrollWithinRangeForComponent:(NSInteger)component ;
- (NSRange)pickerView:(DLPickerView *)pickerView getRangeForScrollInComponent:(NSInteger)component ;
- (CATransform3D)pickerView:(DLPickerView *)pickerView customScrollEffectForComponent:(NSInteger)component withPosition:(CGFloat)position ;
- (void)pickerView:(DLPickerView *)pickerView customCellForComponent:(NSInteger)component withPosition:(CGFloat)position andTheCell:(DLPickerViewCell *)andTheCell;
- (NSInteger)pickerView:(DLPickerView *)pickerView initiallySelectedRowForComponent:(NSInteger)component ;
- (double)pickerView:(DLPickerView *)pickerView scaleValueForCenterIndicatorInComponent:(NSInteger)component ;
- (void)pickerView:(DLPickerView *)pickerView componentDidScroll:(NSInteger)component;
- (void)pickerView:(DLPickerView *)pickerView centerRowDidChangedForComponent:(NSInteger)component toRowNumber:(NSInteger)row;
@end

typedef enum : NSUInteger {
    DLPickerViewLayoutStyleVertical,
    DLPickerViewLayoutStyleHorizontal,
} DLPickerViewLayoutStyle;

typedef enum : NSUInteger {
    DLPickerViewSelectionStyleSystem,
    DLPickerViewSelectionStyleCustom,
} DLPickerViewSelectionStyle;

@interface DLPickerViewCell: DLTableViewCell
@end

@interface DLPickerView : UIView
@property (nonatomic, weak) id <DLPickerViewDataSource> dataSource;
@property (nonatomic, weak) id <DLPickerViewDelegate> delegate;
@property (nonatomic, copy) void (^scrollStartOrEndAction)(NSInteger, BOOL);
@property (nonatomic) BOOL showsSelectionIndicator;
@property (nonatomic) BOOL showMaskViewsForSystemEffect;
@property (nonatomic, readonly) NSInteger numberOfComponents;
@property (nonatomic, assign) DLPickerViewLayoutStyle layoutStyle;
@property (nonatomic) BOOL enableScrollSound;
@property (nonatomic) double magnifyingViewScale;
@property (nonatomic) BOOL enableNightMode;
@property (nonatomic, copy) NSURL * soundURL;
@property (nonatomic, strong) UIColor * backgroundColor;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;
- (CGSize)rowSizeAt:(NSInteger)row forComponent:(NSInteger)component;
- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;
- (DLPickerViewCell *)cellForRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (NSInteger)lastCenterRowInComponent:(NSInteger)component;
- (DLPickerViewCell *)dequeueReusableCellForComponent:(NSInteger)component withIdentifier:(NSString *)identifier;
- (void)enableUserInteractionRightAwayWithTableView:(DLTableView *)tableView;
- (CGFloat)heightForComponent:(NSInteger)component inRow:(NSInteger)row;
@end
