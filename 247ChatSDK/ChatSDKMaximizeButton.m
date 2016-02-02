//
//  ChatSDKMaximizeButton.m
//  247ChatSDK
//
//  Created by Atul Khatri on 18/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import "ChatSDKMaximizeButton.h"
#import "ChatSDKResources.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatSDKConstants.h"

@implementation ChatSDKMaximizeButton
@synthesize portraitPos,landscapePos;

UILabel* badgeView=nil;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRotation) name:UIDeviceOrientationDidChangeNotification object:nil];
        btnWidth = MAXIMISE_BUTTON_WIDTH;
        btnHeight = MAXIMIZE_BUTTON_HEIGHT;
        
        [self mapPositions];

        // Do any additional setup after loading the view, typically from a nib.
        positionsArray  = [[NSMutableArray alloc] init];
        [self createArray];
        
        [self setTitle:@"Chat" forState:UIControlStateNormal];
        [[self titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [self attachBadge];
    }
    return self;
}

-(void)showWithAnimation
{
    [self checkRotation];
    CGRect currentFrame= self.frame;
    CGRect frameAfterAnimation= self.frame;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
       
    if(currentOrientation == UIInterfaceOrientationPortrait)
    {
        //Manipulating current frame
        if(portraitPos==2 || portraitPos==3 || portraitPos==4)
        {
            currentFrame.origin.x+=btnHeight;
        }else if(portraitPos==0 || portraitPos==6 || portraitPos==7)
        {
            currentFrame.origin.x-=btnHeight;
        }else if(portraitPos==1)
        {
            currentFrame.origin.y-=btnHeight;
        }else if(portraitPos==5)
        {
            currentFrame.origin.y+=btnHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //Manipulating current frame
        if(portraitPos==2 || portraitPos==3 || portraitPos==4)
        {
            currentFrame.origin.x-=btnHeight;
        }else if(portraitPos==0 || portraitPos==6 || portraitPos==7)
        {
            currentFrame.origin.x+=btnHeight;
        }else if(portraitPos==1)
        {
            currentFrame.origin.y+=btnHeight;
        }else if(portraitPos==5)
        {
            currentFrame.origin.y-=btnHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        //Manipulating current frame
        if(landscapePos==2 || landscapePos==3 || landscapePos==4)
        {
            currentFrame.origin.y-=btnHeight;
        }else if(landscapePos==0 || landscapePos==6 || landscapePos==7)
        {
            currentFrame.origin.y+=btnHeight;
        }else if(landscapePos==1)
        {
            currentFrame.origin.x-=btnHeight;
        }else if(landscapePos==5)
        {
            currentFrame.origin.x+=btnHeight;
        }
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //Manipulating current frame
        if(landscapePos==2 || landscapePos==3 || landscapePos==4)
        {
            currentFrame.origin.y+=btnHeight;
        }else if(landscapePos==0 || landscapePos==6 || landscapePos==7)
        {
            currentFrame.origin.y-=btnHeight;
        }else if(landscapePos==1)
        {
            currentFrame.origin.x+=btnHeight;
        }else if(landscapePos==5)
        {
            currentFrame.origin.x-=btnHeight;
        }        
    }    
    
    self.frame=currentFrame;
   
    [UIView animateWithDuration:0.5 animations:^{
        //Assigning new frame
        self.frame= frameAfterAnimation;
    }];
}

-(void)hideWithAnimation
{
    CGRect frameAfterAnimation= self.frame;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
       
    if(currentOrientation == UIInterfaceOrientationPortrait)
    {
        //Manipulating current frame
        if(portraitPos==2 || portraitPos==3 || portraitPos==4)
        {
            frameAfterAnimation.origin.x+=btnHeight;
        }else if(portraitPos==0 || portraitPos==6 || portraitPos==7)
        {
            frameAfterAnimation.origin.x-=btnHeight;
        }else if(portraitPos==1)
        {
            frameAfterAnimation.origin.y-=btnHeight;
        }else if(portraitPos==5)
        {
            frameAfterAnimation.origin.y+=btnHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //Manipulating current frame
        if(portraitPos==2 || portraitPos==3 || portraitPos==4)
        {
            frameAfterAnimation.origin.x-=btnHeight;
        }else if(portraitPos==0 || portraitPos==6 || portraitPos==7)
        {
            frameAfterAnimation.origin.x+=btnHeight;
        }else if(portraitPos==1)
        {
            frameAfterAnimation.origin.y+=btnHeight;
        }else if(portraitPos==5)
        {
            frameAfterAnimation.origin.y-=btnHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        //Manipulating current frame
        if(landscapePos==2 || landscapePos==3 || landscapePos==4)
        {
            frameAfterAnimation.origin.y-=btnHeight;
        }else if(landscapePos==0 || landscapePos==6 || landscapePos==7)
        {
            frameAfterAnimation.origin.y+=btnHeight;
        }else if(landscapePos==1)
        {
            frameAfterAnimation.origin.x-=btnHeight;
        }else if(landscapePos==5)
        {
            frameAfterAnimation.origin.x+=btnHeight;
        }
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //Manipulating current frame
        if(landscapePos==2 || landscapePos==3 || landscapePos==4)
        {
            frameAfterAnimation.origin.y+=btnHeight;
        }else if(landscapePos==0 || landscapePos==6 || landscapePos==7)
        {
            frameAfterAnimation.origin.y-=btnHeight;
        }else if(landscapePos==1)
        {
            frameAfterAnimation.origin.x+=btnHeight;
        }else if(landscapePos==5)
        {
            frameAfterAnimation.origin.x-=btnHeight;
        }
    }
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         //Assigning new frame
                         self.frame= frameAfterAnimation;
                     }
                     completion:^(BOOL finished){
                         self.hidden=YES;
                     }];
}

-(void)createArray//:(CGFloat )screenWidth and:(CGFloat)screenHeight
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSDictionary *dictTL = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f], nil] forKey:@"TL"];
    [positionsArray addObject:dictTL];
    NSDictionary *dictTM = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:(screenWidth-btnWidth)/2],[NSNumber numberWithFloat:0.0f], nil] forKey:@"TM"];
    [positionsArray addObject:dictTM];
    NSDictionary *dictTR = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:screenWidth-btnWidth],[NSNumber numberWithFloat:0.0f], nil] forKey:@"TR"];
    [positionsArray addObject:dictTR];
    NSDictionary *dictRM = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:screenWidth-btnWidth],[NSNumber numberWithFloat:(screenHeight-btnWidth)/2], nil] forKey:@"RM"];
    [positionsArray addObject:dictRM];
    NSDictionary *dictBR = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:screenWidth-btnWidth],[NSNumber numberWithFloat:screenHeight-btnWidth], nil] forKey:@"BR"];
    [positionsArray addObject:dictBR];
    NSDictionary *dictBM = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:(screenWidth-btnWidth)/2],[NSNumber numberWithFloat:screenHeight-btnWidth], nil] forKey:@"BM"];
    [positionsArray addObject:dictBM];
    NSDictionary *dictBL = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:screenHeight-btnWidth], nil] forKey:@"BL"];
    [positionsArray addObject:dictBL];
    NSDictionary *dictLM = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:(screenHeight-btnWidth)/2], nil] forKey:@"LM"];
    [positionsArray addObject:dictLM];
    [positionsArray addObject:dictTL];
    [positionsArray addObject:dictTM];
    [positionsArray addObject:dictTR];
    [positionsArray addObject:dictRM];
    [positionsArray addObject:dictBR];
    [positionsArray addObject:dictBM];
    
}

