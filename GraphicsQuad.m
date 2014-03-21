//
//  GraphicsQuad.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/13/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsQuad.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsQuad {
    int vertexCount;
    float buffer[4 * 12];
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
        self.color = [[GameColor alloc] initWithRGBA:1.0 g:1.0 b:1.0 a:1.0];
        [self updateVertexBuffer:_p1 p2:_p2 p3:_p3 p4:_p4];
    }
    return self;
}

- (void) updateVertexBuffer:(Vector2D*)p1 p2:(Vector2D*)p2 p3:(Vector2D*)p3 p4:(Vector2D*)p4 {
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
    
    buffer[idx++] = p4.x;
    buffer[idx++] = p4.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    buffer[idx++] = 1.0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    
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

    //glGenVertexArraysOES(1, &_vertexArray);
    //glBindVertexArrayOES(_vertexArray);
    
    //glGenBuffers(1, &_vertexBuffer);
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

- (void)updateColor:(GameColor*)color {
    //color
    _color.r = color.r;
    _color.g = color.g;
    _color.b = color.b;
    _color.a = color.a;
    
    buffer[6] = _color.r;
    buffer[7] = _color.g;
    buffer[8] = _color.b;
    buffer[9] = _color.a;
    
    buffer[18] = _color.r;
    buffer[19] = _color.g;
    buffer[20] = _color.b;
    buffer[21] = _color.a;
    
    buffer[30] = _color.r;
    buffer[31] = _color.g;
    buffer[32] = _color.b;
    buffer[33] = _color.a;
    
    buffer[42] = _color.r;
    buffer[43] = _color.g;
    buffer[44] = _color.b;
    buffer[45] = _color.a;
    
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
    //glColor4f(0.5f,0.5f,1.0f,1.0f);
    //glEnable(GL_LINE_SMOOTH);
    //glLineWidth(5);
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}


@end
