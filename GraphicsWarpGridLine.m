//
//  GraphicsWarpGridLine.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/24/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsWarpGridLine.h"
#import "PointMass.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsWarpGridLine {
    int _pointCount;
    float* _buffer;
    GLuint vertexArray;
    GLuint vertexBuffer;
    float _color[4];
}

- (id) initWithCapacity:(int)npoints {
    self = [super init];
    if (self) {
        _pointCount = npoints;
        _points = [[NSMutableArray alloc] initWithCapacity:npoints];
        for(int i = 0; i < npoints; i++) {
            [_points insertObject:[[Vector2D alloc] init] atIndex: i];
        }
        _lineWidth = 5.0;
        _color[0] = 0.0;
        _color[1] = 0.0;
        _color[2] = 1.0;
        _color[3] = 1.0;
        _buffer = (float*)malloc(sizeof(float) * npoints * 7);
    }
    return self;
}

- (void)updateCoordinates {
    int idx = 0;
    for (Vector2D* p in _points) {
        _buffer[idx++] = p.x;
        _buffer[idx++] = p.y;
        _buffer[idx++] = 0;
        
        _buffer[idx++] = 0.0;
        _buffer[idx++] = 0.0;
        _buffer[idx++] = 1.0;
        _buffer[idx++] = 1.0;
        
    }
    if (vertexArray <= 0) {
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        glGenBuffers(1, &vertexBuffer);
    } else {
        glBindVertexArrayOES(vertexArray);
    }
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, /*sizeof(_buffer)*/ sizeof(float) * _pointCount * 7, _buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void) draw {
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(_lineWidth);
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_LINE_STRIP, 0, _pointCount);
}

@end
