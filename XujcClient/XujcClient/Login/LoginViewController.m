//
//  LoginViewController.m
//  XujcClient
//
//  Created by 田奕焰 on 16/3/1.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

#import "LoginViewController.h"
#import "UIView+BorderLine.h"
#import "LoginLayoutConfigs.h"
#import "LoginTextFieldGroupView.h"
#import "BindingAccountViewController.h"
#import "FormButton.h"
#import <TTTAttributedLabel.h>
#import "ServiceProtocolViewController.h"
#import "VerificationCodeTextField.h"
#import "ChangePasswordViewController.h"
#import "UITextField+Theme.h"
#import "TTTAttributedLabel+Theme.h"

static CGFloat const kButtonMarginBottom = 12.f;

static CGFloat const kSwitchButtonFontSize = 15.f;

@interface LoginViewController()<TTTAttributedLabelDelegate>

@property (strong, nonatomic) LoginTextFieldGroupView *loginTextFieldGroupView;
@property (strong, nonatomic) LoginTextFieldGroupView *signupTextFieldGroupView;

@property (strong, nonatomic) UIImageView *logoImageView;

@property (strong, nonatomic) UITextField *accountTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) FormButton *loginButton;

@property (strong, nonatomic) UITextField *signupNicknameTextField;
@property (strong, nonatomic) UITextField *signupPhoneTextField;
@property (strong, nonatomic) UITextField *signupPasswordTextField;
@property (strong, nonatomic) VerificationCodeTextField *signupVerificationCodeTextField;
@property (strong, nonatomic) FormButton *signupButton;

@property (strong, nonatomic) UIButton *switchButton;

@property (strong, nonatomic) MASConstraint *loginTextFieldGroupViewRightConstraint;
@property (strong, nonatomic) MASConstraint *logoTopConstraint;
@property (strong, nonatomic) MASConstraint *logoBottomConstraint;

@property (strong, nonatomic) LoginViewModel *loginViewModel;
@property (strong, nonatomic) SignupViewModel *signupViewModel;

@property (strong, nonatomic) TTTAttributedLabel *serviceProtocolLabel;
@property (strong, nonatomic) TTTAttributedLabel *forgetPasswordLabel;

@end

@implementation LoginViewController

