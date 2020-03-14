#include "UnZipAsset.h"
#include <thread>
#include "MobileClientKernel.h"
#include "Define.h"
#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else
#include "unzip/unzip.h"
#endif

static unsigned long  _maxUnzipBufSize = 0x500000;

CUnZipAsset::CUnZipAsset(const char* szFilePath,const char* szUnZipPath,int nHandler)
: m_szFilePath(szFilePath)
, m_szUnZipPath(szUnZipPath)
, m_nHandler(nHandler)
{
    m_nPercent = 0;
}

CUnZipAsset::~CUnZipAsset()
{
}

//解压zip
bool CUnZipAsset::unzip(const char *zipPath,const char *dirpath,const char *passwd,bool bAsset)
{
    CCLOG("unzip info:zippath[%s]\n dirpath[%s]",zipPath,dirpath);
    if (false == FileUtils::getInstance()->isFileExist(zipPath))
    {
        CCLOG("zipfile [%s] not exist",zipPath);
        return false;
    }
    
    unzFile pFile;
    if(!bAsset)
    {
         pFile = unzOpen(zipPath);
    }
    else
    {
        ssize_t len = 0;
        unsigned char *data = CCFileUtils::getInstance()->getFileData(zipPath, "rb", &len);
        //Data d = FileUtils::getInstance()->getDataFromFile(zipPath);
        
        pFile = unzOpenBuffer(data, len);
        //pFile = unzOpen(zipPath);
    }
    if(!pFile)
    {
        CCLOG("unzip error get zip file false");
        return false;
    }
    
    // 获取zip文件信息
    unz_global_info globalInfo;
    double dCountEntry = 0;
    if (unzGetGlobalInfo(pFile, &globalInfo) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", zipPath);
        unzClose(pFile);
        return false;
    }
    
    std::string szTmpDir = dirpath;
    if (szTmpDir[szTmpDir.length()-1]!='/')
    {
        szTmpDir = szTmpDir+"/";
    }
    int err = unzGoToFirstFile(pFile);
    bool ret = true;
    while (err == UNZ_OK)
    {
        int nRet = 0;
        int openRet = 0;
        do
        {
            if(passwd)
            {
                openRet = unzOpenCurrentFilePassword( pFile,passwd);
                CCLOG("openRet %d",openRet);
            }
            else
            {
                openRet = unzOpenCurrentFile(pFile);
            }
            CC_BREAK_IF(UNZ_OK != openRet);
            unz_file_info FileInfo;
            char szFilePathA[260];
            nRet = unzGetCurrentFileInfo(pFile, &FileInfo, szFilePathA, sizeof(szFilePathA), NULL, 0, NULL, 0);
            CC_BREAK_IF(UNZ_OK != nRet);
            //如果szFilePathA为中文的话，请使用iocnv转码后再使用。

            std::string newName = szTmpDir +szFilePathA;
            if (newName[newName.length()-1]=='/')
            {
                FileUtils::getInstance()->createDirectory(newName.c_str());
                continue;
            }
            else
            {
                std::string strFolder = "";
                int nPos = newName.find_last_of('/');
                if(nPos > 0)
                {
                    strFolder = newName.substr(0, nPos+1);
                    if (false == FileUtils::getInstance()->isDirectoryExist(strFolder))
                    {
                        FileUtils::getInstance()->createDirectory(strFolder.c_str());
                    }
                }
            }
            

            FILE* pFile2 = fopen(newName.c_str(), "w");
            if (pFile2)
            {
                fclose(pFile2);
            }
            else
            {
                CCLOG("unzip can not create file");
                return false;
            }

            unsigned long savedSize = 0;
            pFile2 = fopen(newName.c_str(), "wb");
            while(pFile2 != NULL && FileInfo.uncompressed_size > savedSize)
            {
                unsigned char *pBuffer = NULL;
                unsigned long once = FileInfo.uncompressed_size - savedSize;
                if(once > _maxUnzipBufSize)
                {
                    once = _maxUnzipBufSize;
                    pBuffer = new unsigned char[once];
                }
                else
                {
                    pBuffer = new unsigned char[once];
                }
                int nSize = unzReadCurrentFile(pFile, pBuffer, once);
                fwrite(pBuffer, once, 1, pFile2);
                
                savedSize += nSize;
                delete []pBuffer;
            }
            if (pFile2)
            {
                fclose(pFile2);
            }
            
        } while (0);
        if(nRet != UNZ_OK)
        {
            ret = false;
        }
        else
        {
            unzCloseCurrentFile(pFile);
        }
        err = unzGoToNextFile(pFile);
        
        int tmp = (int)(((++dCountEntry)/globalInfo.number_entry) * 100);
        upDatePro(tmp);
    }
    
    if(err != UNZ_END_OF_LIST_OF_FILE)
    {
        ret = false;
    }
    unzClose(pFile);
    return ret;
}

void CUnZipAsset::UnZipFile(const char* szFilePath,const char* szUnZipPath,int nHandler)
{
	CUnZipAsset *pUnzipAsset = new CUnZipAsset(szFilePath,szUnZipPath,nHandler);
	pUnzipAsset->autorelease();
	pUnzipAsset->retain();
    std::thread thr(&CUnZipAsset::UnZipRun, pUnzipAsset);
    thr.detach();
}

//更新进度
void CUnZipAsset::upDatePro(int percent)
{
    if(percent != m_nPercent)
    {
        m_nPercent = percent;
        if((m_nPercent % 2) == 0)
        {
            Notify(DOWN_PRO_INFO, m_nPercent);
        }
    }
}

//通知UI
void CUnZipAsset::Notify(int wMain,int wSub)
{
    if (m_nHandler != 0)
    {
        GetMCKernel()->HanderMessage(MSG_UN_ZIP,m_nHandler,(WORD)wMain,(WORD)wSub);
    }
}

void CUnZipAsset::UnZipRun()
{
    int result = DOWN_ERROR_UNZIP;
     //创建解压
    if (FileUtils::getInstance()->createDirectory(m_szUnZipPath.c_str()))
    {
        if(unzip(m_szFilePath.c_str(),m_szUnZipPath.c_str(),NULL,true))
      	{
      		result = DOWN_COMPELETED;
      	}
    }else{
    	CCLOG("download unzippath create fail [%s]",m_szUnZipPath.c_str());
    }
    
    Notify(result, (result == DOWN_COMPELETED ? 100 : 0));
    
    release();
}
