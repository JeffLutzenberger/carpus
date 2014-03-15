//
//  GraphicsArc.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsArc.h"
#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsArc {
    int vertexCount;
    float buffer[60 * 10];
    GLuint _vertexArray;
    GLuint _vertexBuffer;

}


- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius lineWidth:(float)lineWidth startTheta:(float)startTheta endTheta:(float)endTheta color:(float[4])color {
    self = [super init];
    if (self) {
        vertexCount = 60;
        self.x = x;
        self.y = y;
        self.radius = radius;
        self.lineWidth = lineWidth;
        self.startTheta = startTheta;
        self.endTheta = endTheta;
        self.color = color;
        [self makeObject];
    }
    return self;
}

- (void) makeObject {
    
    int idx = 0;
    float rout = self.radius + self.lineWidth * 0.5;
    float rin = self.radius - self.lineWidth * 0.5;
    float radius = rout;
    float sectionCount = (float)vertexCount * 0.5;
    float deltaTheta = _endTheta - _startTheta;
    for (int i = 0; i < sectionCount; ++i){
        float percent = (i / (float) (sectionCount-1));
        float rad = _startTheta + percent * deltaTheta;
        
        radius = rout;
        float x = self.x + radius * cos(rad);
        float y = self.y + radius * sin(rad);
        
        buffer[idx++] = x;
        buffer[idx++] = y;
        buffer[idx++] = 0;
        
        buffer[idx++] = 0;
        buffer[idx++] = 0;
        buffer[idx++] = 1;
        
        buffer[idx++] = self.color[0];
        buffer[idx++] = self.color[1];
        buffer[idx++] = self.color[2];
        buffer[idx++] = self.color[3];
        
        radius = rin;
        x = self.x + radius * cos(rad);
        y = self.y + radius * sin(rad);
        
        buffer[idx++] = x;
        buffer[idx++] = y;
        buffer[idx++] = 0;
        
        buffer[idx++] = 0;
        buffer[idx++] = 0;
        buffer[idx++] = 1;
        
        buffer[idx++] = self.color[0];
        buffer[idx++] = self.color[1];
        buffer[idx++] = self.color[2];
        buffer[idx++] = self.color[3];
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
    glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

@end
