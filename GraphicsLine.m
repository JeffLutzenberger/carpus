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
    float _color[4];
}


- (id) initWithCoordsAndColor:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(float[4])color {
    self = [super init];
    if (self) {
        _lineWidth = lineWidth;
        _color[0] = color[0];
        _color[1] = color[1];
        _color[2] = color[2];
        _color[3] = color[3];
        vertexCount = 2;
        [self updateCoordinates:x1 y1:y1 x2:x2 y2:y2 lineWidth:lineWidth color:color];
    }
    return self;
}

- (void)updateCoordinates:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(float[4])color {
    _lineWidth = lineWidth;
    //_color = color;
    
    int idx = 0;
    _buffer[idx++] = x1;
    _buffer[idx++] = y1;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
    _buffer[idx++] = x2;
    _buffer[idx++] = y2;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
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

@implementation GraphicsQuadLine {
    int vertexCount;
    float _buffer[4 * 7];
    float _lineWidth;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _color[4];

}

- (id) initWithCoordsAndColor:(Vector2D*)start end:(Vector2D*)end lineWidth:(float)lineWidth color:(float[4])color{
    self = [super init];
    if (self) {
        _lineWidth = lineWidth;
        _color[0] = color[0];
        _color[1] = color[1];
        _color[2] = color[2];
        _color[3] = color[3];
        vertexCount = 4;
        [self updateCoordinates:start end:end lineWidth:lineWidth color:color];
    }
    return self;
}

- (void) updateCoordinates:(Vector2D*)start end:(Vector2D*)end lineWidth:(float)lineWidth color:(float[4])color {
    _lineWidth = lineWidth;
    _color[0] = color[0];
    _color[1] = color[1];
    _color[2] = color[2];
    _color[3] = color[3];
    float w = _lineWidth;
    Vector2D* dir = [Vector2D normalize:[[Vector2D alloc] initWithXY:end.x - start.x y:end.y - start.y]];
    Vector2D* n = [[Vector2D alloc] initWithXY:dir.y y:-dir.x];
    float x1 = start.x - n.x * w;
    float x2 = start.x + n.x * w;
    float x3 = end.x + n.x * w;
    float x4 = end.x - n.x * w;
    float y1 = start.y + n.y * w;
    float y2 = start.y - n.y * w;
    float y3 = end.y - n.y * w;
    float y4 = end.y + n.y * w;
    
    int idx = 0;
    _buffer[idx++] = x1;
    _buffer[idx++] = y1;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
    _buffer[idx++] = x2;
    _buffer[idx++] = y2;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
    _buffer[idx++] = x4;
    _buffer[idx++] = y4;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
    _buffer[idx++] = x3;
    _buffer[idx++] = y3;
    _buffer[idx++] = 0;
    
    _buffer[idx++] = color[0];
    _buffer[idx++] = color[1];
    _buffer[idx++] = color[2];
    _buffer[idx++] = color[3];
    
    if (_vertexArray <= 0) {
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        glGenBuffers(1, &_vertexBuffer);
    } else {
        glBindVertexArrayOES(_vertexArray);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(_buffer), _buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void) draw {
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

@end
