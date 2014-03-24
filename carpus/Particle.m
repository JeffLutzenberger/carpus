//
//  Particle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Particle.h"
#import "GraphicsCircle.h"
#import "GraphicsTrace.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface Tracer () {
    
}

@end

@implementation Tracer

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.color = color;
        self.age = 0;
    }
    return self;
}

@end

@implementation Particle {
    NSMutableArray* trail;
    GraphicsCircle* circle1;
    GraphicsCircle* circle2;
    
    GraphicsTrace* trace1;
    GraphicsTrace* trace2;
}

- (id) initWithPositionAndColor:(float)x y:(float)y r:(float)r color:(ETColor)color {
    self = [super init];
    if(self) {
        self.x = x;
        self.y = y;
        self.prevx = x;
        self.prevy = y;
        self.radius = r;
        self.color = color;
        self.age = 0;
        self.dir = [[Vector2D alloc] initWithXY:1 y:0];
        self.vel = [[Vector2D alloc] initWithXY:0 y:0.1];
        self.numTracers = 30;
        self.traceWidth = 2;
        self.accel = -0.0003;
        trail = [[NSMutableArray alloc] initWithCapacity:self.numTracers];
        self.source = nil;
        for (int i = 0; i < self.numTracers; i++) {
            [trail insertObject:[[Tracer alloc] initWithPositionAndColor:self.x
                                                                       y:self.y
                                                                   color:self.color] atIndex:i];
        }
        const float* c = gGameColors[self.color];
        float innerColor2[] = {c[0], c[1], c[2], 1.0};
        float outerColor2[] = {c[0], c[1], c[2], 1.0};
        circle1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                  y:0
                                                             radius:self.radius
                                                         innerColor:innerColor2
                                                         outerColor:outerColor2];
        const float* white = gGameColors[WHITE];
        float innerColor3[] = {white[0], white[1], white[2], 0.7};
        float outerColor3[] = {white[0], white[1], white[2], 0.7};
        circle2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                  y:0
                                                             radius:0.5 * self.radius
                                                         innerColor:innerColor3
                                                         outerColor:outerColor3];
        
        float traceColor1[] = {c[0], c[1], c[2], 0.25};
        trace1 = [[GraphicsTrace alloc] initWithTrailAndColor:trail lineWidth:2 * self.traceWidth color:traceColor1];
        
        float traceColor2[] = {c[0], c[1], c[2], 0.25};
        trace1 = [[GraphicsTrace alloc] initWithTrailAndColor:trail lineWidth:self.traceWidth color:traceColor2];


    }
    return self;
}

- (void) move:(float)dt {
    self.prevx = self.x;
    self.prevy = self.y;
    self.x += self.vel.x * dt * 0.08;
    self.y += self.vel.y * dt * 0.08;
    //NSLog(@"%0.2f", self.vel.y);
    self.age += dt;
}

- (void) trace {
    Tracer* t;
    for (int i = 0; i < self.numTracers; i++) {
        t =[trail objectAtIndex:i];
        t.age += 1;
    }
    if (self.numTracers > 0) {
        t = [trail lastObject];
        t.x = self.x;
        t.y = self.y;
        t.age = 0;
        [trail insertObject:t atIndex:0];
        [trail removeLastObject];
    }
    
    [trace1 updateCoordinates:trail];
    
    [trace2 updateCoordinates:trail];
}

- (void) resetTrail {
    
}
- (void) update:(float)dt {
    [self move:dt];
    self.age += dt;
}

- (void)setParticleColor:(ETColor)color {
    self.color = color;
    const float* c = gGameColors[self.color];
    float c1[4] = {c[0], c[1], c[2], 1.0};
    [circle1 setColor:c1 outerColor:c1];
    [circle1 updateCircle];
    [trace1 setColor:c1];
    
    for (Tracer* t in trail) {
        [t setColor:color];
    }
}

- (void) recycle:(float)x y:(float)y vx:(float)vx vy:(float)vy color:(ETColor)color {
    Tracer* t;
    self.x = x;
    self.y = y;
    self.prevx = x;
    self.prevy = y;
    self.age = 0;
    self.vel.x = vx;
    self.vel.y = vy;
    [self setParticleColor:color];
    for (int i = 0; i < self.numTracers; i++) {
        t = [trail objectAtIndex:i];
        t.x = self.x;
        t.y = self.y;
        t.color = self.color;
    }
    
}

- (void) bounce:(Vector2D*)n {
    float dot = 2 * [Vector2D dot:self.vel v2:n];
    self.vel.x -= dot * n.x;
    self.vel.y -= dot * n.y;
    
    //self.vel.x -= 2 * self.vel.x * n.x;
    //self.vel.y -= 2 * self.vel.y * n.y;


}

- (void) redirect:(Vector2D*)n {
    float speed = [Vector2D length:self.vel];
    self.vel.x = speed * n.x;
    self.vel.y = speed * n.y;

}

