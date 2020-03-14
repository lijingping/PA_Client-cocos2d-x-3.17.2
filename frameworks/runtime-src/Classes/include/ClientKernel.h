#ifndef _LUA_CLIENT_KERNEL_H_
#define _LUA_CLIENT_KERNEL_H_

#include "Define.h"
#include "cocos2d.h"
#include "MobileClientKernel.h"
USING_NS_CC;
class CClientKernel: public cocos2d::Node,public IMessageRespon,public ILog
{
private:
    CClientKernel();
    static CClientKernel * instance;

public:
    static CClientKernel * GetInstance();

public:
	virtual ~CClientKernel();

public:
	bool OnMessageHandler(int nHandler,WORD wMain, WORD wSub, unsigned char *pBuffer = nullptr);

public:
	bool OnCallLuaSocketCallBack(int nHandler,Ref* data);

public:
    /*
	bool OnSocketConnectEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize);
	bool OnSocketDataEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize);
	bool OnSocketErrorEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize);
	bool OnSocketCloseEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize);
    */
public:
    static void globalUpdate(float dt);
    
public:
	virtual void OnMessageRespon(CMessage* message);

	virtual void LogOut(const char *message);
};



#endif
