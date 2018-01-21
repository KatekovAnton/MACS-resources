//
//  AppDelegate.m
//  maxtouchTool
//
//  Created by Katekov Anton on 8/3/16.
//  Copyright © 2016 katekovanton. All rights reserved.
//

#import "AppDelegate.h"



@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

BOOL Foo(NSString *string) {
    return [string rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]].location != NSNotFound;
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    
//    NSArray *strings = @[@"    d",
//                         @"    ",
//                         @"dfsdf",
//                         @"dds dsf dsf    dsfsad"];
//    for (NSString *string in strings) {
//        BOOL result = Foo(string);
//        if (result)
//            NSLog(@"Yes");
//        else
//            NSLog(@"No");
//    }
//    int a = 0;
//    a++;
//    CGFloat f = copysign(1.0, 0);
//    f=f;
    [self calculateCoordinates];
}

- (void)calculateCoordinates
{
    float addAngle = M_PI / 180.0 * 22.5;
    
    float y = 48;
    float radius = 24;
    for (int i = 0; i < 8; i++) {
        float angle = (i + 6) * M_PI / 4.0 + addAngle;
        float x = cosf(angle) * radius;
        float z = sinf(angle) * radius;
        printf("%04d:\t%.03f\t%.03f\t%.03f\n", i * 45, x, y, z);
    }
    
    int a = 0;
    a++;
}

- (void)testDecode {

    // reading first texture value
    printf("reading 1st texture:\n");
    float coef = 1;
    [self decodeValue:0 coef:coef];
    printf(" no \n");
    [self decodeValue:0.3 coef:coef];
    printf(" yes \n");
    [self decodeValue:0.6 coef:coef];
    printf(" no \n");
    [self decodeValue:1.0 coef:coef];
    printf(" yes \n");
    
    printf("\n\nreading 2nd texture:\n");
    
    coef = 0;
    [self decodeValue:0 coef:coef];
    printf(" no \n");
    [self decodeValue:0.3 coef:coef];
    printf(" no \n");
    [self decodeValue:0.6 coef:coef];
    printf(" yes \n");
    [self decodeValue:1.0 coef:coef];
    printf(" yes \n");
}

- (void)decodeValue:(float)value coef:(float)coef
{
    float value1 = (0.6 - value) * value;
    value1 = value1 * value1;
    value1 = value1 * 255;
    value1 = value1 * coef;
    
    float value2 = (value - 0.5)*10. * (1.0 - coef);
    
    float result = value1 + value2;
    printf("%f", result);
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
