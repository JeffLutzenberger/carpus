//
//  GraphicsRectangle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsRectangle.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsRectangle {
    int vertexCount;
    float buffer[4 * 10];
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 p4:(Vector2D*)p4 {
    self = [super init];
    if (self) {
        vertexCount = 4;
        self.p1 = p1;
        self.p2 = p2;
        self.p3 = p3;
        self.p4 = p4;
        [self makeObject];
    }
    return self;
}

- (void) makeObject {
    int idx = 0;
    buffer[idx++] = self.p1.x;
    buffer[idx++] = self.p1.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = self.p2.x;
    buffer[idx++] = self.p2.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = self.p3.x;
    buffer[idx++] = self.p3.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = self.p4.x;
    buffer[idx++] = self.p4.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 0.0;
    buffer[idx++] = 1.0;
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
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
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(5);
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}


@end
