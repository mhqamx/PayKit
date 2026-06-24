#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Centralized visual language for the demo. The demo locks to a custom dark
/// "premium fintech" palette so the look is intentional rather than inheriting
/// system grouped-table chrome.
@interface DemoTheme : NSObject

// Palette
@property (class, nonatomic, readonly) UIColor *canvas;
@property (class, nonatomic, readonly) UIColor *card;
@property (class, nonatomic, readonly) UIColor *cardElevated;
@property (class, nonatomic, readonly) UIColor *cardBorder;
@property (class, nonatomic, readonly) UIColor *field;
@property (class, nonatomic, readonly) UIColor *textPrimary;
@property (class, nonatomic, readonly) UIColor *textSecondary;
@property (class, nonatomic, readonly) UIColor *textTertiary;
@property (class, nonatomic, readonly) UIColor *accent;
@property (class, nonatomic, readonly) UIColor *wechat;
@property (class, nonatomic, readonly) UIColor *alipay;
@property (class, nonatomic, readonly) UIColor *success;
@property (class, nonatomic, readonly) UIColor *failure;
@property (class, nonatomic, readonly) UIColor *cancelled;

// Metrics
@property (class, nonatomic, readonly) CGFloat cardRadius;
@property (class, nonatomic, readonly) CGFloat controlRadius;
@property (class, nonatomic, readonly) CGFloat pagePadding;

// Fonts
+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;
+ (UIFont *)textFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;

// Builders
+ (UIView *)cardView;
+ (UIButton *)primaryButtonWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