- (instancetype)initWithLoginViewModel:(LoginViewModel *)loginViewModel andSignupViewModel:(SignupViewModel *)signupViewModel
{
    if (self = [super init]) {
        _loginViewModel = loginViewModel;
        _signupViewModel = signupViewModel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Login Screen";
    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:_logoImageView];
    
    _loginTextFieldGroupView = [[LoginTextFieldGroupView alloc] initWithItemHeight:kLoginTextFieldHeight];
    [self.view addSubview:_loginTextFieldGroupView];
    
    _accountTextField = [UITextField ty_textField];
    _accountTextField.placeholder = NSLocalizedString(@"Phone", nil);
    _accountTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_loginTextFieldGroupView addSubview:_accountTextField];
    
    _passwordTextField = [UITextField ty_textField];
    _passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
    _passwordTextField.secureTextEntry = YES;
    [_loginTextFieldGroupView addSubview:_passwordTextField];
    
    _signupTextFieldGroupView = [[LoginTextFieldGroupView alloc] initWithItemHeight:kLoginTextFieldHeight];
    [self.view addSubview:_signupTextFieldGroupView];
    
    _signupNicknameTextField = [UITextField ty_textField];
    _signupNicknameTextField.placeholder = NSLocalizedString(@"Nickname", nil);
    [_signupTextFieldGroupView addSubview:_signupNicknameTextField];
    
    _signupPhoneTextField = [UITextField ty_textField];
    _signupPhoneTextField.placeholder = NSLocalizedString(@"Phone(Only support China inland)", nil);
    _signupPhoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_signupTextFieldGroupView addSubview:_signupPhoneTextField];
    
    _signupVerificationCodeTextField = [[VerificationCodeTextField alloc] initWithViewModel:[self.signupViewModel verificationCodeTextFieldViewModel]];
    [_signupTextFieldGroupView addSubview:_signupVerificationCodeTextField];
    
    _signupPasswordTextField = [UITextField ty_textField];
    _signupPasswordTextField.placeholder = NSLocalizedString(@"Password", nil);
    _signupPasswordTextField.secureTextEntry = YES;
    [_signupTextFieldGroupView addSubview:_signupPasswordTextField];
    
    _loginButton = [[FormButton alloc] init];
    [_loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.view addSubview:_loginButton];
    
    _signupButton = [[FormButton alloc] init];
    [_signupButton setTitle:NSLocalizedString(@"Signup", nil) forState:UIControlStateNormal];
    [self.view addSubview:_signupButton];
    
    _switchButton = [[UIButton alloc] init];
    [_switchButton setTitleColor:[UIColor ty_textGray] forState:UIControlStateNormal];
    _switchButton.titleLabel.font = [UIFont systemFontOfSize:kSwitchButtonFontSize];
    [self.view addSubview:_switchButton];
    
    _serviceProtocolLabel = [TTTAttributedLabel ty_smallLabel];
    _serviceProtocolLabel.text = [NSString stringWithFormat:@"%@%@", @"点击「注册」按钮\n代表你已阅读并同意", NSLocalizedString(@"Service Protocol", nil)];
    _serviceProtocolLabel.delegate = self;
    NSURL *useAgreementUrl = [NSURL URLWithString:NSStringFromClass([ServiceProtocolViewController class])];
    NSRange range = [_serviceProtocolLabel.text rangeOfString:NSLocalizedString(@"Service Protocol", nil)];
    [_serviceProtocolLabel addLinkToURL:useAgreementUrl withRange:range];
    [self.view addSubview:_serviceProtocolLabel];
    
    _forgetPasswordLabel = [TTTAttributedLabel ty_smallLabel];
    _forgetPasswordLabel.text = NSLocalizedString(@"Forget Password?", nil);
    _forgetPasswordLabel.delegate = self;
    NSURL *forgetPasswordUrl = [NSURL URLWithString:NSStringFromClass([ChangePasswordViewController class])];
    [_forgetPasswordLabel addLinkToURL:forgetPasswordUrl withRange:NSMakeRange(0, [_forgetPasswordLabel.text length])];
    [self.view addSubview:_forgetPasswordLabel];
    
    [self initConstraints];
    
    // Binding
    [self bindSwitchAnimation];
    
    [self bindViewModel];
    
    // load account cache
    self.accountTextField.text = [_loginViewModel currentAccountPhone];
    self.passwordTextField.text = [_loginViewModel currentAccountPassword];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)initConstraints
{
    [_logoImageView makeConstraints:^(MASConstraintMaker *make) {
        self.logoTopConstraint = make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view.mas_width).with.multipliedBy(0.5f);
        make.width.equalTo(self.logoImageView.mas_height);
    }];
    
    [_signupTextFieldGroupView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom);
        make.left.equalTo(self.loginTextFieldGroupView.mas_right).with.offset(2 * kLoginContentMarginHorizontal);
        make.width.equalTo(self.view.mas_width).with.offset(-2 * kLoginContentMarginHorizontal);
    }];
    
    [_loginTextFieldGroupView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signupVerificationCodeTextField);
        self.loginTextFieldGroupViewRightConstraint = make.right.equalTo(self.view.mas_right).with.offset(-kLoginContentMarginHorizontal);
        make.width.equalTo(self.signupTextFieldGroupView);
    }];
    
    [_loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(kLoginButtonMarginTop);
        make.width.equalTo(self.signupNicknameTextField);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(kLoginButtonHeight));
    }];
    
    [_signupButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton);
        make.width.equalTo(self.loginButton);
        make.centerX.equalTo(self.loginButton);
        make.height.equalTo(self.loginButton);
    }];
    
    [_serviceProtocolLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signupButton.mas_bottom).with.offset(kButtonMarginBottom);
        make.centerX.equalTo(self.signupButton);
    }];
    
    [_forgetPasswordLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom).with.offset(kButtonMarginBottom);
        make.centerX.equalTo(self.loginButton);
    }];
    
    [_switchButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signupButton.mas_bottom).with.offset(kButtonMarginBottom);
        make.centerX.equalTo(self.serviceProtocolLabel.mas_centerX);
    }];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    @weakify(self);
    [[defaultCenter ty_keyboardWillShowSignal] subscribeNext:^(NSNotification *note) {
        @strongify(self);
        NSDictionary *userInfo = note.userInfo;
        // Get keyboard animation.
        NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration = durationValue.doubleValue;
        
        NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
        UIViewAnimationCurve animationCurve = curveValue.intValue;
        
        [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            [self.logoTopConstraint uninstall];
            [self.logoBottomConstraint uninstall];
            self.logoBottomConstraint = make.bottom.equalTo(self.mas_topLayoutGuideBottom);
        }];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:(animationCurve << 16)
                         animations:^{
                             [self.view layoutIfNeeded];
                             self.switchButton.layer.opacity = 0;
                         }
                         completion:nil];
    }];
    
    [[defaultCenter ty_keyboardWillHideSignal] subscribeNext:^(NSNotification *note) {
        @strongify(self);
        NSDictionary *userInfo = note.userInfo;
        // Get keyboard animation.
        NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration = durationValue.doubleValue;
        
        NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
        UIViewAnimationCurve animationCurve = curveValue.intValue;
        
        [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            [self.logoTopConstraint uninstall];
            [self.logoBottomConstraint uninstall];
            self.logoTopConstraint = make.top.equalTo(self.mas_topLayoutGuideBottom);
        }];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:(animationCurve << 16)
                         animations:^{
                             [self.view layoutIfNeeded];
                             self.switchButton.layer.opacity = 1.f;
                         }
                         completion:nil];
    }];
}

