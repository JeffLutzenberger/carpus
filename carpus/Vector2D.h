//
//  Vector2D.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vector2D : NSObject

@property float x;
@property float y;

- (id) initWithXY:(float)x y:(float)y;

- (id) initWithVector2D:(Vector2D*)v;

+ (float) squaredLength:(Vector2D*)v;

+ (float) length:(Vector2D*)v;

+ (Vector2D*) scalarMultiply:(Vector2D*)v num:(float)num;

+ (Vector2D*) add:(Vector2D*)v1 v2:(Vector2D*)v2;

+ (Vector2D*) subtract:(Vector2D*)v1 v2:(Vector2D*)v2;

+ (Vector2D*) normalize:(Vector2D*)v;

+ (float) dot:(Vector2D*)v1 v2:(Vector2D*)v2;

+ (Vector2D*) rotate:(Vector2D*)v theta:(float)theta;

+ (Vector2D*) rotateXY:(float)x y:(float)y theta:(float)theta;

+ (NSString*) toString:(Vector2D*)v;

@end
