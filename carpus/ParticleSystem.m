//
//  ParticleSystem.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "ParticleSystem.h"
#import "GraphicsLine.h"
#import "GraphicsQuad.h"

@implementation PassiveParticle {
    GraphicsLine* _graphicsLine;
    GraphicsQuad* _graphicsQuad;
    Vector2D* p1;
    Vector2D* p2;
    Vector2D* p3;
    Vector2D* p4;
}

- (id) initWithPosition:(float)x y:(float)y texture:(GLuint)texture {
    self = [super init];
    if (self) {
        _pos = [[Vector2D alloc] initWithXY:x y:y];
        _prevPos = [[Vector2D alloc] initWithXY:x y:y];
        _vel = [[Vector2D alloc] initWithXY:0 y:0];
        _dir = [[Vector2D alloc] initWithXY:0 y:1];
        _texture = texture;
        _theta = 0;
        _speed = 0;
        _accel = 0;
        _damping = 0;
        _age = 0;
        _lifetime = 1000;
        _color = [[GameColor alloc] initWithRGBA:1.0 g:0.0 b:0.0 a:1.0];
        _graphicsLine = [[GraphicsLine alloc] initWithCoordsAndColor:_pos.x y1:_pos.y x2:_prevPos.x y2:_prevPos.y lineWidth:3.0 color:_color];
        p1 = [[Vector2D alloc] initWithXY:_pos.x - 10 y:_pos.y - 10];
        p2 = [[Vector2D alloc] initWithXY:_pos.x + 10 y:_pos.y - 10];
        p3 = [[Vector2D alloc] initWithXY:_pos.x + 10 y:_pos.y + 10];
        p4 = [[Vector2D alloc] initWithXY:_pos.x - 10 y:_pos.y + 10];
        _graphicsQuad = [[GraphicsQuad alloc] initWithPoints:p1 p2:p2 p3:p3 p4:p4];
        
    }
    return self;
}

- (void) move:(float)dt {
    self.prevPos.x = self.pos.x;
    self.prevPos.y = self.pos.y;
    self.vel.x += self.dir.x * self.accel * dt;
    self.vel.y += self.dir.y * self.accel * dt;
    self.pos.x += self.vel.x * dt;
    self.pos.y += self.vel.y * dt;
}

- (void) recycle:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    self.pos.x = x;
    self.pos.y = y;
    self.prevPos.x = x;
    self.prevPos.y = y;
    self.age = 0;
    self.vel.x = vx;
    self.vel.y = vy;
    self.dir = [Vector2D normalize:self.vel];
}

- (void) updatePoints {
    float r = 50;
    p1.x = _pos.x - r;
    p1.y = _pos.y - r;
    p2.x = _pos.x + r;
    p2.y = _pos.y - r;
    p3.x = _pos.x + r;
    p3.y = _pos.y + r;
    p4.x = _pos.x - r;
    p4.y = _pos.y + r;
}

- (void) update:(float)dt {
    [self move:dt];
    self.age += dt;
}

- (void) draw:(Camera*)camera {
    [_graphicsLine updateCoordinates:_pos.x y1:_pos.y x2:_prevPos.x y2:_prevPos.y lineWidth:5.0 color:_color];
    [_graphicsLine draw];
    //[self updatePoints];
    //[_graphicsQuad updateVertexBuffer:p1 p2:p2 p3:p3 p4:p4];
    //[_graphicsQuad draw];
}

@end

@implementation ParticleSystem {
    GLuint _particleTexture;
    float _lifetime;
    float _speed;
}

- (id) initWithCoordsAndCapacity:(float)x y:(float)y capacity:(int)capacity {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        _pool = [[NSMutableArray alloc] init];
        _active = [[NSMutableArray alloc] init];
        //_particleTexture = [self setupTexture:@"glow.png"];
        _particleTexture = [self setupTexture:@"item_powerup_fish.png"];
        //_particleTexture = [self setupTexture:@"tile_floor.png"];
        for(int i = 0; i < capacity; i++) {
            [_pool addObject:[[PassiveParticle alloc] initWithPosition:x y:y texture:_particleTexture]];
        }
    }
    return self;
}

- (void) burst:(float)x y:(float)y burstRadius:(float)burstRadius speed:(float)speed accel:(float)accel nparticles:(int)nparticles lifetime:(float)lifetime {
    _lifetime = lifetime;
    _speed = speed;
    float theta = 0;
    float s = 0;
    PassiveParticle* p;
    for (int i = 0; i < nparticles; i += 1) {
        if ([self.pool count] <= 0) {
            break;
        }
        theta = drand48() * M_PI * 2;
        p = [self.pool lastObject];
        [self.pool removeLastObject];
        p.speed = speed;
        p.accel = accel;
        p.lifetime = lifetime;
        s = speed + drand48() * speed * 0.1;
        [p recycle:x + sin(theta) * 1.5 * burstRadius * drand48()
                 y:y + cos(theta) * 1.5 * burstRadius * drand48()
                vx:sin(theta) * s
                vy:cos(theta) * s];
        [self.active addObject:p];
    }
}

- (void) update:(float)dt {
    //var i = 0, theta, p;
    PassiveParticle* p;
    for (int i = [self.active count] - 1; i >= 0; i--) {
        p = [self.active objectAtIndex:i];
        [p update:dt];
        if (p.age > _lifetime) {
            [p recycle:self.x y:self.y vx:0 vy:0];
            [self.active removeObjectAtIndex:i];
            [self.pool addObject:p];
        }
    }
}

- (void)draw:(Camera*)camera {
    //glUseProgram([camera textureShader]);
    //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    //[camera translateObject:0 y:0 z:-0.0];
    //glActiveTexture(GL_TEXTURE0);
    //glBindTexture(GL_TEXTURE_2D, _particleTexture);
    for(PassiveParticle* p in self.active) {
        [p draw:camera];
    }
    //glUseProgram([camera basicShader]);
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

@end
