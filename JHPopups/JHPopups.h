//
//  JHPopups.h
//  RemindTeacher_iOS
//
//  Created by zhangHao on 16/6/29.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHPopupsStyle) {
    JHPopupsStyleActionSheet = 0,
    JHPopupsStyleCentered,
    JHPopupsStyleFullscreen
};

typedef NS_ENUM(NSInteger, JHPopupsPresentationStyle) {
    JHPopupsPresentationStyleFadeIn = 0,
    JHPopupsPresentationStyleSlideInFromTop,
    JHPopupsPresentationStyleSlideInFromBottom,
    JHPopupsPresentationStyleSlideInFromLeft,
    JHPopupsPresentationStyleSlideInFromRight
};

typedef NS_ENUM(NSInteger, JHPopupsMaskType) {
    JHPopupsMaskTypeClear,
    JHPopupsMaskTypeDark
};

@class JHPopupsMotif;
@protocol JHPopupControllerDelegate;
@interface JHPopups : NSObject

@property (nonatomic, strong) JHPopupsMotif *motif;
@property (nonatomic, weak) id <JHPopupControllerDelegate> delegate;

- (instancetype)initWithWillPopups:(UIView *)pView
                        popupStyle:(JHPopupsStyle)popupStyle
                 presentationStyle:(JHPopupsPresentationStyle)presentationStyle;
- (instancetype)initWithWillPopups:(UIView *)pView;

- (void)show;
- (void)showPopupsWithAnimated:(BOOL)animated;
- (void)dismissPopupsAnimated:(BOOL)animated;

@end

@protocol JHPopupControllerDelegate <NSObject>
@optional
- (void)popupControllerWillPresent:(JHPopups *)controller;
- (void)popupControllerDidPresent:(JHPopups *)controller;
- (void)popupControllerWillDismiss:(JHPopups *)controller;
- (void)popupControllerDidDismiss:(JHPopups *)controller;

@end

@interface JHPopupsMotif : NSObject

@property (nonatomic, assign) CGFloat cornerRadius;                         // 弹出视图的圆弧半径
@property (nonatomic, assign) JHPopupsStyle popupStyle;                     // 视图弹出后的位置
@property (nonatomic, assign) JHPopupsPresentationStyle presentationStyle;  // 视图弹出方向
@property (nonatomic, assign) JHPopupsMaskType maskType;                    // 遮罩是否透明
@property (nonatomic, assign) BOOL dismissesOppositeDirection;              // 视图反方向消失
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;          // 遮罩是否可以响应
+ (JHPopupsMotif *)defaultMotif;

@end
