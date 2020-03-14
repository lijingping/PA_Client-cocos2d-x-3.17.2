#include "Tool.h"

#include <iostream>


CTool::CTool()
{
}


CTool::~CTool()
{
}

bool CTool::isInRange(int nAx, int nAy, int nBx, int nBy, int nRange)
{
	if ((nBx - nAx) * (nBx - nAx) + (nBy - nAy) * (nBy - nAy) > nRange * nRange)
	{
		return false;
	}
	else
	{
		return true;
	}
}

bool CTool::isInRange(double dAx, double dAy, double dBx, double dBy, int nRange)
{
	if ((dBx - dAx) * (dBx - dAx) + (dBy - dAy) * (dBy - dAy) > nRange * nRange)
	{
		return false;
	}
	else
	{
		return true;
	}
}

double CTool::countRange(double dAx, double dAy, double dBx, double dBy)
{
	return sqrt((dBx - dAx) * (dBx - dAx) + (dBy - dAy) * (dBy - dAy));
}

double CTool::distanceOfPointToLine(double dPos1x, double dPos1y, double dPos2x, double dPos2y, double dPos3x, double dPos3y)
{
	//先算公式分子
	double dMember1 = (dPos1x - dPos2x) * (dPos3y - dPos2y);
	double dMember2 = (dPos1y - dPos2y) * (dPos2x - dPos3x);
	//计算分母
	double dDenominator1 = (dPos3y - dPos2y) * (dPos3y - dPos2y);
	double dDenominator2 = (dPos2x - dPos3x) * (dPos2x - dPos3x);

	double dResult = sqrt(pow(dMember1 + dMember2, 2) / (dDenominator1 + dDenominator2));
	return dResult;
}

char* CTool::getCopyStr(const char* source)
{
    char* dest = new char[strlen(source)+1];
    strcpy(dest, source);
    return dest;
}
