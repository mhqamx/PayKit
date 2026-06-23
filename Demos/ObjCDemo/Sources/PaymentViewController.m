#import "PaymentViewController.h"
#import "DemoConfig.h"
@import PayKit;

@interface PaymentViewController ()
@property (nonatomic, strong) UITextField *alipayOrderField;
@property (nonatomic, strong) UITextField *wechatPrepayField;
@property (nonatomic, strong) UITextView *resultView;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayKit ObjC Demo";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self buildInterface];
}

- (void)buildInterface {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"PayKit client payment demo";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.adjustsFontForContentSizeCategory = YES;

    UILabel *noteLabel = [[UILabel alloc] init];
    noteLabel.text = @"Replace sample payloads with backend-issued WeChat and Alipay payment parameters.";
    noteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    noteLabel.textColor = UIColor.secondaryLabelColor;
    noteLabel.numberOfLines = 0;

    self.alipayOrderField = [self textFieldWithPlaceholder:@"Alipay order string"];
    self.alipayOrderField.text = @"app_id=demo&method=alipay.trade.app.pay&charset=utf-8&sign=demo";

    self.wechatPrepayField = [self textFieldWithPlaceholder:@"WeChat prepay id"];
    self.wechatPrepayField.text = @"wx-prepay-id";

    UIButton *alipayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [alipayButton setTitle:@"Start Alipay" forState:UIControlStateNormal];
    [alipayButton addTarget:self action:@selector(startAlipay) forControlEvents:UIControlEventTouchUpInside];

    UIButton *wechatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [wechatButton setTitle:@"Start WeChat Pay" forState:UIControlStateNormal];
    [wechatButton addTarget:self action:@selector(startWeChatPay) forControlEvents:UIControlEventTouchUpInside];

    self.resultView = [[UITextView alloc] init];
    self.resultView.editable = NO;
    self.resultView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.resultView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.resultView.layer.cornerRadius = 8.0;
    self.resultView.text = @"Payment result will appear here.";

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        noteLabel,
        [self labeled:@"Alipay orderString" control:self.alipayOrderField],
        alipayButton,
        [self labeled:@"WeChat prepayId" control:self.wechatPrepayField],
        wechatButton,
        self.resultView
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24.0],
        [self.resultView.heightAnchor constraintEqualToConstant:180.0]
    ]];
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeholder;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return textField;
}

- (UIStackView *)labeled:(NSString *)label control:(UIView *)control {
    UILabel *labelView = [[UILabel alloc] init];
    labelView.text = label;
    labelView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    labelView.textColor = UIColor.secondaryLabelColor;
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[labelView, control]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6.0;
    return stack;
}

- (void)startAlipay {
    PYKAlipayPayRequest *request = [[PYKAlipayPayRequest alloc] initWithOrderString:self.alipayOrderField.text ?: @""
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
                                                                     prepayId:self.wechatPrepayField.text ?: @""
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
    NSString *status = @"unknown";
    if (result.status == PYKPayStatusSuccess) {
        status = @"success";
    } else if (result.status == PYKPayStatusCancelled) {
        status = @"cancelled";
    } else if (result.status == PYKPayStatusFailed) {
        status = @"failed";
    }
    self.resultView.text = [NSString stringWithFormat:
        @"status: %@\nchannel: %ld\nrawCode: %@\nrawMessage: %@\nClient success still needs backend order confirmation.",
        status,
        (long)result.channel,
        result.rawCode ?: @"-",
        result.rawMessage ?: @"-"
    ];
}

@end
