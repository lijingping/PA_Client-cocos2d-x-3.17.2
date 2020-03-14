#pragma once


#ifndef CTimeTool_h
#define CTimeTool_h

class CTimeTool
{
public:
	CTimeTool();
	~CTimeTool();
	void timeUpdate(double dt);
	double getTime();
	void resetTime();
private:
	double m_dTimeCount;
};


#endif /* CTimeTool_h */