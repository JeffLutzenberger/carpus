//
//  Obstacle.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Rectangle.h"
#import "Camera.h"

@interface Obstacle : Rectangle

@property float reaction;

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta color:(ETColor)color;

- (void) draw:(Camera*)camera;

@end
