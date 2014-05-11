//
//  Simulation.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Simulation.h"
#import "Obstacle.h"
#import "Influencer.h"
#import "Portal.h"
#import "Source.h"
#import "Sink.h"
#import "Bucket.h"

typedef enum {
    TOUCH_ADDS_INFLUENCER,
    TOUCH_IS_INFLUENCER,
    TOUCH_MOVES_INFLUENCER
} ETTouchScheme;

@implementation Simulation {
    ETTouchScheme touchScheme;
    Rectangle* interactionObject;
    NSString* currentPath;
    BOOL checkingPath;
    BOOL pathCheckStarted;
    Particle* pathParticle;
    
    //length of path measurements
    float pathSampleRate;
    float pathSampleDt;
    float pathSamples;
    float pathLength;
}

- (id) init {
    self = [super init];
    if (self) {
        self.maxParticleAge = 7500; //ms
        self.maxParticleSpeed = 2;
        self.missed = 0;
        self.caught = 0;
        self.maxLength = 0.0;
        
        pathSampleRate = 2000;
        pathSampleDt = 0.0;
        pathSamples = 1.0;
        pathLength = 0.0;
        
        self.influencers = [[NSMutableArray alloc] init];
        self.obstacles = [[NSMutableArray alloc] init];
        self.portals = [[NSMutableArray alloc] init];
        self.buckets = [[NSMutableArray alloc] init];
        self.sources = [[NSMutableArray alloc] init];
        self.sinks = [[NSMutableArray alloc] init];
        self.touches = [[NSMutableArray alloc] init];
        self.touchObjects = [[NSMutableArray alloc] init];
        touchScheme = TOUCH_MOVES_INFLUENCER;
        self.paths = [[NSMutableArray alloc] init];
        currentPath = @"";
        checkingPath = NO;
        pathCheckStarted = NO;
        pathParticle = nil;
        
        //self.backgroundGrid = [[BackgroundGrid alloc] initWithSizeAndSpacing:768.0 h:1024.0 gridx:768.0 / 32.0 gridy:1024.0 / 32.0];
    }
    return self;
}

- (void) update:(float)dt {

    //[self.backgroundGrid update:dt];
    
    pathSampleDt += dt;
    if (pathSampleDt > pathSampleRate) {
        pathSampleDt = 0.0;
        //check to see if all particles have compeleted at least one cycle
        BOOL cycleComplete = YES;
        pathSamples = 1.0;
        pathLength = 0.0;
        for (Sink *s in self.sinks) {
            for (Particle *p in s.particles) {
                if (p.completeCycles <= 0) {
                    cycleComplete = NO;
                    break;
                } else {
                    pathLength += sqrt(p.length);
                    pathSamples += 1.0;
                }
            }
        }
        if (cycleComplete) {
            pathLength = pathLength / pathSamples;
        }
        NSLog(@"path length: %0.1f", pathLength);
    }
    for (Source* s in self.sources) {
        [s update:dt];
    }
    
    for (Sink* s in self.sinks) {
        [s update:dt];
        //f = -o.force;
        //f = f < 0 ? f * 0.25 : f;
        //[self.backgroundGrid applyExplosiveForce:s.x y:s.y force:1.0 radius:s.radius * 10];
    }
    
    //for (Influencer* i in self.influencers) {
    //    //[self.backgroundGrid applyExplosiveForce:i.x y:i.y force:1.0 radius:i.radius * 10];
    //}

    [self moveParticles:dt];
}

- (void) singleTap:(CGPoint)pos {
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //check to see if we're over an influencr
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerTouchHit:p]) {
                return;
            }
        }
        //add a new influencer
        Influencer* influencer = [[Influencer alloc] initWithPositionSizeAndForce:pos.x y:pos.y radius:15 force:5];
        influencer.enabled = true;
        //[self.touches addObject:touch];
        [self.influencers addObject:influencer];
        return;
    }
}

