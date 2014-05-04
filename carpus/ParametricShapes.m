//
//  ParametricShapes.m
//  carpus
//
//  Created by Jeff Lutzenberger on 4/6/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "ParametricShapes.h"
#import "ShaderLoader.h"

#define NUM_PARTICLES 180

typedef struct Particle
{
    float       pID;
    float       radius;
    float       speed;
    float       damping;
    float       pointSize;
    float       timeOffset;
    //float       life;
    GLKVector3  color;
} Particle;

@implementation ParametricShapes {
    // Instance variables
    GLKVector2  _pos;
    GLKVector2  _gravity;
    float       _life;
    float       _time;
    Particle  particles[NUM_PARTICLES];
    float           radius;
    float           velocity;
    float           decay;
    float           size;
    GLKVector3      particleColor;
    GLuint _vertexArray;
    GLuint _vertexBuffer;

}

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color {
    self = [super init];
    if (self) {
        _pos = GLKVector2Make(x, y);
        _gravity = GLKVector2Make(0.0f, 0.0f);
        _life = 0.0f;
        _time = 0.0f;
        const float* c = gGameColors[color];
        particleColor.r = c[0];
        particleColor.g = c[1];
        particleColor.b = c[2];
    }
    return self;
}

- (void) draw:(Camera*)camera {
    // Uniforms
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(camera.projectionMatrix, camera.baseModelViewMatrix);
    glUniformMatrix4fv(camera.parametricShader.u_ProjectionMatrix, 1, 0, modelViewProjectionMatrix.m);
    glUniform2f(camera.parametricShader.u_Gravity, _gravity.x, _gravity.y);
    glUniform1f(camera.parametricShader.u_Time, _time);
    glUniform1f(camera.parametricShader.u_eRadius, radius);
    glUniform1f(camera.parametricShader.u_eVelocity, velocity);
    glUniform1f(camera.parametricShader.u_eDecay, decay);
    glUniform1f(camera.parametricShader.u_eSize, size);
    glUniform1f(camera.parametricShader.u_eLife, _life);
    glUniform3f(camera.parametricShader.u_eColor, particleColor.r, particleColor.g, particleColor.b);
    glUniform2f(camera.parametricShader.u_ePosition, _pos.x, _pos.y);
    
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_POINTS, 0, NUM_PARTICLES);
    
}
- (void)update:(float)timeElapsed {
    _time += timeElapsed;
    
    if(_time > _life)
        _time = 0.0f;
    
}

// 1
- (float)randomFloatBetween:(float)min and:(float)max
{
    float range = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * range) + min;
}
/*
- (void)loadParticleSystem:(parametricShader*)shader
{
    
    _life = 5000.0;
    
    // 3
    radius = 10.0;
    velocity = 4.0;
    decay = -velocity/_life;
    size = 20.0;
    
    // 4
    // Load Particles
    for(int i=0; i<NUM_PARTICLES; i++)
    {
        // Assign a unique ID to each particle, between 0 and 360 (in radians)
        particles[i].pID = GLKMathDegreesToRadians(((float)i/(float)NUM_PARTICLES)*360.0f);
        
        // Assign random offsets within bounds
        particles[i].radius = drand48() * radius;
        particles[i].speed = drand48() * velocity;
        particles[i].damping = particles[i].speed * decay;//drand48() * decay;
        particles[i].pointSize = drand48() * size;
        particles[i].timeOffset = drand48() * _life;
        //particles[i].life = _life;
        float r = drand48();
        float g = drand48();
        float b = drand48();
        particles[i].color = GLKVector3Make(r, g, b);
    }
    
    // 5
    // Load Properties
    radius = 20.0f;                                     // Blast radius
    velocity = 200.00f;                                   // Explosion velocity
    decay = -10.0f;                                      // Explosion decay
    size = 10.0f;                                      // Fragment size
    //particleColor = GLKVector3Make(0.00f, 0.60f, 1.00f);        // Fragment color
    
    // 6
    // Set global factors
    //float growth = radius / velocity;       // Growth time
    //_life = growth + decay + decay;                    // Simulation lifetime
    
    float drag = 10.00f;                                            // Drag (air resistance)
    _gravity = GLKVector2Make(0.00f, -9.81f*(1.0f/drag));           // World gravity
    
    //////////////////
    if (_vertexArray <= 0) {
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        glGenBuffers(1, &_vertexBuffer);
    } else {
        glBindVertexArrayOES(_vertexArray);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(particles), particles, GL_STATIC_DRAW);
    
    // Attributes
    glEnableVertexAttribArray(shader.a_pID);
    glEnableVertexAttribArray(shader.a_pRadiusOffset);
    glEnableVertexAttribArray(shader.a_pVelocityOffset);
    glEnableVertexAttribArray(shader.a_pDecayOffset);
    glEnableVertexAttribArray(shader.a_pSizeOffset);
    glEnableVertexAttribArray(shader.a_pTimeOffset);
    glEnableVertexAttribArray(shader.a_pColorOffset);
    
    glVertexAttribPointer(shader.a_pID, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, pID)));
    glVertexAttribPointer(shader.a_pRadiusOffset, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, radius)));
    glVertexAttribPointer(shader.a_pVelocityOffset, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, speed)));
    glVertexAttribPointer(shader.a_pDecayOffset, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, damping)));
    glVertexAttribPointer(shader.a_pSizeOffset, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, pointSize)));
    glVertexAttribPointer(shader.a_pTimeOffset, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, timeOffset)));
    glVertexAttribPointer(shader.a_pColorOffset, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)(offsetof(Particle, color)));
    
    glBindVertexArrayOES(0);
    
    
}
*/
@end