- (Vector2D*) position {
    return [[Vector2D alloc] initWithXY:self.x y:self.y];
};

- (BOOL) lineCollision:(Vector2D*)p1 p2:(Vector2D*)p2 {

    float LineA1x = self.prevx;
    float LineA1y = self.prevy;
    float LineA2x = self.x;
    float LineA2y = self.y;
    
    float LineB1x = p1.x;
    float LineB1y = p1.y;
    float LineB2x = p2.x;
    float LineB2y = p2.y;
    
    //Vector2D* LineA1 = [[Vector2D alloc] initWithXY:self.prevx y:self.prevy];
    //Vector2D* LineA2 = [[Vector2D alloc] initWithXY:self.x y:self.y];
    //Vector2D* LineB1 = [[Vector2D alloc] initWithXY:p1.x y:p1.y];
    //Vector2D* LineB2 = [[Vector2D alloc] initWithXY:p2.x y:p2.y];
    float denom = (LineB2y - LineB1y) * (LineA2x - LineA1x) - (LineB2x - LineB1x) * (LineA2y - LineA1y);
    
    if (denom != 0.0) {
        float ua = ((LineB2x - LineB1x) * (LineA1y - LineB1y) - (LineB2y - LineB1y) * (LineA1x - LineB1x)) / denom;
        float ub = ((LineA2x - LineA1x) * (LineA1y - LineB1y) - (LineA2y - LineA1y) * (LineA1x - LineB1x)) / denom;
        if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
            return false;
        }
        self.x = LineA1x + ua * (LineA2x - LineA1x);
        self.y = LineA1y + ua * (LineA2y - LineA1y);
        self.prevx = self.x;
        self.prevy = self.y;
        Tracer* t = [trail objectAtIndex:0];
        t.x = self.x;
        t.y = self.y;
        return true;
    }
    return false;

}

//http://stackoverflow.com/questions/1073336/circle-line-collision-detection

- (Vector2D*) cicleLineCollision:(float)cx cy:(float)cy r:(float)r {
    
    Vector2D* d = [[Vector2D alloc] initWithXY:self.x - self.prevx y:self.y - self.prevy];
    Vector2D* f = [[Vector2D alloc] initWithXY:self.prevx - cx y:self.prevy - cy];
    float a = [Vector2D dot:d v2:d];
    float b = 2 * [Vector2D dot:f v2:d];
    float c = [Vector2D dot:f v2:f] - r * r;
    
    float discriminant = b * b - 4 * a * c;
    if( discriminant < 0 )
    {
        // no intersection
        return nil;
    }
    else
    {
        // ray didn't totally miss sphere,
        // so there is a solution to
        // the equation.
        
        discriminant = sqrt( discriminant );
        
        // either solution may be on or off the ray so need to test both
        // t1 is always the smaller value, because BOTH discriminant and
        // a are nonnegative.
        float t1 = (-b - discriminant)/(2*a);
        //float t2 = (-b + discriminant)/(2*a);
        
        // 3x HIT cases:
        //          -o->             --|-->  |            |  --|->
        // Impale(t1 hit,t2 hit), Poke(t1 hit,t2>1), ExitWound(t1<0, t2 hit),
        
        // 3x MISS cases:
        //       ->  o                     o ->              | -> |
        // FallShort (t1>1,t2>1), Past (t1<0,t2<0), CompletelyInside(t1<0, t2>1)
        
        if( t1 >= 0 && t1 <= 1 )
        {
            // t1 is the intersection, and it's closer than t2
            // (since t1 uses -b - discriminant)
            // Impale, Poke
    
            Vector2D* intersection = [[Vector2D alloc] initWithXY:self.prevx + d.x * t1 y:self.prevy + d.y * t1];
            Vector2D* n = [Vector2D normalize:[[Vector2D alloc] initWithXY:intersection.x - cx y:intersection.y - cy]];
            self.x = intersection.x;
            self.y = intersection.y;
            self.prevx = self.x;
            self.prevy = self.y;
            Tracer* t = [trail objectAtIndex:0];
            t.x = self.x;
            t.y = self.y;
            return n;
        }
        
        /*// here t1 didn't intersect so we are either started
        // inside the sphere or completely past it
        if( t2 >= 0 && t2 <= 1 )
        {
            // ExitWound
            return true ;
        }
        
        // no intn: FallShort, Past, CompletelyInside
        return false ;
        */
    }
    return nil;
}

- (BOOL) circleCollision:(Vector2D*)p1 p2:(Vector2D*)p2 {
    return false;
}

- (BOOL) circleCircleCollision:(Vector2D*)p r:(float)r {
    return false;
}

- (void) draw:(Camera*)camera {
    
    [camera translateObject:0 y:0 z:-1.0];
    [trace1 draw];
    
    [camera translateObject:self.x y:self.y z:-0.5];
    [circle1 draw];
    
    [camera translateObject:self.x y:self.y z:-0.25];
    [circle2 draw];
    
}

@end
