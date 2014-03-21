//
//  Vector2D.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Vector2D.h"

@implementation Vector2D

- (id) initWithXY:(float)x y:(float)y {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
    }
    return self;
}

+ (float) squaredLength: (Vector2D*)v {
    return (v.x * v.x) + (v.y * v.y);
}

+ (float) length: (Vector2D*)v {
    return sqrtf((v.x * v.x) + (v.y * v.y));
}

+ (Vector2D*) scalarMultiply: (Vector2D*)v num:(float)num {
    v.x *= num;
    v.y *= num;
    return [[Vector2D alloc] initWithXY:v.x * num y:v.y * num];
}

+ (Vector2D*) add:(Vector2D*)v1 v2:(Vector2D*)v2 {
    return [[Vector2D alloc] initWithXY:v1.x + v2.x y:v1.y + v2.y];
}

+ (Vector2D*) subtract:(Vector2D*)v1 v2:(Vector2D*)v2 {
    return [[Vector2D alloc] initWithXY:v1.x - v2.x y:v1.y - v2.y];
}

+ (Vector2D*) normalize: (Vector2D*)v {
    float l = [Vector2D length:v];
    //v.x /= l;
    //v.y /= l;
    //return v;
    return [[Vector2D alloc] initWithXY:v.x / l y:v.y / l];
}

+ (float) dot:(Vector2D*)v1 v2:(Vector2D*)v2 {
    return v1.x * v2.x + v1.y * v2.y;
}

+ (Vector2D*) rotateXY:(float)x y:(float)y theta:(float)theta {
    float x1 = cos(theta) * x + sin(theta) * y;
    float y1 = -sin(theta) * x + cos(theta) * y;
    return [[Vector2D alloc] initWithXY:x1 y:y1];
}

+ (Vector2D*) rotate:(Vector2D*)v theta:(float)theta {
    return [Vector2D rotateXY:v.x y:v.y theta:theta];
}

+ (NSString*) toString:(Vector2D*)v {
    return [NSString stringWithFormat:@"[%0.2f, %0.2f]", v.x, v.y];
}

@end
