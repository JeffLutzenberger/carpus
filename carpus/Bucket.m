//
//  Bucket.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Bucket.h"
#import "Source.h"
#import "GraphicsRectangle.h"

@implementation Bucket {
    GraphicsRectangle* _rectangle;
}

- (id)initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta {
    self = [super initWithPositionAndSize:x y:y w:w h:h theta:theta];
    if (self) {
        self.caught = 0;
        self.maxFill = 0;
        self.level = 0;
        self.hasBottom = true;
        self.inColor = RED;
        self.outColor = RED;
        const float* c = gGameColors[self.inColor];
        float color[4] ={c[0], c[1], c[2], 1.0};
        _rectangle = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:5 color:color];
        
    }
    return self;
}

- (void)reset {
    self.caught = 0;
    self.level = 0;
}

- (BOOL)checkIsFull {
    return self.caught >= self.maxFill;
}

- (void)update:(float)dt {
    
}

- (Vector2D*)hit:(Particle*)p {
    if (self.hasBottom) {
        if( [p lineCollision:self.p1 p2:self.p2]) {
            //count this as being caught
            //add score and recycle the particle
            if (true /*p.color == _inColor*/) {
                Source* s = (Source*)(p.source);
                [s recycleParticle:p];
                self.caught += 1;
                return nil;
            } else {
                return self.n1;
            }
        }
        if( [p lineCollision:self.p2 p2:self.p3]) {
            [p bounce:self.n2];
            return self.n2;
        }
        if( [p lineCollision:self.p3 p2:self.p4]) {
            [p bounce:self.n3];
            return self.n3;
        }
        if( [p lineCollision:self.p4 p2:self.p1]) {
            [p bounce:self.n4];
            return self.n4;
        }
    } else if([p lineCollision:self.p5 p2:self.p6]) {
        if ([Vector2D dot:p.vel v2:self.n1]) {
            //going from out color to in color...
            if (p.color != RED/*_outColor*/) {
                //colors don't match so don't let the particle through
                [p bounce:self.n3];
                return self.n3;
            } else {
                p.color = RED;//_inColor;
                [p redirect:self.n1];
                return self.n1;
            }
        } else {
            if (p.color != RED/*_inColor*/) {
                //colors don't match so don't let the particle through
                [p bounce:self.n1];
                return self.n1;
            } else {
                p.color = RED;//_outColor;
                [p redirect:self.n3];
                return self.n3;
            }
        }
    }
    return nil;
}

- (void) draw:(Camera*)camera {
    [camera translateObject:self.x y:self.y z:-0.5];
    [_rectangle draw];
}

@end
