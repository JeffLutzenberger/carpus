//
//  GameColor.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GameColor.h"

const float gGameColors[][3] = {
    {1.0, 1.0, 1.0},
    {0, 0, 0},
    {0, 0.6, 1.0},
    {0, 1.0, 0},
    {1.0, 0, 0},
    {1.0, 0.6, 0},
    {0.4, 0.4, 1.0}
};

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

+ (GameColor*) HSVToColor:(float)h s:(float)s v:(float)v {
    if (h == 0 && s == 0)
        return [[GameColor alloc] initWithRGBA:v g:v b:v a:1.0];
    float c = s * v;
    float x = c * (1 - ABS(fmodf(h, 2) - 1));
    float m = v - c;
    
    if (h < 1) return [[GameColor alloc] initWithRGBA:c + m g:x + m b:m a:1.0]; //new Color(c + m, x + m, m);
    else if (h < 2) return [[GameColor alloc] initWithRGBA:x + m g:c + m b:m a:1.0];//new Color(x + m, c + m, m);
    else if (h < 3) return [[GameColor alloc] initWithRGBA:m g:c + m b:x + m a:1.0];//new Color(m, c + m, x + m);
    else if (h < 4) return [[GameColor alloc] initWithRGBA:m g:x + m b:c + m a:1.0];//new Color(m, x + m, c + m);
    else if (h < 5) return [[GameColor alloc] initWithRGBA:x + m g:m b:c + m a:1.0];//new Color(x + m, m, c + m);
    else return [[GameColor alloc] initWithRGBA:c + m g:m b:x + m a:1.0];//new Color(c + m, m, x + m);
}
@end
