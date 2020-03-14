#include "stdafx.h"
#include "TimeTool.h"


#include <stdio.h>

CTimeTool::CTimeTool()
	:m_dTimeCount(0.0)
{

}

CTimeTool::~CTimeTool()
{

}

void CTimeTool::timeUpdate(double dt)
{
	m_dTimeCount += dt;
}

double CTimeTool::getTime()
{
	return m_dTimeCount;
}

void CTimeTool::resetTime()
{
	m_dTimeCount = 0.0;
}
