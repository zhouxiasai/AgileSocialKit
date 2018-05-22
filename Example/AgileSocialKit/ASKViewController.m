//
//  ASKViewController.m
//  AgileSocialKit
//
//  Created by 紫芋 on 05/22/2018.
//  Copyright (c) 2018 紫芋. All rights reserved.
//

#import "ASKViewController.h"
#import "AgileSocialKit.h"

@interface ASKViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *textSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *imageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fileSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkTitleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkDescSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkLinkSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkThumbSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *animateSwitch;

@end

@implementation ASKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(UIButton *)sender {
    ASKShareMessage *message = [self getMessage];
    
    [ASKShare shareToType:sender.tag message:message completion:^(BOOL success, id ret, NSError *error) {
        NSLog(@"%d", success);
    }];
}

- (IBAction)showShareView:(id)sender {
    ASKShareMessage *message = [self getMessage];
    
    [ASKShare showShareSheetAnimated:self.animateSwitch.isOn withImage:message.image link:message.link linkTitle:message.title linkDescription:message.desc linkThumb:message.thumbnail toTargets:ASKShareViewTargetAll completion:^(ASKShareViewTarget target, BOOL success, NSError *error) {
        if (success) {
            NSLog(@"成功");
        } else {
            NSLog(@"失败:%@", error);
        }
    }];
}

- (IBAction)launchMiniProgram:(id)sender {
    //由于 拉起小程序 微信会校验bundleId，demo 会返回跳转失败，放到正式APP 中即可使用
    [ASKShareWechat launchMiniProgramWithName:@"gh_4a971b57c7d3" path:nil miniProgramType:0 completion:^(BOOL success, id ret, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (ASKShareMessage *)getMessage {
    ASKShareMessage *message = [[ASKShareMessage alloc] init];
    message.text = self.textSwitch.isOn ? @"ASKAgileShareKit测试分享文本" : nil;
    message.image = self.imageSwitch.isOn ? [UIImage imageNamed:@"logo.png"] : nil;
    message.link = self.linkLinkSwitch.isOn ? @"http://www.baidu.com" : nil;
    message.title = self.linkTitleSwitch.isOn ? @"测试链接标题" : nil;
    message.desc = self.linkDescSwitch.isOn ? @"测试链接描述232132132132111" : nil;
    message.thumbnail = self.linkThumbSwitch.isOn ? [UIImage imageNamed:@"logo.png"] : nil;
    message.fileName = self.fileSwitch.isOn ? @"logo" : nil;
    message.fileExt = self.fileSwitch.isOn ? @"png" : nil;
    message.fileData = self.fileSwitch.isOn ? UIImagePNGRepresentation([UIImage imageNamed:@"logo.png"]) : nil;
    return message;
}

@end
