//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "AdminViewTabBarController.h"

@interface AdminViewTabBarController () <UITabBarDelegate>

@end

@implementation AdminViewTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Admin panel";
}

- (void)sendObject:(id)object sender:(id)sender {
    [self.mvc sendObject:object sender:sender];
}

@end
