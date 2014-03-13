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
}

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius innerColor:(float[4])innerColor outerColor:(float[4])outerColor{
    self = [super init];
    if (self) {
        vertexCount = 30;
        self.x = x;
        self.y = y;
        self.radius = radius;
        self.innerColor = innerColor;
        self.outerColor = outerColor;
        [self makeObject];
    }
    return self;
}

- (void) makeObject {
    
    int idx = 0;
    //center vertex for triangle fan
    buffer[idx++] = self.x;
    buffer[idx++] = self.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = self.innerColor[0];
    buffer[idx++] = self.innerColor[1];
    buffer[idx++] = self.innerColor[2];
    buffer[idx++] = self.innerColor[3];
    
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
        
        buffer[idx++] = self.outerColor[0];
        buffer[idx++] = self.outerColor[1];
        buffer[idx++] = self.outerColor[2];
        buffer[idx++] = self.outerColor[3];
    }
    
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
    //glColor4f(0.5f,0.5f,1.0f,1.0f);
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

@end