-(NSArray*)fixCord:(NSArray*)currentPosition{
    
    float x= [[currentPosition objectAtIndex:0] floatValue];
    float y= [[currentPosition objectAtIndex:1] floatValue];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if(currentOrientation == UIInterfaceOrientationPortrait)
    {
        y=y+20;
    }
    else if(currentOrientation== UIInterfaceOrientationLandscapeLeft)
    {
        x=x-10;
        //Patch
        x=x+20;
    }else if(currentOrientation== UIInterfaceOrientationLandscapeRight)
    {
        x=x+10;
        //Patch
        x=x-20;
    }
    
    NSLog(@"fixed X=%f, fixed Y=%f",x,y);
    NSArray* fixedCord= [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:x],[NSNumber numberWithFloat:y], nil];
    return fixedCord;
}

-(void)rotateButton
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation==UIInterfaceOrientationPortrait){
        if((portraitPos==1 || portraitPos==5))
        {
            NSLog(@"## ROTATE-> Portrait-> IF");
            //Attaching top or bottom center
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 0), CGAffineTransformMakeRotation(4*M_PI/2.0));
            self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
        }else{
            if(portraitPos==0 || portraitPos==7)
            {
                NSLog(@"## ROTATE-> Portrait-> ELSE-> POS 0-7");
                //Attaching left
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 10), CGAffineTransformMakeRotation(M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==2 || portraitPos==3){
                NSLog(@"## ROTATE-> Portrait-> ELSE-> POS 2-3");
                //Attaching right
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 10), CGAffineTransformMakeRotation(3*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==4){
                NSLog(@"## ROTATE-> Portrait-> ELSE-> POS 4");
                //Attaching bottom-right
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 10), CGAffineTransformMakeRotation(3*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==6){
                NSLog(@"## ROTATE-> Portrait-> ELSE-> POS 6");
                //Attaching bottom-left
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 10), CGAffineTransformMakeRotation(M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }
        }
    }else if(orientation==UIInterfaceOrientationPortraitUpsideDown){
        if((portraitPos==1 || portraitPos==5))
        {
            NSLog(@"## ROTATE-> UPSideDown-> IF");
            //Attaching top or bottom center
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 0), CGAffineTransformMakeRotation(2*M_PI/2.0));
            self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
        }else{
            if(portraitPos==0 || portraitPos==7)
            {
                NSLog(@"## ROTATE-> UPSideDown-> ELSE-> POS 0-7");
                //Attaching left
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 10), CGAffineTransformMakeRotation(3*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==2 || portraitPos==3){
                NSLog(@"## ROTATE-> UPSideDown-> ELSE-> POS 2-3");
                //Attaching right
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 10), CGAffineTransformMakeRotation(M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==4){
                NSLog(@"## ROTATE-> UPSideDown-> ELSE-> POS 4");
                //Attaching bottom-right
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 10), CGAffineTransformMakeRotation(M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(portraitPos==6){
                NSLog(@"## ROTATE-> UPSideDown-> ELSE-> POS 6");
                //Attaching bottom-left
                CGAffineTransform transform= CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 10), CGAffineTransformMakeRotation(3*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }
        }
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        if((landscapePos==1 || landscapePos==5))
        {
            NSLog(@"## ROTATE-> Landscape Right-> IF");
            //Attaching top or bottom center
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 0), CGAffineTransformMakeRotation(M_PI/2.0));
            self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            
        }else{
            if(landscapePos==0 || landscapePos==7)
            {
                NSLog(@"## ROTATE-> Landscape Right-> ELSE-> POS 0-7");
                //Attaching left
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 0), CGAffineTransformMakeRotation(2*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==2 || landscapePos==3){
                NSLog(@"## ROTATE-> Landscape Right-> ELSE-> POS 2-3");
                //Attaching right
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 20), CGAffineTransformMakeRotation(4*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==4){
                NSLog(@"## ROTATE-> Landscape Right-> ELSE-> POS 4");
                //Attaching bottom-right
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 20), CGAffineTransformMakeRotation(4*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==6){
                NSLog(@"## ROTATE-> Landscape Right-> ELSE-> POS 6");
                //Attaching bottom-left
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 0), CGAffineTransformMakeRotation(2*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }
        }
    }else if(orientation == UIInterfaceOrientationLandscapeLeft){
        if((landscapePos==1 || landscapePos==5))
        {
            NSLog(@"## ROTATE-> Landscape Left-> IF");
            //Attaching top or bottom center
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 0), CGAffineTransformMakeRotation(3*M_PI/2.0));
            self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            
        }else{
            if(landscapePos==0 || landscapePos==7)
            {
                NSLog(@"## ROTATE-> Landscape Left-> ELSE-> POS 0-7");
                //Attaching left
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 20), CGAffineTransformMakeRotation(4*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==2 || landscapePos==3){
                NSLog(@"## ROTATE-> Landscape Left-> ELSE-> POS 2-3");
                //Attaching right
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 0), CGAffineTransformMakeRotation(2*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==4){
                NSLog(@"## ROTATE-> Landscape Left-> ELSE-> POS 4");
                //Attaching bottom-right
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(10, 0), CGAffineTransformMakeRotation(2*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }else if(landscapePos==6){
                NSLog(@"## ROTATE-> Landscape Left-> ELSE-> POS 6");
                //Attaching bottom-left
                CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-10, 20), CGAffineTransformMakeRotation(4*M_PI/2.0));
                self.transform = CGAffineTransformConcat(CGAffineTransformIdentity, transform);
            }
        }
    }
