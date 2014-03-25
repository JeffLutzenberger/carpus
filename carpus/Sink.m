//
//  Sink.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Sink.h"
#import "ParticleSystem.h"
#import "GraphicsCircle.h"
#import "GraphicsCircleOutline.h"
#import "GraphicsArc.h"

@implementation Sink {
    GraphicsCircleOutline* influenceCircle1;
    GraphicsCircleOutline* influenceCircle2;
    GraphicsCircle* gradient1;
    GraphicsCircle* gradient2;
    GraphicsCircle* innerCircle1;
    GraphicsCircle* innerCircle2;
    GraphicsArc* arc;
    GraphicsCircle* grabberCircle1;
    GraphicsCircleOutline* grabberCircle2;
    GraphicsCircle* grabberCircle3;
    GraphicsCircleOutline* nozzelCircle;
    float grabberFadeDt;
    float grabberFadeLength;
    float pulseDt;
    float pulseRate;
    float flashDt;
    float flashLength;
    float ringPulseDt;
    float ringPulseLength;
    ParticleSystem* particleSystem;
    ParticleSystem* spiralParticleSystem;
}


- (id) initWithPositionSizeForceAndSpeed:(float)x y:(float)y radius:(float)radius force:(float)force speed:(float)speed {
    self = [super initWithPositionAndSize:x y:y w:radius h:radius theta:0 color:GREEN];
    if (self) {
        self.speed = speed;
        self.force = force;
        self.radius = radius;
        self.influenceRadius = radius * 5;
        self.influenceEquation = 1;
        self.localizeInfluence = false;
        self.isSource = true;
        self.maxFill = 100;
        self.inColor = GREEN;
        self.outColor = GREEN;
        self.grabber = [[Rectangle alloc] initWithPositionAndSize:x + cos(self.theta) * self.influenceRadius y:y + sin(self.theta) * self.influenceRadius w:40 h:40 theta:0 color:GREEN];
        grabberFadeDt = 0;
        grabberFadeLength = 0;
        pulseDt = 0;
        pulseRate = 0;
        flashDt = 0;
        flashLength = 0;
        ringPulseDt = 0;
        ringPulseLength = 0;
        particleSystem = [[ParticleSystem alloc] initWithCoordsAndCapacity:self.x y:self.y capacity:300];
        spiralParticleSystem = [[ParticleSystem alloc] initWithCoordsAndCapacity:self.x y:self.y capacity:300];
        //[spiralParticleSystem burst:self.x y:self.y burstRadius:100 speed:0.005 accel:-0.0009 nparticles:10 lifetime:50000];
        
        const float* c = gGameColors[self.inColor];
        float color1[] = {c[0], c[1], c[2], 0.8};
        float color2[] = {c[0], c[1], c[2], 0.25};
        float color3[] = {c[0], c[1], c[2], 0.0};
        float color4[] = {c[0], c[1], c[2], 0.25};
        float color5[] = {1.0, 1.0, 1.0, 0.7};
        float color6[] = {1.0, 1.0, 1.0, 0.0};
        gradient1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                           y:0
                                                                      radius:radius * 4
                                                                   //lineWidth:radius
                                                                  innerColor:color2
                                                                  outerColor:color3];
        
        influenceCircle1 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_influenceRadius + 7
                                                                          lineWidth:3
                                                                         innerColor:color1
                                                                         outerColor:color1];
        
        influenceCircle2 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_influenceRadius - 7
                                                                          lineWidth:3
                                                                         innerColor:color1
                                                                         outerColor:color1];
        
        innerCircle1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                       y:0
                                                                  radius:radius * 1.5
                                                              innerColor:color1
                                                              outerColor:color3];
        
        innerCircle2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                       y:0
                                                                  radius:radius * 0.5
                                                              innerColor:color5
                                                              outerColor:color4];
        
        gradient2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                    y:0
                                                                radius:radius * 1.05
                                                                //lineWidth:radius * 0.25
                                                                innerColor:color5
                                                                outerColor:color6];
        arc = [[GraphicsArc alloc] initWithPositionAndRadius:0 y:0 radius:self.influenceRadius lineWidth:14 startTheta:0 endTheta:3.14 * 0.5 color:color2];
        
        const float* cout = gGameColors[self.outColor];
        float grabberColor1[] = {cout[0], cout[1], cout[2], 0.8};
        float grabberColor2[] = {cout[0], cout[1], cout[2], 0.0};
        float grabberColor3[] = {cout[0], cout[1], cout[2], 0.25};
        float grabberColor4[] = {1.0, 1.0, 1.0, 0.7};
        float grabberColor5[] = {1.0, 1.0, 1.0, 0.0};
        float grabberColor6[] = {cout[0], cout[1], cout[2], 1.0};
        
        grabberCircle1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0 y:0 radius:_radius innerColor:grabberColor1 outerColor:grabberColor2];
        
        grabberCircle2 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0 y:0 radius:_radius lineWidth:_radius innerColor:grabberColor3 outerColor:grabberColor2];
        
        grabberCircle3 = [[GraphicsCircle alloc] initWithPositionAndRadius:0 y:0 radius:_radius * 0.5 innerColor:grabberColor4 outerColor:grabberColor5];
        
        nozzelCircle = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_radius * 0.8
                                                                          lineWidth:1
                                                                         innerColor:grabberColor6
                                                                         outerColor:grabberColor6];
        
    }
    return self;
}

