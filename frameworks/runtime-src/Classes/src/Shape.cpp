#include "stdafx.h"
#include "Shape.h"
#include <iostream>


CShape::CShape()
	: m_nSizeHeight(0)
	, m_nSizeWidth(0)
	, m_nPosX(0)
	, m_nPosY(0)
	, m_fRadius(0.0)
{
	
}


CShape::~CShape()
{
}


void CShape::setSize(int width, int height)
{
	m_nSizeWidth = width;
	m_nSizeHeight = height;
}

void CShape::setPos(int x, int y)
{
	m_nPosX = x;
	m_nPosY = y;
}

void CShape::rectShape()
{
}

void CShape::cicleShape()
{
}
