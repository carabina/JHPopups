//
//  JHPopups.m
//  RemindTeacher_iOS
//
//  Created by zhangHao on 16/6/29.
//  Copyright © 2016年 zhanghao. All rights reserved.
//

#import "JHPopups.h"

#define MaskAlpha 0.5
#define AnimateDuration 0.25

@interface JHPopups ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *appWindow;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, assign) CGSize popupSize;
@property (nonatomic, assign) BOOL dismissAnimated;
@property (nonatomic, assign) BOOL bufferEffect;//TODO:
@end

@implementation JHPopups

- (instancetype)initWithWillPopups:(UIView *)pView {
    return [self initWithWillPopups:pView
                         popupStyle:[JHPopupsMotif defaultMotif].popupStyle
                  presentationStyle:[JHPopupsMotif defaultMotif].presentationStyle];
}

- (instancetype)initWithWillPopups:(UIView *)pView
                        popupStyle:(JHPopupsStyle)popupStyle
                 presentationStyle:(JHPopupsPresentationStyle)presentationStyle {
    if (self = [super init]) {
        _popupSize = pView.frame.size;
        _popupView = [UIView new];
        _popupView.frame = CGRectZero;
        _popupView.backgroundColor = [UIColor whiteColor];
        _popupView.clipsToBounds = YES;
        
        _maskView = [[UIView alloc] initWithFrame:self.appWindow.bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:MaskAlpha];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundWhenTapped:)];
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];
        [_maskView addSubview:_popupView];
        
        _motif = [JHPopupsMotif defaultMotif];
        _motif.popupStyle = popupStyle;
        _motif.presentationStyle = presentationStyle;
        [_popupView addSubview:pView];
    }
    return self;
}

- (void)backgroundWhenTapped:(id)sender {
    if (_motif.shouldDismissOnBackgroundTouch) [self dismissPopupsAnimated:_dismissAnimated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_popupView]) return NO;
    return YES;
}

