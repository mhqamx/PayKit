#import "PaymentViewController.h"
#import "DemoConfig.h"
@import PayKit;

@interface PaymentViewController () <UITextViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UITextView *alipayOrderInput;
@property (nonatomic, strong) UITextView *wechatPrepayInput;
@property (nonatomic, strong) UITextView *resultView;
@property (nonatomic, strong) NSLayoutConstraint *alipayHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *wechatHeightConstraint;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayKit 集成示例";
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    [self buildInterface];
    [self updateInputHeights];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateInputHeights];
}

- (void)buildInterface {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 18.0;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.leadingAnchor constant:16.0],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.trailingAnchor constant:-16.0],
        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:18.0],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-24.0]
    ]];

    self.alipayOrderInput = [[UITextView alloc] init];
    self.wechatPrepayInput = [[UITextView alloc] init];

    [self.contentStack addArrangedSubview:[self headerView]];
    [self.contentStack addArrangedSubview:[self inputSectionWithTitle:@"支付宝支付"
                                                               detail:@"填写后端返回的完整 orderString，Demo 会通过 PayKit 调用支付宝 SDK。"
                                                           inputTitle:@"orderString"
                                                                input:self.alipayOrderInput
                                                          buttonTitle:@"发起支付宝支付"
                                                               action:@selector(startAlipay)]];
    [self.contentStack addArrangedSubview:[self inputSectionWithTitle:@"微信支付"
                                                               detail:@"当前示例保留 prepayId 输入，其余微信字段使用 Demo 默认值，实际接入时应全部来自后端。"
                                                           inputTitle:@"prepayId"
                                                                input:self.wechatPrepayInput
                                                          buttonTitle:@"发起微信支付"
                                                               action:@selector(startWeChatPay)]];
    [self.contentStack addArrangedSubview:[self resultSection]];

    [self configureInput:self.alipayOrderInput
                    text:@"app_id=demo&method=alipay.trade.app.pay&charset=utf-8&sign=demo"
      accessibilityLabel:@"支付宝订单字符串"];
    [self configureInput:self.wechatPrepayInput
                    text:@"wx-prepay-id"
      accessibilityLabel:@"微信预支付订单号"];
}

- (UIView *)headerView {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8.0;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"PayKit 支付 SDK Demo";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.adjustsFontForContentSizeCategory = YES;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"这是客户接入参考页面，不是 SDK 内置收银台。PayKit SDK 只负责微信/支付宝支付调用、回调转发和结果归一。";
    subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.adjustsFontForContentSizeCategory = YES;

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:subtitleLabel];
    return [self cardWithContent:stack];
}

- (UIView *)inputSectionWithTitle:(NSString *)title
                           detail:(NSString *)detail
                       inputTitle:(NSString *)inputTitle
                            input:(UITextView *)input
                      buttonTitle:(NSString *)buttonTitle
                           action:(SEL)action {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12.0;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    titleLabel.adjustsFontForContentSizeCategory = YES;

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.text = detail;
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    detailLabel.textColor = UIColor.secondaryLabelColor;
    detailLabel.numberOfLines = 0;
    detailLabel.adjustsFontForContentSizeCategory = YES;

    UILabel *fieldLabel = [[UILabel alloc] init];
    fieldLabel.text = inputTitle;
    fieldLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    fieldLabel.textColor = UIColor.secondaryLabelColor;
    fieldLabel.adjustsFontForContentSizeCategory = YES;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.title = buttonTitle;
    configuration.baseBackgroundColor = UIColor.systemBlueColor;
    configuration.baseForegroundColor = UIColor.whiteColor;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleMedium;
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(12.0, 16.0, 12.0, 16.0);
    button.configuration = configuration;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:detailLabel];
    [stack addArrangedSubview:fieldLabel];
    [stack addArrangedSubview:input];
    [stack addArrangedSubview:button];
    return [self cardWithContent:stack];
}

- (UIView *)resultSection {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 10.0;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"支付结果";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    self.resultView = [[UITextView alloc] init];
    self.resultView.editable = NO;
    self.resultView.scrollEnabled = NO;
    self.resultView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.resultView.textColor = UIColor.labelColor;
    self.resultView.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    self.resultView.layer.cornerRadius = 8.0;
    self.resultView.textContainerInset = UIEdgeInsetsMake(12.0, 10.0, 12.0, 10.0);
    self.resultView.text = @"支付回调结果会显示在这里。客户端 success 只代表渠道客户端流程成功，最终订单状态仍需以业务后台确认为准。";
    [[self.resultView.heightAnchor constraintGreaterThanOrEqualToConstant:120.0] setActive:YES];

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:self.resultView];
    return [self cardWithContent:stack];
}

