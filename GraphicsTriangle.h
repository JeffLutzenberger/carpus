//
//  GraphicsTriangle.h
//  carpus
//
//  Created by Jeff Lutzenberger on 4/26/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Vector2D.h"
#import "GameColor.h"

@interface GraphicsTriangle : NSObject

@property Vector2D* p1;
@property Vector2D* p2;
@property Vector2D* p3;
@property BOOL fanEffect;
//@property GameColor* color;

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3;

- (void) updateVertexBuffer:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3;

- (void)setColor:(float[4])color;

- (void) draw;

@end
