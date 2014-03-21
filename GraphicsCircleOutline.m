//
//  GraphicsCircleOutline.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsCircleOutline.h"
#import <GLKit/GLKit.h>

#define CIRCLE_VERTEX_COUNT = 30
#define BUFFER_OFFSET(i) ((char *)NULL + (i))


@implementation GraphicsCircleOutline {
    int vertexCount;
    float buffer[80 * 10];
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _innerColor[4];
    float _outerColor[4];
}

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius lineWidth:(float)lineWidth innerColor:(float[4])innerColor outerColor:(float[4])outerColor{
    self = [super init];
    if (self) {
        vertexCount = 80;
        self.x = x;
        self.y = y;
        self.radius = radius;
        self.lineWidth = lineWidth;
        [self setColor:innerColor outerColor:outerColor];
        [self updateCircle];
    }
    return self;
}

- (void) setColor:(float[4])innerColor outerColor:(float[4])outerColor {
    _innerColor[0] = innerColor[0];
    _innerColor[1] = innerColor[1];
    _innerColor[2] = innerColor[2];
    _innerColor[3] = innerColor[3];
    _outerColor[0] = outerColor[0];
    _outerColor[1] = outerColor[1];
    _outerColor[2] = outerColor[2];
    _outerColor[3] = outerColor[3];
}

- (void) updateCircle {
    
    int idx = 0;
    float rout = self.radius + self.lineWidth * 0.5;
    float rin = self.radius - self.lineWidth * 0.5;
    float radius = rout;
    float sectionCount = (float)vertexCount * 0.5;
    for (int i = 0; i < sectionCount; ++i){
        float percent = (i / (float) (sectionCount-1));
        float rad = percent * 2 * M_PI;
        
        
        radius = rout;
        float x = self.x + radius * cos(rad);
        float y = self.y + radius * sin(rad);
        
        buffer[idx++] = x;
        buffer[idx++] = y;
        buffer[idx++] = 0;
        
        buffer[idx++] = 0;
        buffer[idx++] = 0;
        buffer[idx++] = 1;
        
        buffer[idx++] = _outerColor[0];
        buffer[idx++] = _outerColor[1];
        buffer[idx++] = _outerColor[2];
        buffer[idx++] = _outerColor[3];
        
        radius = rin;
        x = self.x + radius * cos(rad);
        y = self.y + radius * sin(rad);
        
        buffer[idx++] = x;
        buffer[idx++] = y;
        buffer[idx++] = 0;
        
        buffer[idx++] = 0;
        buffer[idx++] = 0;
        buffer[idx++] = 1;
        
        buffer[idx++] = _innerColor[0];
        buffer[idx++] = _innerColor[1];
        buffer[idx++] = _innerColor[2];
        buffer[idx++] = _innerColor[3];
    }
    
    if (_vertexArray <= 0) {
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        glGenBuffers(1, &_vertexBuffer);
    } else {
        glBindVertexArrayOES(_vertexArray);
    }

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(buffer), buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
}

- (void) draw {
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

@end
