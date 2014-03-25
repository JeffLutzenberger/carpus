//
//  GraphicsTrace.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsTrace.h"
#import "Particle.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsTrace {
    int vertexCount;
    float _buffer[30 * 7];
    //float* _buffer;
    float _lineWidth;
    GLuint vertexArray;
    GLuint vertexBuffer;
    float _color[4];
}

- (id) initWithTrailAndColor:(NSMutableArray*)trail lineWidth:(float)lineWidth color:(float[4])color{
    self = [super init];
    if (self) {
        _lineWidth = lineWidth;
        [self setColor:color];
        vertexCount = (int)[trail count];
        vertexArray = 0;
        //_buffer = (float *)malloc(vertexCount * 7 * sizeof(float));
        [self updateCoordinates:trail];
    }
    return self;
}

- (void) setColor:(float[4])color {
    _color[0] = color[0];
    _color[1] = color[1];
    _color[2] = color[2];
    _color[3] = color[3];
}

- (void)updateCoordinates:(NSMutableArray *)trail {
    int idx = 0;
    for (int i = 0; i < vertexCount; i++) {
        Tracer* t = [trail objectAtIndex:i];
        float alpha = (vertexCount - t.age) / vertexCount;
        _buffer[idx++] = t.x;
        _buffer[idx++] = t.y;
        _buffer[idx++] = 0;
        
        _buffer[idx++] = _color[0];
        _buffer[idx++] = _color[1];
        _buffer[idx++] = _color[2];
        _buffer[idx++] = _color[3] * alpha;
        
    }
    if (vertexArray <= 0) {
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        glGenBuffers(1, &vertexBuffer);
    } else {
        glBindVertexArrayOES(vertexArray);
    }
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(_buffer), _buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
    
}

- (void) draw {
    //glColor4f(0.5f,0.5f,1.0f,1.0f);
    //glEnable(GL_LINE_SMOOTH);
    glLineWidth(_lineWidth);
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_LINE_STRIP, 0, vertexCount);
}


@end