- (BOOL) doubleTap:(CGPoint)pos {
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //delete the influencer if this was a double tap
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerTouchHit:p]) {
                [self.influencers removeObject:influencer];
                return YES;
            }
        }
    }
    return NO;
}

- (void) panGesture:(CGPoint)pos {
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //check to see if we're over an influencer
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerTouchHit:p]) {
                influencer.x = pos.x;
                influencer.y = pos.y;
                return;
            }
        }
    }
    //is this a grabber
    for(Sink* s in self.sinks) {
        /*if ([s hitGrabber:p]) {
         s.grabberSelected = true;
         Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
         [s moveGrabber:v];
         return;
         }*/
        if (s.selected && s.grabber.selected) {
            //s.grabberSelected = true;
            Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
            [s moveGrabber:v];
            return;
        }
    }
}

- (BOOL) hitInteractable:(CGPoint)pos {
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    //is this a grabber
    for(Sink* s in self.sinks) {
        if ([s hitGrabber:p]) {
            interactionObject = s;
            s.selected = YES;
            s.grabber.selected = YES;
            s.grabberSelected = true;
            return YES;
        }
    }
    
    //hit an existing influencer
    for(Influencer* influencer in self.influencers) {
        p.radius = influencer.influenceRadius;
        if([influencer influencerTouchHit:p]) {
            interactionObject = influencer;
            influencer.selected = YES;
            return YES;
        }
    }
    
    return NO;

}

- (BOOL) touchBegan:(UITouch*)touch {
    //touch event can be either a grabber or an interactable object...
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    //is this a grabber
    for(Sink* s in self.sinks) {
        if ([s hitGrabber:p]) {
            interactionObject = s;
            s.selected = YES;
            s.grabber.selected = YES;
            s.grabberSelected = true;
            return YES;
        }
    }
    
    if (touchScheme == TOUCH_MOVES_INFLUENCER) {
        //check to see if we're over an influencer
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerHit:p]) {
                influencer.selected = YES;
                return YES;
            }
        }
    } else if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //check to see if we're over an influencr
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerHit:p]) {
                return YES;
            }
        }
        //add a new influencer
        Influencer* influencer = [[Influencer alloc] initWithPositionSizeAndForce:pos.x y:pos.y radius:15 force:5];
        influencer.enabled = true;
        //[self.touches addObject:touch];
        [self.influencers addObject:influencer];
        return YES;

    } else if (touchScheme == TOUCH_IS_INFLUENCER) {
        Influencer* influencer = nil;
        [self.touches addObject:touch];
        influencer = [[Influencer alloc] initWithPositionSizeAndForce:pos.x y:pos.y radius:15 force:5];
        influencer.enabled = true;
        [self.influencers addObject:influencer];
        return YES;
    }
    
    return NO;
}

- (void) touchEnded:(UITouch*)touch {
    
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    for(Sink* s in self.sinks) {
        if (s.selected) {
            s.grabberSelected = NO;
            s.grabber.selected = NO;
            s.selected = NO;
            interactionObject = nil;
        }
    }

    if (touchScheme == TOUCH_MOVES_INFLUENCER) {
        for(Influencer* i in self.influencers) {
            i.selected = NO;
        }
    } else if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //delete the influencer if this was a double tap
        if (touch.tapCount >= 2) {
            for(Influencer* influencer in self.influencers) {
                p.radius = influencer.influenceRadius;
                if([influencer influencerTouchHit:p]) {
                    [self.influencers removeObject:influencer];
                    return;
                }
            }
        }
    
    } else if (touchScheme == TOUCH_IS_INFLUENCER) {
        NSUInteger index = [self.touches indexOfObject:touch];
        if (index != NSNotFound) {
            id obj = [self.influencers objectAtIndex:index];
            if (obj) {
                [self.touches removeObjectAtIndex:index];
                [self.influencers removeObjectAtIndex:index];
                return;
            }
        }
    }
    
    for(Sink* s in self.sinks) {
        if (s.selected) {
            s.grabberSelected = NO;
            s.grabber.selected = NO;
            s.selected = NO;
            interactionObject = nil;
        }
    }
    
}

