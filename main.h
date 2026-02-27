#ifndef MAIN_H
#define MAIN_H
#include <QFontMetrics>
#include <QOpenGLTexture>
#include <QRegularExpression>
#include <QtCore/qmath.h>

#include <memory>

// Font alignment
enum r_fontAlign_e {
	F_LEFT,
	F_CENTRE,
	F_RIGHT,
	F_CENTRE_X,
	F_RIGHT_X
};

// Fonts
enum r_fonts_e {
	F_FIXED,	// Monospaced: Bitsteam Vera Sans Mono
	F_VAR,		// Normal: Liberation Sans
	F_VAR_BOLD,	// Normal: Liberation Sans Bold
	F_NUMFONTS
};

// Texture flags
enum r_texFlag_e {	
	TF_CLAMP	= 0x01,	// Clamp texture
	TF_NOMIPMAP	= 0x02,	// No mipmaps
	TF_NEAREST	= 0x04,	// Use nearest-pixel magnification instead of linear
	TF_ASYNC	= 0x08	// Asynchronous loading
};

class Cmd {
  public:
    virtual void execute() = 0;
};

class ViewportCmd : public Cmd {
  public:
    ViewportCmd(int X, int Y, int W, int H) : x(X), y(Y), w(W), h(H) {
    }

    void execute();
  private:
    int x, y, w, h;
};

class ColorCmd : public Cmd {
  public:
  ColorCmd(float Col[4]) : col {Col[0], Col[1], Col[2], Col[3]} {}
    void execute() {
        glColor4fv(col);
    }
  private:
    float col[4];
};

class DrawImageQuadCmd : public Cmd {
  public:
    DrawImageQuadCmd() {}
  DrawImageQuadCmd(std::shared_ptr<QOpenGLTexture> Tex, float X0, float Y0, float X1, float Y1, float X2, float Y2, float X3, float Y3, float S0 = 0, float T0 = 0, float S1 = 1, float T1 = 0, float S2 = 1, float T2 = 1, float S3 = 0, float T3 = 1) : x {X0, X1, X2, X3}, y {Y0, Y1, Y2, Y3}, s {S0, S1, S2, S3}, t {T0, T1, T2, T3}, tex(Tex) {
    }

    void execute();
  protected:
    std::shared_ptr<QOpenGLTexture> tex;
    float x[4];
    float y[4];
    float s[4];
    float t[4];
};

class DrawImageCmd : public DrawImageQuadCmd {
  public:
  DrawImageCmd(std::shared_ptr<QOpenGLTexture> tex, float x, float y, float w, float h, float s1 = 0, float t1 = 0, float s2 = 1.0f, float t2 = 1.0f) : DrawImageQuadCmd(tex, x, y, x + w, y, x + w, y + h, x, y + h, s1, t1, s2, t1, s2, t2, s1, t2) {
    }
};

class DrawStringCmd : public DrawImageQuadCmd {
  public:
    DrawStringCmd(float X, float Y, int Align, int Size, int Font, const char *Text);
    ~DrawStringCmd() {
    }

    void execute() {
        float curCol[4];
        if (col[3] > 0) {
            glGetFloatv(GL_CURRENT_COLOR, curCol);
            glColor4fv(col);
        }
        DrawImageQuadCmd::execute();
        if (col[3] > 0) {
            glColor4fv(curCol);
        }
    }

    void setCol(float c0, float c1, float c2) {
        col[0] = c0;
        col[1] = c1;
        col[2] = c2;
        col[3] = 1.0f;
    }
  private:
    float col[4] = {0.0f, 0.0f, 0.0f, 0.0f};
    QString text;
};
#endif
