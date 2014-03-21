//
//  GraphicCircle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsCircle.h"
#define CIRCLE_VERTEX_COUNT = 30
#define BUFFER_OFFSET(i) ((char *)NULL + (i))


@implementation GraphicsCircle {
    int vertexCount;
    float buffer[30 * 10];
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _innerColor[4];
    float _outerColor[4];
}

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius innerColor:(float[4])innerColor outerColor:(float[4])outerColor{
    self = [super init];
    if (self) {
        vertexCount = 30;
        self.x = x;
        self.y = y;
        self.radius = radius;
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
    //center vertex for triangle fan
    buffer[idx++] = self.x;
    buffer[idx++] = self.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _innerColor[0];
    buffer[idx++] = _innerColor[1];
    buffer[idx++] = _innerColor[2];
    buffer[idx++] = _innerColor[3];
    
    //outer vertices of the circle
    int outerVertexCount = vertexCount-1;
    
    for (int i = 0; i < outerVertexCount; ++i){
        float percent = (i / (float) (outerVertexCount-1));
        float rad = percent * 2 * M_PI;
        
        //vertex position
        float outer_x = self.x + self.radius * cos(rad);
        float outer_y = self.y + self.radius * sin(rad);
        
        buffer[idx++] = outer_x;
        buffer[idx++] = outer_y;
        buffer[idx++] = 0;
        
        buffer[idx++] = 0;
        buffer[idx++] = 0;
        buffer[idx++] = 1;
        
        buffer[idx++] = _outerColor[0];
        buffer[idx++] = _outerColor[1];
        buffer[idx++] = _outerColor[2];
        buffer[idx++] = _outerColor[3];
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
    glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

@end
