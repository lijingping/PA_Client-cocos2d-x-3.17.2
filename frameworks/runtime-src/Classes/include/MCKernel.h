//
//  MCKernel.h
//  PA_Client
//
//  Created by LI on 2019/6/4.
//

#ifndef MCKernel_h
#define MCKernel_h

#include <vector>
#include <mutex>
#include "MobileClientKernel.h"

interface IObj
{
    virtual bool Release() = 0;
};

interface IReleaseCash
{
    virtual void AddToCash(IObj *obj) = 0;
};

//http://www.debugease.com/vc/1982282.html
class CMCKernel :public IMCKernel,public IReleaseCash
{
    std::vector<IObj *> *m_pCashList;
    std::vector<CMessage *> *m_pMsgArray;
    std::mutex m_utex;
    ILog *m_log;
public:
    CMCKernel();
    virtual ~CMCKernel();
public:
    //IMsgHandler
    virtual bool HanderMessage(unsigned short wType, int nHandler, unsigned short wMain, unsigned short wSub, unsigned char *pBuffer/* = nullptr*/, unsigned short wSize/* = 0*/);
public:
    //IMCKernel
    virtual bool CheckVersion(unsigned long dwVersion);
    virtual const char* GetVersion();
    virtual ISocketServer* CreateSocket(int handler);
    virtual void OnMainLoop(IMessageRespon* respon, int maxCount = 0);
    virtual void SetLogOut(ILog *log);
public:
    //IReleaseCash
    virtual void AddToCash(IObj *obj);
public:
    void LogOut(const char *message);
private:
    static CMCKernel* instance;
public:
    static CMCKernel * GetInstance();
};

#endif /* MCKernel_h */
