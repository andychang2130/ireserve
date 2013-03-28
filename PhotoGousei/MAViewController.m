//
//  MAViewController.m
//  PhotoGousei
//
//  Created by Mac-III on 13/3/14.
//  Copyright (c) 2013年 MacAndy. All rights reserved.
//

#import "MAViewController.h"

@interface MAViewController ()
{
    UIImagePickerController *imagePicker;
}

-(UIImage*) modifyWithImage:(UIImage*)targetImage;
//套過這方法處理影像

@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender
{
    if ([_sourceTypeSegment selectedSegmentIndex]==1
        && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"No Camara" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    
    imagePicker=[UIImagePickerController new];
    
    if ([_sourceTypeSegment selectedSegmentIndex]==0) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        //UIImagePickerControllerSourceTypePhotoLibrary 相片庫
    }else if ([_sourceTypeSegment selectedSegmentIndex]==1) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    
        
        imagePicker.mediaTypes=@[@"public.image",@"public.movie"];
    //@[@"public.image"] array 只取得.image
    imagePicker.delegate=self;

    //Add Customize OverlayView 客制化拍照界面
    if ([_sourceTypeSegment selectedSegmentIndex]==1) {
        UIButton *takeButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        takeButton.frame=CGRectMake(0, 0, 80, 30);
        [takeButton addTarget:self action:@selector(takeButtoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [imagePicker.cameraOverlayView addSubview:takeButton];
        imagePicker.showsCameraControls=NO;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

-(void)takeButtonpressed:(id)sender
{
    [imagePicker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//didFinishPickingMediaWithInfo 取得使用者點了哪張圖
{
    NSLog(@"Info: %@",[info description]);
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //取得MediaType
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *resultImage=[info objectForKey:UIImagePickerControllerOriginalImage];
        //取得OriginalImage
        UIImage *modifiedImage=[self modifyWithImage:resultImage];
        [self.resultImageView setImage:modifiedImage];
        UIImageWriteToSavedPhotosAlbum(modifiedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        //[_resultImageView setImage:resultImage];  用縮圖前
        
        //[_resultImageView setImage:[self    用縮圖後modifyWithImage:resultImage]];
        
        //show出resultImage
        //UIImageView/view/mode 可調整影像呈現
        //Aspect Fit ：維持照片比例顯示,在imageView範圍內.
        //Aspect Fill :維持照片比例顯示,超出imageView也可以.
        //在縮圖時,若選fit或fill會維持照片比例;選left等其他的可真的縮小圖片
    }
    
    else if([mediaType isEqualToString:@"public.movie"])
    {
        // Use Movie Here.
        NSString *tempFilePath=[[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath)==YES)
        {
            UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, @selector(videoFilePath:didFinishSavingWithError:contextInfo:), nil);
        }
        
    }
    
        [imagePicker dismissViewControllerAnimated:YES completion:NO];
    imagePicker=nil;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"Image Saved");
}

-(UIImage*) modifyWithImage:(UIImage*)targetImage
{
    
    
    CGSize targetSize=CGSizeMake(640, 640);
    //CGSize targetSize=CGSizeMake(targetImage.size.width/10, targetImage.size.height/10);
    //縮微10之1
    UIGraphicsBeginImageContext(targetSize);
    //建立虛擬畫布
    
    [targetImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    //顯示目標圖片
    
    UIImage *frameImage=[UIImage imageNamed:@"frame_01.png"];
    [frameImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    //把外觀疊在目標圖片上
    
    UIColor *textColor=[UIColor redColor];
    [textColor set]; //設定之後的文字顏色為textColor指定的顏色
    NSString *textString=@"喵～～～喵";
    UIFont *textFont=[UIFont systemFontOfSize:60];
    [textString drawAtPoint:CGPointMake(0, 0) withFont:textFont];
    //文字寫在圖片上
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    //取出虛擬畫布的內容
    UIGraphicsEndImageContext();
    return resultImage;
    
}


@end