- (void) setMyRadius:(float)radius {
    self.radius = radius;
    self.influenceRadius = radius * 5;
    self.w = radius;
    self.h = radius;
};

- (void) setSinkColor:(ETColor)inColor outColor:(ETColor)outColor {
    self.inColor = inColor;
    self.outColor = outColor;
    
    const float* c = gGameColors[self.inColor];
    float color1[] = {c[0], c[1], c[2], 0.8};
    float color2[] = {c[0], c[1], c[2], 0.25};
    float color3[] = {c[0], c[1], c[2], 0.0};
    float color4[] = {c[0], c[1], c[2], 0.25};
    float color5[] = {1.0, 1.0, 1.0, 0.7};
    float color6[] = {1.0, 1.0, 1.0, 0.0};
    
    [gradient1 setColor:color2 outerColor:color3];
    [gradient1 updateCircle];
    [innerCircle1 setColor:color1 outerColor:color3];
    [innerCircle1 updateCircle];
    [innerCircle2 setColor:color5 outerColor:color4];
    [innerCircle2 updateCircle];
    [gradient2 setColor:color5 outerColor:color6];
    [gradient2 updateCircle];
    
    [influenceCircle1 setColor:color1 outerColor:color1];
    [influenceCircle1 updateCircle];
    [influenceCircle2 setColor:color1 outerColor:color1];
    [influenceCircle2 updateCircle];
    
    [arc setColor:color2];
    [arc updateArc:arc.endTheta];
    
    const float* cout = gGameColors[self.outColor];
    float grabberColor1[] = {cout[0], cout[1], cout[2], 0.8};
    float grabberColor2[] = {cout[0], cout[1], cout[2], 0.0};
    float grabberColor3[] = {cout[0], cout[1], cout[2], 0.25};
    float grabberColor4[] = {1.0, 1.0, 1.0, 0.7};
    float grabberColor5[] = {1.0, 1.0, 1.0, 0.0};
    
    [grabberCircle1 setColor:grabberColor1 outerColor:grabberColor2];
    [grabberCircle1 updateCircle];
    [grabberCircle2 setColor:grabberColor3 outerColor:grabberColor2];
    [grabberCircle2 updateCircle];
    [grabberCircle3 setColor:grabberColor4 outerColor:grabberColor5];
    [grabberCircle3 updateCircle];
    
}

- (BOOL) checkIsFull {
    return (self.caught >= self.maxFill);
}

- (void) recycleParticle:(Particle*)p {
    float dt = (float)drand48() * 0.2 - 0.1;
    p.x = self.x + cos(self.theta + dt) * (self.influenceRadius + 10);
    p.y = self.y + sin(self.theta + dt) * (self.influenceRadius + 10);
    p.vel.x = cos(self.theta) * self.speed;
    p.vel.y = sin(self.theta) * self.speed;
    [p setParticleColor:self.outColor];
}

- (void) influence:(Particle*)p dt:(float)dt maxSpeed:(float)maxSpeed {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:(self.x - p.x) y:(self.y - p.y)];
    float r2 = MAX([Vector2D squaredLength:v2], self.radius * self.radius);
    float res = 0;
    if (self.influenceEquation == 0) {
        // 1/r^2
        res = self.force * 100 / (r2 + 10 * 10);
    } else if (self.influenceEquation == 1) {
        // 1/r smooths out influence
        res = self.force / sqrt(r2 + 10 * 10);
    } else if (self.influenceEquation == 2) {
        if (r2 < self.influenceRadius * self.influenceRadius) {
            res = maxSpeed;
        }
    }
    res *= dt * 0.08;
    v2 =[Vector2D normalize:v2];
    v2.x *= res;
    v2.y *= res;
    p.vel.x += v2.x;
    p.vel.y += v2.y;
};

