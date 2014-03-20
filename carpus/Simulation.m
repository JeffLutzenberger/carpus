//
//  Simulation.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Simulation.h"
#import "Source.h"
#import "Sink.h"
#import "Bucket.h"

@implementation Simulation {
}

- (id) init {
    self = [super init];
    if (self) {
        self.maxParticleAge = 5000; //ms
        self.maxParticleSpeed = 2;
        self.missed = 0;
        self.caught = 0;
        self.buckets = [[NSMutableArray alloc] init];
        self.sources = [[NSMutableArray alloc] init];
        self.sinks = [[NSMutableArray alloc] init];
        //self.touchInfluencers = [[NSMutableArray alloc] init];
        self.touches = [[NSMutableArray alloc] init];
        self.touchObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) update:(float)dt {

    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        [s update:dt];
    }
    
    for (Sink* s in self.sinks) {
        [s update:dt];
        //f = -o.force;
        //f = f < 0 ? f * 0.25 : f;
        //this.backgroundGrid.applyExplosiveForce(f * 5, new Vector(o.x, o.y), o.radius * 10);
    }

    [self moveParticles:dt];
}

- (void) touchBegan:(UITouch*)touch {
    //touch event can be either a grabber or an interactable object...
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:nil];
    //1. is this a grabber
    for(Sink* s in self.sinks) {
        //if s.hit touch event then this touch event is a grabber move
        if ([s hitGrabber:p]) {
            s.grabberSelected = true;
            [self.touches addObject:touch];
            [self.touchObjects addObject:s];
            NSLog(@"hit grabber");
            return;
        }
    }
    Sink* influencer = nil;
    [self.touches addObject:touch];
    influencer = [[Sink alloc] initWithPositionSizeForceAndSpeed:pos.x y:pos.y radius:15 force:5 speed:5];
    influencer.enabled = true;
    [self.touchObjects addObject:influencer];
    return;
}

- (void) touchEnded:(UITouch*)touch {
    NSUInteger index = [self.touches indexOfObject:touch];
    id obj = [self.touchObjects objectAtIndex:index];
    Sink* influencer = (Sink*)obj;
    influencer.grabberSelected = false;
    [self.touches removeObjectAtIndex:index];
    [self.touchObjects removeObjectAtIndex:index];
    
}

- (void) touchMoved:(UITouch*)touch {
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    NSUInteger index = [self.touches indexOfObject:touch];
    id obj = [self.touchObjects objectAtIndex:index];
    Sink* influencer = (Sink*)obj;
    if(influencer.grabberSelected) {
        NSLog(@"Move grabber...");
        Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
        [influencer moveGrabber:v];
    } else {
        influencer.x = pos.x;
        influencer.y = pos.y;
    }
}

- (void) moveParticles:(float)dt {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j += 1) {
            Particle* p = [s.particles objectAtIndex:j];
            [self moveParticle:p dt:dt];
        }
    }
}

- (void) moveParticle:(Particle*)particle dt:(float)dt {
    
    [particle move:dt];
    
    [particle trace];
    
    [self hitSinks:particle dt:dt];
    
    [self hitBuckets:particle dt:dt];

    for(Sink* s in self.touchObjects) {
        [s influence:particle dt:dt maxSpeed:[self maxParticleSpeed]];
    }
    
    if (particle.age > self.maxParticleAge) {
        self.missed += 1;
        [particle.source recycleParticle:particle];
    }

}

- (void) hitBuckets:(Particle*)p dt:(float)dt {
    for (Bucket* b in self.buckets) {
        if (!b.enabled) {
            continue;
        }
        Vector2D* h = [b hit:p];
        if (h) {
            [p move:dt];
        }
    }
}

- (void) hitSinks:(Particle*)p dt:(float)dt {
    for (int i = 0; i < [self.sinks count]; i++) {
        Sink* s = [self.sinks objectAtIndex:i];
        if (![s enabled]) {
            continue;
        }
        if ([s localizeInfluence] /*&& ![s.grid sameTile:s particle:p]*/) {
            continue;
        }
        if ([s influenceBound] /*&& ![s insideInfluenceRing:p]*/) {
            continue;
        }
                  
        //this is where we would check the color of the particle
        /*if ([p color] != [s inColor]) {
            Vector2D* n = [s bounce:p];
            if (n) {
                //move the particle outside the circle...
                p.bounce(n);
                p.move(dt);
                return true;
            }
        }*/
        
        if ([s sinkHit:p]) {
            if (s.isSource && [s checkIsFull]) {
                [s recycleParticle:p];
                //p.brightness += 0.1;
                p.age = 0;
                return /*false*/;
            } else {
                [p.source recycleParticle:p];
                self.caught += 1;
                //NSLog(@"%d", self.caught);
                return /*true*/;
            }
        }
        [s influence:p dt:dt maxSpeed:[self maxParticleSpeed]];
        //s.influence(p, dt, this.maxParticleSpeed);
    }
};

- (void) draw:(Camera*)camera {

    [self drawParticles:camera];

    [self drawBuckets:camera];
    
    [self drawSources:camera];
    
    [self drawSinks:camera];
    
}

- (void) drawParticles:(Camera*)camera {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }
}

- (void) drawBuckets:(Camera*)camera {
    for (Bucket* b in self.buckets) {
        [b draw:camera];
    }
}

- (void) drawSources:(Camera*)camera {
    for (Source* s in self.sources) {
        [s draw:camera];
    }
}

- (void) drawSinks:(Camera*)camera {
    for (Sink* s in self.sinks) {
        [s draw:camera];
    }
}

@end
