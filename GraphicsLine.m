//
//  GraphicsLine.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/19/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsLine.h"


#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsLine {
    int vertexCount;
    float _buffer[2 * 7];
    float _lineWidth;
    GLuint vertexArray;
    GLuint vertexBuffer;
}


- (id) initWithCoordsAndColor:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(GameColor*)color {
    self = [super init];
    if (self) {
        vertexCount = 2;
        vertexArray = 0;
        [self updateCoordinates:x1 y1:y1 x2:x2 y2:y2 lineWidth:lineWidth color:color];
    }
    return self;
}

- (void)updateCoordinates:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(GameColor*)color {
    _lineWidth = lineWidth;
    _color = color;
    
    int idx = 0;
    _buffer[idx++] = x1;
    _buffer[idx++] = y1;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = _color.r;
    _buffer[idx++] = _color.g;
    _buffer[idx++] = _color.b;
    _buffer[idx++] = _color.a;
    
    _buffer[idx++] = x2;
    _buffer[idx++] = y2;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = _color.r;
    _buffer[idx++] = _color.g;
    _buffer[idx++] = _color.b;
    _buffer[idx++] = _color.a;
    
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
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(_lineWidth);
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_LINE_STRIP, 0, vertexCount);
}

@end
