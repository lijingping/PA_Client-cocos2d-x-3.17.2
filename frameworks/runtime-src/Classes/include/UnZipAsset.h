#ifndef _UN_ZIP_ASSET_H_
#define _UN_ZIP_ASSET_H_

#include <string>
#include "cocos2d.h"

using namespace cocos2d;
using namespace std;

class CUnZipAsset :public cocos2d::Node
{
protected:
	std::string	m_szUnZipPath;			//解压目录
	std::string m_szFilePath;			//解压文件
    int			m_nHandler;
    int         m_nPercent;             //进度
protected:
	CUnZipAsset(const char* szFilePath,const char* szUnZipPath,int nHandler);

public:
	virtual ~CUnZipAsset();

public:
    static void UnZipFile(const char* szFilePath,const char* szUnZipPath,int nHandler);

protected:
    bool unzip(const char *zipPath,const char *dirpath,const char *passwd,bool bAsset);
    void upDatePro(int precent);
    void Notify(int wMain,int wSub);
	void UnZipRun();
};

#endif
