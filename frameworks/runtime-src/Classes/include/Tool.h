#pragma once

#include <math.h>

class CTool
{
public:
	CTool();
	~CTool();
	bool isInRange(int nAx, int nAy, int nBx, int nBy, int nRange);
	static bool isInRange(double dAx, double dAy, double dBx, double dBy, int nRange);
	static double countRange(double dAx, double dAy, double dBx, double dBy);
	// �㵽ֱ�ߵľ��루Pos1 Ϊ�������ĵ㣬pos2��pos3Ϊֱ���ϵ����㣩
	double distanceOfPointToLine(double dPos1x, double dPos1y, double dPos2x, double dPos2y, double dPos3x, double dPos3y);
    
    static char* getCopyStr(const char* source);
};

