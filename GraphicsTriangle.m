//
//  GraphicsTriangle.m
//  carpus
//
//  Created by Jeff Lutzenberger on 4/26/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsTriangle.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsTriangle {
    int vertexCount;
    float buffer[3 * 12];
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 {
    self = [super init];
    if (self) {
        vertexCount = 4;
        self.p1 = p1;
        self.p2 = p2;
        self.p3 = p3;
        //self.color = [[GameColor alloc] initWithRGBA:1.0 g:1.0 b:1.0 a:1.0];
        [self updateVertexBuffer:_p1 p2:_p2 p3:_p3];
        self.fanEffect = NO;
    }
    return self;
}

- (void) updateVertexBuffer:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 {
    int idx = 0;
    //position
    buffer[idx++] = p1.x;
    buffer[idx++] = p1.y;
    buffer[idx++] = 0;
    //normal
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    //color
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    //texture
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = p2.x;
    buffer[idx++] = p2.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = 1;
    buffer[idx++] = 1;
    
    buffer[idx++] = p3.x;
    buffer[idx++] = p3.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = 1;
    buffer[idx++] = 0;
    
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
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(24));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(40));
    
    glBindVertexArrayOES(0);
    
}

- (void)setColor:(float[4])color {
    //color
    //_color.r = color[0];
    //_color.g = color[1];
    //_color.b = color[2];
    //_color.a = color[3];
    
    buffer[6] = color[0];
    buffer[7] = color[1];
    buffer[8] = color[2];
    buffer[9] = color[3];
    
    buffer[18] = color[0];
    buffer[19] = color[1];
    buffer[20] = color[2];
    buffer[21] = color[3];
    
    buffer[30] = color[0];
    buffer[31] = color[1];
    buffer[32] = color[2];
    buffer[33] = color[3];
    
    glBindVertexArrayOES(_vertexArray);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(buffer), buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(24));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(40));
    
    glBindVertexArrayOES(0);
    
}

- (void) draw {
    glBindVertexArrayOES(_vertexArray);
    if(self.fanEffect) {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
    } else {
        glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    }
}

@end
