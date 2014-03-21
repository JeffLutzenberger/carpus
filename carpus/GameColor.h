//
//  GameColor.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameColor : NSObject

@property float r;
@property float g;
@property float b;
@property float a;

- (id)initWithRGBA:(float)r g:(float)g b:(float)b a:(float)a;

+ (GameColor*) HSVToColor:(float)h s:(float)s v:(float)v;

@end

typedef enum {
    WHITE,
    BLACK,
    BLUE,
    GREEN,
    RED,
    ORANGE,
    GRAY1,
    NCOLORS
} ETColor;

extern const float gGameColors[][3];
