//
//  GameColor.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GameColor.h"

@implementation GameColor

- (id)initWithRGBA:(float)r g:(float)g b:(float)b a:(float)a {
    self = [super init];
    if (self) {
        _r = r;
        _g = g;
        _b = b;
        _a = a;
    }
    return self;
}

@end