//    [self showWithAnimation];
}

-(void)checkRotation
{
    NSLog(@"##### inside checkRotation");
    self.transform = CGAffineTransformIdentity;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation==UIInterfaceOrientationPortrait)
    {
        
        NSLog(@"UIInterfaceOrientationPortrait");
        NSDictionary *dict = [positionsArray objectAtIndex:(portraitPos + 0*2)];
        NSLog(@"dict =%@",dict);
        for (id key in dict)
        {
            id anObject = [dict objectForKey:key];
            NSArray *tempArr = anObject;
            tempArr= [self fixCord:tempArr];
            
            [self setFrame:CGRectMake([[tempArr objectAtIndex:0] floatValue],[[tempArr objectAtIndex:1] floatValue], btnWidth, btnHeight)];
            
        }
        [self rotateButton];
    }
    else if(orientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        
        NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
        NSDictionary *dict = [positionsArray objectAtIndex:(portraitPos + 2*2)];
        NSLog(@"dict =%@",dict);
        for (id key in dict)
        {
            id anObject = [dict objectForKey:key];
            NSArray *tempArr = anObject;
            tempArr= [self fixCord:tempArr];
            
            [self setFrame:CGRectMake([[tempArr objectAtIndex:0] floatValue],[[tempArr objectAtIndex:1] floatValue], btnWidth, btnHeight)];
            
        }
        [self rotateButton];
    }
    else if(orientation == UIInterfaceOrientationLandscapeRight)
    {
        
        NSLog(@"UIInterfaceOrientationLandscapeRight");
        NSDictionary *dict = [positionsArray objectAtIndex:(landscapePos + 1*2)];
        NSLog(@"dict =%@",dict);
        for (id key in dict)
        {
            id anObject = [dict objectForKey:key];
            NSArray *tempArr = anObject;
            tempArr= [self fixCord:tempArr];
            
            [self setFrame:CGRectMake([[tempArr objectAtIndex:0] floatValue],[[tempArr objectAtIndex:1] floatValue] , btnWidth, btnHeight)];
        }
        
        [self rotateButton];
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"UIInterfaceOrientationLandscapeLeft");
        NSDictionary *dict = [positionsArray objectAtIndex:(landscapePos + 3*2)];
        NSLog(@"dict =%@",dict);
        for (id key in dict)
        {
            id anObject = [dict objectForKey:key];
            NSArray *tempArr = anObject;
            tempArr= [self fixCord:tempArr];
            
            [self setFrame:CGRectMake([[tempArr objectAtIndex:0] floatValue],[[tempArr objectAtIndex:1] floatValue] , btnWidth, btnHeight)];
            
        }
        [self rotateButton];
    }
    
}

