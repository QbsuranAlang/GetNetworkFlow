//
//  ViewController.h
//  GetNetworkFlow
//
//  Created by 聲華 陳 on 2014/11/26.
//  Copyright (c) 2014年 Qbsuran Alang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)flow:(id)sender;
- (IBAction)inOut:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *message;

@end

