#import "DemoTheme.h"

static UIColor *PYKHexColor(uint32_t hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@implementation DemoTheme

+ (UIColor *)canvas { return PYKHexColor(0x0A0C10); }
+ (UIColor *)card { return PYKHexColor(0x14171F); }
+ (UIColor *)cardElevated { return PYKHexColor(0x1B1F29); }
+ (UIColor *)cardBorder { return PYKHexColor(0x252A36); }
+ (UIColor *)field { return PYKHexColor(0x0E1117); }
+ (UIColor *)textPrimary { return PYKHexColor(0xF3F5FA); }
+ (UIColor *)textSecondary { return PYKHexColor(0x8B93A7); }
+ (UIColor *)textTertiary { return PYKHexColor(0x5C6378); }
+ (UIColor *)accent { return PYKHexColor(0xFF5C39); }
+ (UIColor *)wechat { return PYKHexColor(0x07C160); }
+ (UIColor *)alipay { return PYKHexColor(0x1677FF); }
+ (UIColor *)success { return PYKHexColor(0x2BD576); }
+ (UIColor *)failure { return PYKHexColor(0xFF5C5C); }
+ (UIColor *)cancelled { return PYKHexColor(0xFFB23E); }

+ (CGFloat)cardRadius { return 18.0; }
+ (CGFloat)controlRadius { return 14.0; }
+ (CGFloat)pagePadding { return 18.0; }

+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *base = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [base.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    if (descriptor == nil) {
        return base;
    }
    return [UIFont fontWithDescriptor:descriptor size:size];
}

+ (UIFont *)textFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    return [UIFont systemFontOfSize:size weight:weight];
}

+ (UIView *)cardView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = DemoTheme.card;
    view.layer.cornerRadius = DemoTheme.cardRadius;
    view.layer.cornerCurve = kCACornerCurveContinuous;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = DemoTheme.cardBorder.CGColor;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

+ (UIButton *)primaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.baseBackgroundColor = DemoTheme.accent;
    configuration.baseForegroundColor = UIColor.whiteColor;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(17.0, 16.0, 17.0, 16.0);
    NSAttributedString *attributed = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{ NSFontAttributeName: [DemoTheme roundedFontOfSize:17.0 weight:UIFontWeightSemibold] }];
    configuration.attributedTitle = attributed;
    button.configuration = configuration;
    button.layer.cornerCurve = kCACornerCurveContinuous;
    button.configurationUpdateHandler = ^(UIButton *updateButton) {
        updateButton.alpha = updateButton.highlighted ? 0.85 : 1.0;
        updateButton.transform = updateButton.highlighted
            ? CGAffineTransformMakeScale(0.98, 0.98)
            : CGAffineTransformIdentity;
    };
    return button;
}

@end