-(void)mapPositions{
    ChatSDKResources* resources= [ChatSDKResources getSDKResourcesInstance];
    [resources initializeValues];
    NSLog(@"PosPortrait: %@, PosLandscape: %@", resources.minimizedButtonPositionPortrait, resources.minimizedButtonPositionLandscape);
    if([resources isXMLValid]){
        if([resources.minimizedButtonPositionPortrait isEqualToString:@"top-center"]){
            portraitPos=1;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"top-right"]){
            portraitPos=2;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"middle-left"]){
            portraitPos=7;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"middle-right"]){
            portraitPos=3;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"bottom-left"]){
            portraitPos=6;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"bottom-center"]){
            portraitPos=5;
        }else if([resources.minimizedButtonPositionPortrait isEqualToString:@"bottom-right"]){
            portraitPos=4;
        }else{
            //Defaults to top-left
            portraitPos=0;
            NSLog(@"##portraitPos %i",portraitPos);
        }
        
        if([resources.minimizedButtonPositionLandscape isEqualToString:@"top-center"]){
            landscapePos=1;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"top-right"]){
            landscapePos=2;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"middle-left"]){
            landscapePos=7;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"middle-right"]){
            landscapePos=3;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"bottom-left"]){
            landscapePos=6;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"bottom-center"]){
            landscapePos=5;
        }else if([resources.minimizedButtonPositionLandscape isEqualToString:@"bottom-right"]){
            landscapePos=4;
        }else{
            //Defaults to top-left
            landscapePos=0;
        }
    }else{
        NSLog(@"mapPositions XML IS INVALID");
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)incrementBadgeCount{
    NSString* currentString= [[NSString alloc]initWithFormat:@"%c",[badgeView.text characterAtIndex:0]];
    int currentCount= [currentString intValue];
    NSString* countString= (currentCount == 9)? [[NSString alloc] initWithFormat:@"%i+",currentCount] : [[NSString alloc]initWithFormat:@"%i",++currentCount];
    [badgeView setText:countString];
    badgeView.hidden=NO;
}

-(void)resetBadge{
    [badgeView setText:@"0"];
    badgeView.hidden=YES;
}

-(void)attachBadge{
    badgeView= [[UILabel alloc] initWithFrame:CGRectMake(btnWidth- ((btnWidth/3.5)+2), 3, btnWidth/3.5, btnWidth/3.5)];
    [badgeView setText:@"0"];
    [badgeView setTextColor:[UIColor whiteColor]];
    [badgeView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    [badgeView setTextAlignment:NSTextAlignmentCenter];
    [badgeView setBackgroundColor:[UIColor redColor]];
    badgeView.layer.cornerRadius = 8;
    badgeView.layer.borderColor = [UIColor whiteColor].CGColor;
    badgeView.layer.borderWidth = 1.8;
    [self addSubview:badgeView];
    [badgeView setHidden:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
