//
//  ViewController.h
//  Pictograph
//
//  Created by Adam on 2015-09-30.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageCoder.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

typedef NS_ENUM(NSInteger, ImageOption) {
    ImageOptionEncoder,
    ImageOptionDecoder,
    ImageOptionNeither
};

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *encodeButton;
@property (nonatomic, strong) UIButton *decodeButton;
@property (nonatomic, assign) ImageOption currentOption;
@property (nonatomic, strong) UIAlertController *alertController;

@end
