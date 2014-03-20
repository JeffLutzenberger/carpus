//
//  GraphicsQuad.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/13/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Vector2D.h"
#import "GameColor.h"

@interface GraphicsQuad : NSObject

@property Vector2D* p1;
@property Vector2D* p2;
@property Vector2D* p3;
@property Vector2D* p4;
@property GameColor* color;

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 p4:(Vector2D*)p4;

- (void) updateVertexBuffer:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 p4:(Vector2D*)p4;

- (void) draw;

@end
