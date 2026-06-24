#import "PaymentViewController.h"
#import "DemoConfig.h"
#import "DemoTheme.h"
@import PayKit;

#pragma mark - PaddedLabel

/// Label with internal padding, used for the inline "DEMO" chip.
@interface PaddedLabel : UILabel
@end

@implementation PaddedLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(3.0, 8.0, 3.0, 8.0);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + 16.0, size.height + 6.0);
}

@end

#pragma mark - PaymentViewController

@interface PaymentViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *amountField;
@property (nonatomic, strong) UIView *resultIndicator;
@property (nonatomic, strong) UILabel *resultTitle;
@property (nonatomic, strong) UILabel *resultBody;
@property (nonatomic, strong) UIView *resultCard;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayKit";
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    self.view.backgroundColor = DemoTheme.canvas;
    [self configureNavigationBar];
    [self buildInterface];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)configureNavigationBar {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = DemoTheme.canvas;
    appearance.shadowColor = UIColor.clearColor;
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: DemoTheme.textPrimary,
        NSFontAttributeName: [DemoTheme roundedFontOfSize:17.0 weight:UIFontWeightBold]
    };
    self.navigationItem.standardAppearance = appearance;
    self.navigationItem.scrollEdgeAppearance = appearance;
}

#pragma mark Layout

- (void)buildInterface {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.alwaysBounceVertical = YES;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 16.0;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:content];

    CGFloat pad = DemoTheme.pagePadding;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.leadingAnchor constant:pad],
        [content.trailingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.trailingAnchor constant:-pad],
        [content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:8.0],
        [content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-32.0]
    ]];

    [content addArrangedSubview:[self heroCard]];
    [content addArrangedSubview:[self orderCard]];
    [content addArrangedSubview:[self buildResultCard]];

    UIButton *payButton = [DemoTheme primaryButtonWithTitle:@"去支付"];
    payButton.translatesAutoresizingMaskIntoConstraints = NO;
    [payButton addTarget:self action:@selector(presentPaymentSheet) forControlEvents:UIControlEventTouchUpInside];
    [content addArrangedSubview:payButton];
    [content setCustomSpacing:22.0 afterView:self.resultCard];
    [[payButton.heightAnchor constraintGreaterThanOrEqualToConstant:56.0] setActive:YES];
}

- (UIView *)heroCard {
    UILabel *wordmark = [[UILabel alloc] init];
    wordmark.text = @"PayKit";
    wordmark.font = [DemoTheme roundedFontOfSize:26.0 weight:UIFontWeightHeavy];
    wordmark.textColor = DemoTheme.textPrimary;

    PaddedLabel *chip = [[PaddedLabel alloc] init];
    chip.text = @"DEMO";
    chip.font = [DemoTheme roundedFontOfSize:11.0 weight:UIFontWeightBold];
    chip.textColor = DemoTheme.accent;
    chip.backgroundColor = [DemoTheme.accent colorWithAlphaComponent:0.14];
    chip.layer.cornerRadius = 7.0;
    chip.layer.cornerCurve = kCACornerCurveContinuous;
    chip.clipsToBounds = YES;
    [chip setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UIStackView *topRow = [[UIStackView alloc] initWithArrangedSubviews:@[wordmark, chip]];
    topRow.axis = UILayoutConstraintAxisHorizontal;
    topRow.alignment = UIStackViewAlignmentCenter;
    topRow.spacing = 10.0;

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"客户接入参考收银台。SDK 只负责微信 / 支付宝调用、回调转发与结果归一，最终订单状态以业务后台为准。";
    subtitle.font = [DemoTheme textFontOfSize:13.0 weight:UIFontWeightRegular];
    subtitle.textColor = DemoTheme.textSecondary;
    subtitle.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[topRow, subtitle]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8.0;
    return [self wrap:stack inContainer:[DemoTheme cardView]];
}

- (UIView *)orderCard {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"订单金额";
    label.font = [DemoTheme textFontOfSize:13.0 weight:UIFontWeightMedium];
    label.textColor = DemoTheme.textSecondary;

    UILabel *currency = [[UILabel alloc] init];
    currency.text = @"¥";
    currency.font = [DemoTheme roundedFontOfSize:34.0 weight:UIFontWeightBold];
    currency.textColor = DemoTheme.textPrimary;
    [currency setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    self.amountField = [[UITextField alloc] init];
    self.amountField.text = @"0.01";
    self.amountField.font = [DemoTheme roundedFontOfSize:40.0 weight:UIFontWeightHeavy];
    self.amountField.textColor = DemoTheme.textPrimary;
    self.amountField.tintColor = DemoTheme.accent;
    self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
    self.amountField.borderStyle = UITextBorderStyleNone;
    self.amountField.delegate = self;
    self.amountField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:@"0.00"
            attributes:@{ NSForegroundColorAttributeName: DemoTheme.textTertiary }];

    UIStackView *amountRow = [[UIStackView alloc] initWithArrangedSubviews:@[currency, self.amountField]];
    amountRow.axis = UILayoutConstraintAxisHorizontal;
    amountRow.alignment = UIStackViewAlignmentFirstBaseline;
    amountRow.spacing = 6.0;

    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = DemoTheme.cardBorder;
    [[divider.heightAnchor constraintEqualToConstant:1.0] setActive:YES];

    UILabel *note = [[UILabel alloc] init];
    note.text = @"订单号  PK202606240001 · 测试沙箱";
    note.font = [DemoTheme textFontOfSize:12.0 weight:UIFontWeightRegular];
    note.textColor = DemoTheme.textTertiary;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[label, amountRow, divider, note]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10.0;
    [stack setCustomSpacing:16.0 afterView:amountRow];
    [stack setCustomSpacing:12.0 afterView:divider];
    return [self wrap:stack inContainer:[DemoTheme cardView]];
}

- (UIView *)buildResultCard {
    self.resultCard = [DemoTheme cardView];

    UILabel *header = [[UILabel alloc] init];
    header.text = @"支付结果";
    header.font = [DemoTheme textFontOfSize:13.0 weight:UIFontWeightMedium];
    header.textColor = DemoTheme.textSecondary;

    self.resultIndicator = [[UIView alloc] init];
    self.resultIndicator.backgroundColor = DemoTheme.textTertiary;
    self.resultIndicator.layer.cornerRadius = 4.0;
    self.resultIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.resultIndicator.widthAnchor constraintEqualToConstant:8.0] setActive:YES];
    [[self.resultIndicator.heightAnchor constraintEqualToConstant:8.0] setActive:YES];

    self.resultTitle = [[UILabel alloc] init];
    self.resultTitle.text = @"等待支付";
    self.resultTitle.font = [DemoTheme roundedFontOfSize:18.0 weight:UIFontWeightBold];
    self.resultTitle.textColor = DemoTheme.textPrimary;

    UIStackView *statusRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.resultIndicator, self.resultTitle]];
    statusRow.axis = UILayoutConstraintAxisHorizontal;
    statusRow.alignment = UIStackViewAlignmentCenter;
    statusRow.spacing = 8.0;

    self.resultBody = [[UILabel alloc] init];
    self.resultBody.text = @"点击「去支付」选择渠道后，回调结果会显示在这里。";
    self.resultBody.font = [DemoTheme textFontOfSize:13.0 weight:UIFontWeightRegular];
    self.resultBody.textColor = DemoTheme.textSecondary;
    self.resultBody.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[header, statusRow, self.resultBody]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8.0;
    [stack setCustomSpacing:10.0 afterView:header];
    return [self wrap:stack inContainer:self.resultCard];
}