- (UIWindow *)appWindow {
    if (!_appWindow) {
        _appWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _appWindow;
}

- (void)initialMotif {
    if (_motif.popupStyle == JHPopupsStyleFullscreen) {
        _motif.presentationStyle = JHPopupsPresentationStyleFadeIn;
    }
    if (_motif.popupStyle == JHPopupsStyleActionSheet) {
        _motif.presentationStyle = JHPopupsPresentationStyleSlideInFromBottom;
    }
    _popupView.layer.cornerRadius = _motif.popupStyle == JHPopupsStyleCentered ? _motif.cornerRadius : 0;
    _popupView.backgroundColor = [UIColor whiteColor];
    UIColor *maskBackgroundColor;
    if (_motif.popupStyle == JHPopupsStyleFullscreen) {
        maskBackgroundColor = _popupView.backgroundColor;
    } else {
        maskBackgroundColor = _motif.maskType == JHPopupsMaskTypeClear? \
        [UIColor clearColor] : [UIColor colorWithWhite:0.0 alpha:MaskAlpha];
    }
    _maskView.backgroundColor = maskBackgroundColor;
}

- (void)sharingPresent {
    if ([_delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
        [_delegate popupControllerWillPresent:self];
    }
}

- (void)sharingDismiss {
    if ([_delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
        [_delegate popupControllerWillDismiss:self];
    }
}

- (CGPoint)startingPoint {
    CGPoint origin;
    switch (_motif.presentationStyle) {
        case JHPopupsPresentationStyleFadeIn:
            origin = _maskView.center;
            break;
        case JHPopupsPresentationStyleSlideInFromBottom:
            origin = CGPointMake(_maskView.center.x, _maskView.bounds.size.height + _popupView.bounds.size.height);
            break;
        case JHPopupsPresentationStyleSlideInFromLeft:
            origin = CGPointMake(-_popupView.bounds.size.width, _maskView.center.y);
            break;
        case JHPopupsPresentationStyleSlideInFromRight:
            origin = CGPointMake(_maskView.bounds.size.width+_popupView.bounds.size.width, _maskView.center.y);
            break;
        case JHPopupsPresentationStyleSlideInFromTop:
            origin = CGPointMake(_maskView.center.x, -_popupView.bounds.size.height);
            break;
        default:
            origin = _maskView.center;
            break;
    }
    return origin;
}

- (CGPoint)endingPoint {
    CGPoint center;
    if (_motif.popupStyle == JHPopupsStyleActionSheet) {
        center = CGPointMake(_maskView.center.x, _maskView.bounds.size.height - _popupView.bounds.size.height / 2);
    } else {
        center = _maskView.center;
    }
    return center;
}

- (CGPoint)dismissedPoint {
    CGPoint dismissed;
    switch (self.motif.presentationStyle) {
        case JHPopupsPresentationStyleFadeIn:
            dismissed = self.maskView.center;
            break;
        case JHPopupsPresentationStyleSlideInFromBottom:
            dismissed = self.motif.dismissesOppositeDirection?CGPointMake(self.maskView.center.x, -self.popupView.bounds.size.height):CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
            if (self.motif.popupStyle == JHPopupsStyleActionSheet) {
                dismissed = CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height);
            }
            break;
        case JHPopupsPresentationStyleSlideInFromLeft:
            dismissed = self.motif.dismissesOppositeDirection?CGPointMake(self.maskView.bounds.size.width+self.popupView.bounds.size.width, self.maskView.center.y):CGPointMake(-self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case JHPopupsPresentationStyleSlideInFromRight:
            dismissed = self.motif.dismissesOppositeDirection?CGPointMake(-self.popupView.bounds.size.width, self.maskView.center.y):CGPointMake(self.maskView.bounds.size.width+self.popupView.bounds.size.width, self.maskView.center.y);
            break;
        case JHPopupsPresentationStyleSlideInFromTop:
            dismissed = self.motif.dismissesOppositeDirection?CGPointMake(self.maskView.center.x, self.maskView.bounds.size.height + self.popupView.bounds.size.height):CGPointMake(self.maskView.center.x, -self.popupView.bounds.size.height);
            break;
        default:
            dismissed = self.maskView.center;
            break;
    }
    return dismissed;
}

- (void)show {
    [self showPopupsWithAnimated:YES];
}

- (void)showPopupsWithAnimated:(BOOL)animated {
    _dismissAnimated = animated;
    [self sharingPresent];
    [self initialMotif];
    
    _popupView.frame = CGRectMake(0, 0, _popupSize.width, _popupSize.height);
    _popupView.center = [self startingPoint];
    _maskView.alpha = 0;
    if (_motif.popupStyle != JHPopupsStyleActionSheet) {
        _maskView.transform = CGAffineTransformMakeScale(1.10, 1.10); // 缩放
    }
    [self.appWindow addSubview:_maskView];
    [UIView animateWithDuration:animated ? AnimateDuration : 0 animations:^{
        _maskView.transform = CGAffineTransformIdentity;
        _maskView.alpha = 1.F;
        _popupView.center = [self endingPoint];;
    } completion:^(BOOL finished) {
        _popupView.userInteractionEnabled = YES;
        if ([_delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
            [_delegate popupControllerDidPresent:self];
        }
    }];
}

- (void)dismissPopupsAnimated:(BOOL)animated {
    [self sharingDismiss];
    if (_motif.presentationStyle == JHPopupsPresentationStyleFadeIn) {
        _popupView.hidden = YES;
    }
    [UIView animateWithDuration:animated ? AnimateDuration : 0 animations:^{
        _maskView.alpha = 0.F;
        _popupView.center = [self dismissedPoint];
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        if ([_delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
            [_delegate popupControllerDidDismiss:self];
        }
        self.appWindow = nil;
    }];
}

@end

@implementation JHPopupsMotif

+ (JHPopupsMotif *)defaultMotif {
    JHPopupsMotif *motif = [JHPopupsMotif new];
    motif.cornerRadius = 0.F;
    motif.popupStyle = JHPopupsStyleCentered;
    motif.presentationStyle = JHPopupsPresentationStyleFadeIn;
    motif.dismissesOppositeDirection = NO;
    motif.maskType = JHPopupsMaskTypeDark;
    motif.shouldDismissOnBackgroundTouch = YES;
    return motif;
}

@end
