#pragma once
#ifndef Shape_h
#define Shape_h



using namespace std;

class CShape
{
public:
	CShape();
	~CShape();
	void setSize(int width, int height);
	void setPos(int x, int y);

	void rectShape();
	void cicleShape();

public:
	int m_nSizeWidth;
	int m_nSizeHeight;
	int m_nPosX;
	int m_nPosY;
	float m_fRadius;
};

#endif