- (UIView *)cardWithContent:(UIView *)content {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    container.layer.cornerRadius = 8.0;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [content.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:16.0],
        [content.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-16.0],
        [content.topAnchor constraintEqualToAnchor:container.topAnchor constant:16.0],
        [content.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-16.0]
    ]];
    return container;
}

- (void)configureInput:(UITextView *)input text:(NSString *)text accessibilityLabel:(NSString *)accessibilityLabel {
    input.text = text;
    input.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    input.adjustsFontForContentSizeCategory = YES;
    input.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    input.textColor = UIColor.labelColor;
    input.layer.cornerRadius = 8.0;
    input.layer.borderWidth = 1.0;
    input.layer.borderColor = UIColor.separatorColor.CGColor;
    input.textContainerInset = UIEdgeInsetsMake(10.0, 8.0, 10.0, 8.0);
    input.autocapitalizationType = UITextAutocapitalizationTypeNone;
    input.autocorrectionType = UITextAutocorrectionTypeNo;
    input.scrollEnabled = NO;
    input.delegate = self;
    input.accessibilityLabel = accessibilityLabel;

    NSLayoutConstraint *height = [input.heightAnchor constraintEqualToConstant:52.0];
    height.active = YES;
    if (input == self.alipayOrderInput) {
        self.alipayHeightConstraint = height;
    } else if (input == self.wechatPrepayInput) {
        self.wechatHeightConstraint = height;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateHeightForTextView:textView];
}

- (void)updateInputHeights {
    [self updateHeightForTextView:self.alipayOrderInput];
    [self updateHeightForTextView:self.wechatPrepayInput];
}

- (void)updateHeightForTextView:(UITextView *)textView {
    CGFloat width = MAX(CGRectGetWidth(textView.bounds), CGRectGetWidth(self.view.bounds) - 64.0);
    CGSize fittingSize = [textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat newHeight = MIN(MAX(fittingSize.height, 52.0), 180.0);
    textView.scrollEnabled = fittingSize.height > 180.0;

    if (textView == self.alipayOrderInput) {
        self.alipayHeightConstraint.constant = newHeight;
    } else if (textView == self.wechatPrepayInput) {
        self.wechatHeightConstraint.constant = newHeight;
    }
}

- (void)startAlipay {
    PYKAlipayPayRequest *request = [[PYKAlipayPayRequest alloc] initWithOrderString:self.alipayOrderInput.text ?: @""
                                                                          appScheme:PayKitDemoAlipayScheme];
    __weak typeof(self) weakSelf = self;
    [PYKPayKit payWithRequest:request completion:^(PYKPayResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showResult:result];
        });
    }];
}

- (void)startWeChatPay {
    PYKWechatPayRequest *request = [[PYKWechatPayRequest alloc] initWithAppId:PayKitDemoWechatAppId
                                                                    partnerId:@"partner-id"
                                                                     prepayId:self.wechatPrepayInput.text ?: @""
                                                                 packageValue:@"Sign=WXPay"
                                                                     nonceStr:@"nonce-from-backend"
                                                                    timeStamp:@"1700000000"
                                                                         sign:@"sign-from-backend"];
    __weak typeof(self) weakSelf = self;
    [PYKPayKit payWithRequest:request completion:^(PYKPayResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showResult:result];
        });
    }];
}

- (void)showResult:(PYKPayResult *)result {
    NSString *status = @"未知";
    if (result.status == PYKPayStatusSuccess) {
        status = @"成功";
    } else if (result.status == PYKPayStatusCancelled) {
        status = @"已取消";
    } else if (result.status == PYKPayStatusFailed) {
        status = @"失败";
    }

    self.resultView.text = [NSString stringWithFormat:
        @"状态：%@\n渠道：%@\n原始码：%@\n原始信息：%@\n说明：客户端成功不等于订单最终成功，请以业务后台确认结果为准。",
        status,
        [self channelName:result.channel],
        result.rawCode ?: @"-",
        result.rawMessage ?: @"-"
    ];
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

@end