- (void) touchMoved:(UITouch*)touch {
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    
    if (touchScheme == TOUCH_MOVES_INFLUENCER) {
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if(influencer.selected) {
                if(influencer.dragDirection == OMNI || influencer.dragDirection == EASTWEST) {
                    influencer.x = pos.x;
                }
                if(influencer.dragDirection == OMNI || influencer.dragDirection == NORTHSOUTH) {
                    influencer.y = pos.y;
                }
                return;
            }
        }
    }
    if (touchScheme == TOUCH_ADDS_INFLUENCER) {
        //check to see if we're over an influencer
        for(Influencer* influencer in self.influencers) {
            p.radius = influencer.influenceRadius;
            if([influencer influencerTouchHit:p]) {
                influencer.x = pos.x;
                influencer.y = pos.y;
                return;
            }
        }
    
    } else if (touchScheme == TOUCH_IS_INFLUENCER) {
        NSUInteger index = [self.touches indexOfObject:touch];
        if (index != NSNotFound) {
            id obj = [self.influencers objectAtIndex:index];
            if (obj && [obj class] == [Influencer class]) {
                Influencer* influencer = (Influencer*)obj;
                influencer.x = pos.x;
                influencer.y = pos.y;
                return;
            }
        }
    }
    
    for(Sink* s in self.sinks) {
        /*if ([s hitGrabber:p]) {
         s.grabberSelected = true;
         Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
         [s moveGrabber:v];
         return;
         }*/
        if (s.selected && s.grabber.selected) {
            //s.grabberSelected = true;
            Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
            [s moveGrabber:v];
            return;
        }
    }
}

- (void) moveParticles:(float)dt {
    for (Source* s in self.sources) {
        for (int j = 0; j < [s.particles count]; j += 1) {
            Particle* p = [s.particles objectAtIndex:j];
            [self moveParticle:p dt:dt];
        }
    }
    
    for (Sink* s in self.sinks) {
        for (int j = 0; j < [s.particles count]; j += 1) {
            Particle* p = [s.particles objectAtIndex:j];
            [self moveParticle:p dt:dt];
        }
    }
}

- (void) moveParticle:(Particle*)particle dt:(float)dt {
    
    [particle move:dt];
    
    [particle trace];
    
    [self hitInfluencers:particle dt:dt];
 
    [self hitSinks:particle dt:dt];
 
    [self hitObstacles:particle dt:dt];
    
    [self hitBuckets:particle dt:dt];

    [self hitPortals:particle dt:dt];
    
    [self hitGridWalls:particle dt:dt];
    
    //for(Sink* s in self.touchObjects) {
    //    [s influence:particle dt:dt maxSpeed:[self maxParticleSpeed]];
    //}
    
    if (particle.age > self.maxParticleAge) {
        self.missed += 1;
        particle.completeCycles = 0;
        [particle.source recycleParticle:particle];
    }

}