- (BOOL) sinkHit:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d2 = [Vector2D squaredLength:v2];
    BOOL hit = NO;
    hit = (d2 <= 3 * self.radius * self.radius);
    if (hit && ![self checkIsFull]) {
        self.caught += 1;
        //[particleSystem burst:self.x y:self.y burstRadius:50 speed:0.5 accel:-0.0009 nparticles:10 lifetime:500];
        
    }
    return hit;
};

- (BOOL) hitGrabber:(Particle*)p {
    return [self.grabber bbHit:p];
};

- (void) moveGrabber:(Vector2D*)v {
    Vector2D* v1 = [[Vector2D alloc] initWithXY:v.x - self.x y:v.y - self.y];
    self.theta = atan(v1.y / v1.x);
    if (v1.x < 0) {
        self.theta -= M_PI;
    }
    float x = self.x + self.influenceRadius * cos(self.theta);
    float y = self.y + self.influenceRadius * sin(self.theta);
    self.grabber.x = x;
    self.grabber.y = y;
};

- (BOOL) insideInfluenceRing:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d2 = [Vector2D squaredLength:v2];
    return (d2 <= 2 * self.influenceRadius * self.influenceRadius);
};

- (Vector2D*) trap:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d1 = sqrtf([Vector2D squaredLength:v2]);
    float r1 = self.influenceRadius;
    float r2 = r1 - 5;
    if (d1 > r1) {
        //get the normal vector at this point
        v2 = [Vector2D normalize:v2];
        p.x = self.x - r2 * v2.x;
        p.y = self.y - r2 * v2.y;
        return v2;
    }
    return nil;
}

- (Vector2D*) bounce:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d1 = sqrtf([Vector2D squaredLength:v2]);
    float r1 = self.influenceRadius + 10;
    float r2 = r1 + 10;
    if (d1 < r1) {
        //get the normal vector at this point
        //n = new Vector(p.x - this.x, p.y - this.y);
        v2 = [Vector2D normalize:v2];
        p.x = self.x - r2 * v2.x;
        p.y = self.y - r2 * v2.y;
        //this.spark(p.x, p.y);
        return v2;
    }
    return nil;
}

- (void) update:(float)dt {
    
    if (self.isSource && [self checkIsFull]) {
        //start grabber fade
        if (grabberFadeDt < grabberFadeLength) {
            grabberFadeDt += dt;
        } else {
            grabberFadeDt = grabberFadeLength;
        }
    }
    
    pulseDt += dt;
    
    if (pulseDt >= pulseRate) {
        pulseDt = 0;
        flashDt = 0;
    }
    
    if (flashDt >= 0 && flashDt < flashLength) {
        flashDt += dt;
    }
    
    ringPulseDt += dt;
    if (ringPulseDt > ringPulseLength) {
        ringPulseDt = 0;
    }
    //this.sparks.update(dt);
    
    [particleSystem update:dt];
    [spiralParticleSystem spiralUpdate:dt s:[self position]];
}

- (void) draw:(Camera*)camera {
    float f = (float)self.caught / (float)self.maxFill * M_PI * 2;
    //NSLog(@"%d", self.caught);
    [arc updateArc:f];

    [particleSystem draw:camera];
    [spiralParticleSystem draw:camera];
    
    [camera translateObject:self.x y:self.y z:-1];
    [gradient1 draw];
    [influenceCircle1 draw];
    [influenceCircle2 draw];
    [arc draw];
    [camera translateObject:self.x y:self.y z:-0.5];
    [innerCircle1 draw];
    //[camera translateObject:self.x y:self.y z:-0.4];
    [innerCircle2 draw];
    //[camera translateObject:self.x y:self.y z:-0.3];
    [gradient2 draw];
    
    if (self.isSource) {
        [camera translateObject:self.grabber.x y:self.grabber.y z:-0.25];
        [grabberCircle1 draw];
        [camera translateObject:self.grabber.x y:self.grabber.y z:-0.3];
        [grabberCircle2 draw];
        [camera translateObject:self.grabber.x y:self.grabber.y z:-0.20];
        [grabberCircle3 draw];
        [camera translateObject:self.grabber.x y:self.grabber.y z:-0.05];
        [nozzelCircle draw];
        
        //draw a pulsing outer ring to indicate this sink has been locked in
        //radius = this.radius;
        //alpha = this.grabberFadeDt / this.grabberFadeLength;
        //[self drawGrabber:camera];
        //this.drawGrabber(canvas, ParticleWorldColors[this.outColor], alpha);
    }

    
}

@end