- (UIView *)wrap:(UIView *)content inContainer:(UIView *)container {
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:18.0],
        [content.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-18.0],
        [content.topAnchor constraintEqualToAnchor:container.topAnchor constant:18.0],
        [content.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-18.0]
    ]];
    return container;
}

#pragma mark Actions

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (NSString *)amountText {
    NSString *raw = [self.amountField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (raw.length == 0) {
        raw = @"0.01";
    }
    return [NSString stringWithFormat:@"¥ %@", raw];
}

- (void)presentPaymentSheet {
    [self.view endEditing:YES];
    // SDK-owned standard payment sheet (Story 5.2). The SDK presents the bottom
    // sheet; once a channel is picked it asks us for the matching request via the
    // provider, then reuses the unified pay path.
    PYKPaymentSheetConfiguration *configuration =
        [PYKPaymentSheetConfiguration standardConfigurationWithAmountText:[self amountText]];
    __weak typeof(self) weakSelf = self;
    [PYKPayKit presentPaymentSheetFromViewController:self
                                      configuration:configuration
                                    requestProvider:^(PYKPayChannel channel,
                                                      void (^provide)(PYKPayRequest * _Nullable, NSError * _Nullable)) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            provide(nil, nil);
            return;
        }
        [strongSelf showPending];
        // In a real app, fetch channel parameters from your backend here.
        provide([strongSelf demoRequestForChannel:channel], nil);
    }
                                         completion:^(PYKPayResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showResult:result];
        });
    }];
}

- (PYKPayRequest *)demoRequestForChannel:(PYKPayChannel)channel {
    if (channel == PYKPayChannelAlipay) {
        return [[PYKAlipayPayRequest alloc] initWithOrderString:PayKitDemoAlipayOrderString
                                                      appScheme:PayKitDemoAlipayScheme];
    }
    return [[PYKWechatPayRequest alloc] initWithAppId:PayKitDemoWechatAppId
                                            partnerId:@"partner-id"
                                             prepayId:PayKitDemoWechatPrepayId
                                         packageValue:@"Sign=WXPay"
                                             nonceStr:@"nonce-from-backend"
                                            timeStamp:@"1700000000"
                                                 sign:@"sign-from-backend"];
}

- (void)showPending {
    self.resultIndicator.backgroundColor = DemoTheme.cancelled;
    self.resultTitle.text = @"支付进行中…";
    self.resultBody.text = @"已通过 PayKit 拉起渠道客户端，等待回调。";
}

- (void)showResult:(PYKPayResult *)result {
    UIColor *color = DemoTheme.textTertiary;
    NSString *statusText = @"未知状态";
    if (result.status == PYKPayStatusSuccess) {
        color = DemoTheme.success;
        statusText = @"支付成功";
    } else if (result.status == PYKPayStatusCancelled) {
        color = DemoTheme.cancelled;
        statusText = @"已取消";
    } else if (result.status == PYKPayStatusFailed) {
        color = DemoTheme.failure;
        statusText = @"支付失败";
    }
    self.resultIndicator.backgroundColor = color;
    self.resultTitle.text = statusText;
    self.resultBody.text = [NSString stringWithFormat:
        @"渠道：%@\n原始码：%@\n原始信息：%@\n说明：客户端成功不等于订单最终成功，请以业务后台确认为准。",
        [self channelName:result.channel],
        result.rawCode ?: @"-",
        result.rawMessage ?: @"-"];
}

- (NSString *)channelName:(PYKPayChannel)channel {
    switch (channel) {
        case PYKPayChannelWechat:
            return @"微信支付";
        case PYKPayChannelAlipay:
            return @"支付宝";
        case PYKPayChannelMock:
            return @"模拟通道";
        default:
            return @"未知通道";
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
