//
//  Obstacle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Obstacle.h"
#import "GraphicsRectangle.h"

@implementation Obstacle {
    GraphicsRectangle* rect1;
    GraphicsRectangle* rect2;
}

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta color:(ETColor)color {
    self = [super initWithPositionAndSize:x y:y w:w h:h theta:theta color:color];
    if (self) {
        self.reaction = 1.0;
        const float* c = gGameColors[self.color];
        float color1[] = {c[0], c[1], c[2], 1.0};
        float color2[] = {1.0, 1.0, 1.0, 0.5};
        rect1 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:self.theta lineWidth:5 color:color1];
        rect2 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:self.theta lineWidth:2 color:color2];
    }
    return self;
}

- (void) draw:(Camera*)camera {
    [camera translateObject:self.x y:self.y z:-0.5];
    [rect1 draw];
    [rect2 draw];
}

@end