- (void)bindSwitchAnimation
{
    @weakify(self);
    // Animate
    RACSignal *switchButtonStatusChangedSignal = [RACObserve(_switchButton, selected) distinctUntilChanged];
    [switchButtonStatusChangedSignal subscribeNext:^(NSNumber *value) {
        @strongify(self);
        BOOL selected = [value boolValue];
        [self.loginTextFieldGroupView mas_updateConstraints:^(MASConstraintMaker *make) {
            [self.loginTextFieldGroupViewRightConstraint uninstall];
            if (selected) {
                self.loginTextFieldGroupViewRightConstraint = make.right.equalTo(self.view.mas_left).with.offset(-kLoginContentMarginHorizontal);
            } else {
                self.loginTextFieldGroupViewRightConstraint = make.right.equalTo(self.view.mas_right).with.offset(-kLoginContentMarginHorizontal);
            }
        }];
        [UIView animateWithDuration:.5f animations:^{
            [self.view layoutIfNeeded];
        }];
    }];
    // Text update
    [_switchButton rac_liftSelector:@selector(setTitle:forState:) withSignals:[switchButtonStatusChangedSignal map:^id(NSNumber *value) {
        return [value boolValue] ? NSLocalizedString(@"SwitchToLogin", nil) : NSLocalizedString(@"SwitchToSignup", nil);
    }], [RACSignal return:@(UIControlStateNormal)], nil];
    
    // Button Hidden
    RACSignal *signupShowSignal = [switchButtonStatusChangedSignal not];
    RAC(self.loginButton, hidden) = switchButtonStatusChangedSignal;
    RAC(self.signupButton, hidden) = signupShowSignal;
    RAC(self.serviceProtocolLabel, hidden) = signupShowSignal;
    RACSignal *smallLabelOpacitySignal = [RACObserve(self.switchButton, layer.opacity) map:^id(NSNumber *value) {
        return @(1 - [value floatValue]);
    }];
    RAC(self.serviceProtocolLabel, layer.opacity) = smallLabelOpacitySignal;
    
    RAC(self.forgetPasswordLabel, hidden) = switchButtonStatusChangedSignal;
    RAC(self.forgetPasswordLabel, layer.opacity) = smallLabelOpacitySignal;
    
    // Selected change
    _switchButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        TyLogDebug(@"switch button clicked");
        self.switchButton.selected = !self.switchButton.selected;
        return [RACSignal empty];
    }];
}

- (void)bindViewModel
{
    // Login
    _loginButton.rac_command = self.loginViewModel.executeLogin;
    RAC(self.loginViewModel, account) = [RACSignal merge:@[self.accountTextField.rac_textSignal, RACObserve(self.accountTextField, text)]];
    RAC(self.loginViewModel, password) = [RACSignal merge:@[self.passwordTextField.rac_textSignal, RACObserve(self.passwordTextField, text)]];
    @weakify(self);
    [self.loginViewModel.executeLogin.executionSignals subscribeNext:^(id x) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    
    [[self.loginViewModel.executeLogin.executionSignals concat] subscribeNext:^(id x) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [[self.loginViewModel.executeLogin.executing filter:^BOOL(id value) {
        return [value boolValue];
    }] subscribeNext:^(id x) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];

    [self.loginViewModel.executeLogin.errors subscribeNext:^(NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:kErrorHUDShowTime];
    }];
    
    // Signup
    _signupButton.rac_command = self.signupViewModel.executeSignup;
    RAC(self.signupViewModel, nickname) = [RACSignal merge:@[self.signupNicknameTextField.rac_textSignal, RACObserve(self.signupNicknameTextField, text)]];
    RAC(self.signupViewModel, account) = [RACSignal merge:@[self.signupPhoneTextField.rac_textSignal, RACObserve(self.signupPhoneTextField, text)]];
    RAC(self.signupViewModel, password) = [RACSignal merge:@[self.signupPasswordTextField.rac_textSignal, RACObserve(self.signupPasswordTextField, text)]];
    
    [self.signupViewModel.executeSignup.executionSignals subscribeNext:^(id x) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    
    [[self.signupViewModel.executeSignup.executionSignals concat] subscribeNext:^(NSString *message) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (hud != nil) {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = NSLocalizedString(message, nil);
            [hud hide:YES afterDelay:kSuccessHUDShowTime];
        }
        self.switchButton.selected = NO;
    }];
    
    [[self.signupViewModel.executeSignup.executing filter:^BOOL(id value) {
        return [value boolValue];
    }] subscribeNext:^(id x) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
    
    [self.signupViewModel.executeSignup.errors subscribeNext:^(NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:kErrorHUDShowTime];
    }];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString *className = url.absoluteString;
    Class viewControllerClass = NSClassFromString(className);
    id viewController;
    if ([className isEqualToString:NSStringFromClass([ServiceProtocolViewController class])]) {
        viewController = [[viewControllerClass alloc] initWithViewModel:[_signupViewModel serviceProtocolViewModel]];
    } else {
        viewController = [[viewControllerClass alloc] initWithViewModel:[_loginViewModel changePasswordViewModel]];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