- (void) hitObstacles:(Particle*)p dt:(float)dt {
    for (Obstacle* o in self.obstacles) {
        if (!o.enabled) {
            continue;
        }
        
        Vector2D* h = [o hit:p];
        if (h) {
            if (o.reaction > 0) {
                [p bounce:h];
                [p move:dt];
                [p trace];
            } else {
                [p.source recycleParticle:p];
            }
            [p move:dt];
        }
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

- (void) hitInfluencers:(Particle*)p dt:(float)dt {
    for (Influencer* i in self.influencers) {
        if (![i enabled]) {
            continue;
        }
        if ([i localizeInfluence] /*&& ![s.grid sameTile:s particle:p]*/) {
            continue;
        }
        if ([i influenceBound] /*&& ![s insideInfluenceRing:p]*/) {
            continue;
        }
        
        if (i.deflectParticles) {
            Vector2D* n = [i bounce:p];
            if (n) {
                //move the particle outside the circle...
                [p bounce:n];
                [p move:dt];
                [p trace];
            }
        }
        
        [i influence:p dt:dt maxSpeed:[self maxParticleSpeed]];
    }
}

- (void) hitPortals:(Particle*)p dt:(float)dt {
    for (Portal* portal in self.portals) {
        if (!portal.enabled) {
            continue;
        }
        if ([portal hit:p]) {
            return;
        }
    }
    return;
}

- (void) hitSinks:(Particle*)p dt:(float)dt {
    for (Sink* s in self.sinks) {
        if (![s enabled]) {
            continue;
        }
        if ([s localizeInfluence] /*&& ![s.grid sameTile:s particle:p]*/) {
            continue;
        }
        if ([s influenceBound] /*&& ![s insideInfluenceRing:p]*/) {
            continue;
        }
        
        if (s.deflectsParticles && [p color] != [s inColor]) {
            Vector2D* n = [p cicleLineCollision:s.x cy:s.y r:s.influenceRadius + 8];
            //Vector2D* n = [s bounce:p];
            if (n) {
                //move the particle outside the circle...
                [p bounce:n];
                [p move:dt];
                [p trace];
                return;
            }
        }
        
        if ([p color] == [s inColor] && s.isSource && [s sinkHit:p] ) {
            if (s.isSource) {
                //lengthSamples += 1.0;
                //self.maxLength += p.length
                p.completeCycles += 1;
                //pathSamples += 1.0;
                //pathCummulativeLength += p.length;
                [s recycleParticle:p];

                //p.brightness += 0.1;
                p.age = 0;
                if (checkingPath && p == pathParticle) {
                    //wait until the particle gets to our "origin" sink
                    if (!pathCheckStarted && s == [self.sinks objectAtIndex:0]) {
                        pathCheckStarted = YES;
                        //start the path string -> S0 (ie. sink 0)
                    }
                }
                return;
            } else {
                p.completeCycles += 1;
                //pathSamples += 1.0;
                //pathCummulativeLength += p.length;
                [p.source recycleParticle:p];
                self.caught += 1;
                //NSLog(@"%d", self.caught);
                return;
            }
        }
        
        //Note: removing sink's ability to influence
        [s influence:p dt:dt maxSpeed:[self maxParticleSpeed]];
        
        if ([s insideInfluenceRing:p]) {
            [p setParticleColor:s.color];
        }
    }
};

- (void) hitGridWalls:(Particle*)p dt:(float)dt {
    //where is the particle...
    //i.e. get the grid rect that the particle is in
    Vector2D* v = [self.gameGrid hit:p];
    if (v) {
        [p bounce:v];
        [p move:dt];
        [p trace];
    }
}

- (void) startPathCheck {
    //clear current path and start following a particle
    currentPath = @"";
    checkingPath = YES;
    Source* s = [self.sources objectAtIndex:0];
    pathParticle = [s.particles objectAtIndex:0];
}


- (void) draw:(Camera*)camera {

    [self drawParticles:camera];

    [self drawBuckets:camera];
    
    [self drawInfluencers:camera];
    
    [self drawObstacles:camera];
    
    [self drawPortals:camera];
    
    [self drawSources:camera];
    
    [self drawSinks:camera];
    
    [self.gameGrid draw:camera];
    
    //[self.backgroundGrid draw:camera];
    
}

- (void) drawParticles:(Camera*)camera {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }
    
    for (Sink *s in self.sinks) {
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }
    /*for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }*/
}

- (void) drawBuckets:(Camera*)camera {
    for (Bucket* b in self.buckets) {
        [b draw:camera];
    }
}

- (void) drawInfluencers:(Camera*)camera {
    for (Influencer* i in self.influencers) {
        [i draw:camera];
    }
}

- (void) drawObstacles:(Camera*)camera {
    for (Obstacle* o in self.obstacles) {
        [o draw:camera];
    }
}

- (void) drawPortals:(Camera*)camera {
    for (Portal* p in self.portals) {
        [p draw:camera];
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

- (void) drawShaderParticles:(Camera*)camera {
    for (Sink* s in self.sinks) {
        [s.shaderParticleSystem draw:camera];
    }
}

@end
