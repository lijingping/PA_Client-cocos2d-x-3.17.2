//
//  Define.h
//  PA_Client
//
//  Created by LI on 2019/6/4.
//

#ifndef Define_h
#define Define_h

#include "platform/CCPlatformConfig.h"
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    
#define TRUE    1
#define FALSE    0
    
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    typedef void                VOID;
    typedef unsigned char        BYTE;
    typedef unsigned short        WORD;
    typedef short               SHORT;
    typedef unsigned int        DWORD;
    typedef    long long            LONGLONG;
    typedef unsigned short        TCHAR;
    typedef long long            SCORE;
    typedef double              DOUBLE;
    typedef int                 LONG;
    typedef int                 INT;
    typedef int                 INT_PTR;
    typedef unsigned int        UINT;
    typedef DWORD               COLORREF;
#else
    typedef void                VOID;
    typedef unsigned char        BYTE;
    typedef unsigned short        WORD;
    typedef short               SHORT;
    typedef unsigned long        DWORD;
    typedef    long long            LONGLONG;
    typedef unsigned short        TCHAR;
    typedef long long            SCORE;
    typedef double              DOUBLE;
    typedef long                LONG;
    typedef int                 INT;
    typedef int                 INT_PTR;
    typedef unsigned int        UINT;
    typedef DWORD               COLORREF;
#endif
    
#else
#ifndef WIN32
    typedef void VOID;
    typedef unsigned char BYTE;
    typedef unsigned short WORD;
    typedef short  SHORT;
    typedef int BOOL;
    typedef unsigned int DWORD;
    typedef double DOUBLE;
    typedef float FLOAT;
    typedef long long SCORE;
    typedef long long __time64_t;
    typedef unsigned short TCHAR, WCHAR;
    typedef long LONG;
    typedef DWORD COLORREF;
    typedef unsigned int UINT;
    
#ifdef __x86_64__
    typedef long long INT_PTR;
#else
    typedef int INT_PTR;
#endif
    
#define TRUE    1
#define FALSE    0
#endif
#endif
    
#ifndef NULL
#ifdef __cplusplus
#define NULL    0
#else
#define NULL    ((void *)0)
#endif
#endif
    
#ifdef WIN32
#define FILE_SEPARATOR "\\"
#else
#define FILE_SEPARATOR "/"
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
#ifdef WIN32
#include <winsock2.h>
    inline void sleep_ms(int ms)
    {
        Sleep(ms*1000);
    }
    
    
#else
#include <unistd.h>
    
    inline void sleep_ms(int ms)
    {
        usleep(ms * 1000 * 1000);
    }
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
#ifndef SAFE_DELETE
#define SAFE_DELETE(p) { if(p) { delete (p); (p)=NULL; } }
#endif
#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) { if(p) { delete[] (p); (p)=NULL; } }
#endif
#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
#ifndef WIN32
#define _atoi64(val)                             strtoll(val, NULL, 10)
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static DWORD m_random = 0;
    
#ifdef WIN32
#include <windows.h>
#else
#include <pthread.h>
#endif
    inline DWORD PthreadSelf()
    {
#ifdef WIN32
        return GetCurrentThreadId();
#else
        return m_random++;
#endif
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
#ifndef interface
#define interface struct
#endif
    
#define     LEN_MD5                                    33                                 //加密密码
#define     LEN_USERNOTE                            32                                    //备注长度
#define     LEN_ACCOUNTS                            32                                    //帐号长度
#define     LEN_NICKNAME                            32                                    //昵称长度
#define     LEN_PASSWORD                            33                                    //密码长度
#define     LEN_GROUP_NAME                            32                                    //社团名字
#define     LEN_UNDER_WRITE                            32                                    //个性签名
    
#define     LEN_QQ                                    16                                    //QQ号码
#define     LEN_EMAIL                                33                                    //电子邮件
#define     LEN_USER_NOTE                            256                                    //用户备注
#define     LEN_SEAT_PHONE                            33                                    //固定电话
#define     LEN_MOBILE_PHONE                        16                                    //移动电话
#define     LEN_PASS_PORT_ID                        19                                    //证件号码
#define     LEN_COMPELLATION                        16                                    //真实名字
#define     LEN_DWELLING_PLACE                        128                                    //联系地址
#define     LEN_WEEK                                7                                    //星期长度
#define     LEN_TASK_NAME                            64                                    //任务名称
#define     LEN_TRANS_REMARK                        32                                    //转账备注
    
#define     LEN_NETWORK_ID                            13                                    //网卡长度
#define     LEN_MACHINE_ID                            33                                    //序列长度
    
#define     LEN_TYPE                                32                                    //种类长度
#define     LEN_KIND                                32                                    //类型长度
#define     LEN_NODE                                32                                    //节点长度
#define     LEN_PAGE                                32                                    //定制长度
#define     LEN_SERVER                                32                                    //房间长度
#define     LEN_PROCESS                                32                                    //进程长度
    
#define     SERVER_GENRE_NORMAL                        0x0001                              //普通类型
#define     SERVER_GENRE_PASSWD                     0x0002                                //密码类型
    
#define     MS_NULL                                    0x00                                //没有状态
#define     MS_SIGNUP                                0x01                                //报名状态
#define     MS_MATCHING                                0x02                                //比赛进行
    //#define     MS_MATCHEND                                0x03                                //比赛结束
    //#define     MS_OUT                                    0x04                                //淘汰状态
#define     MS_OUT                                    0x03                                //淘汰状态
    
#define     SRL_LOOKON                                0x00000001                            //旁观标志
#define     SRL_OFFLINE                                0x00000002                            //断线标志
#define     SRL_SAME_IP                                0x00000004                            //同网标志
    
#define     SRL_ROOM_CHAT                            0x00000100                            //聊天标志
#define     SRL_GAME_CHAT                            0x00000200                            //聊天标志
#define     SRL_WISPER_CHAT                            0x00000400                            //私聊标志
#define     SRL_HIDE_USER_INFO                        0x00000800                            //隐藏标志
    
#define     UD_NULL                                    0                                    //无效子项
#define     UD_IMAGE                                100                                    //图形子项
#define     UD_CUSTOM                                200                                    //自定子项
    
#define     UD_GAME_ID                                1                                    //游戏标识
#define     UD_USER_ID                                2                                    //用户标识
#define        UD_NICKNAME                                3                                    //用户昵称
    
#define     UD_GENDER                                10                                    //用户性别
#define     UD_GROUP_NAME                            11                                    //社团名字
#define     UD_UNDER_WRITE                            12                                    //个性签名
    
#define     UD_TABLE                                20                                    //游戏桌号
#define     UD_CHAIR                                21                                    //椅子号码
    
#define     UD_SCORE                                30                                    //用户分数
#define     UD_BANKER                                31                                    //用户银行
#define     UD_EXPERIENCE                            32                                    //用户经验
#define     UD_LOVELINESS                            33                                    //用户魅力
#define     UD_WIN_COUNT                            34                                    //胜局盘数
#define     UD_LOST_COUNT                            35                                    //输局盘数
#define     UD_DRAW_COUNT                            36                                    //和局盘数
#define     UD_FLEE_COUNT                            37                                    //逃局盘数
#define     UD_PLAY_COUNT                            38                                    //总局盘数
    
#define     UD_WIN_RATE                                40                                    //用户胜率
#define     UD_LOST_RATE                            41                                    //用户输率
#define     UD_DRAW_RATE                            42                                    //用户和率
#define     UD_FLEE_RATE                            43                                    //用户逃率
#define         UD_GAME_LEVEL                            44                                    //游戏等级
    
#define     UD_NOTE_INFO                            50                                    //用户备注
#define     UD_LOOKON_USER                            51                                    //旁观用户
    
#define     UD_IMAGE_FLAG                            (UD_IMAGE+1)                        //用户标志
#define     UD_IMAGE_STATUS                            (UD_IMAGE+2)                        //用户状态
    
#define     DB_ERROR                                 -1                                  //处理失败
#define     DB_SUCCESS                                 0                                      //处理成功
#define     DB_NEEDMB                                 18                                     //处理失败
#define     DB_PASSPORT                                19                                    //处理失败
    
#define     PT_USE_MARK_DOUBLE_SCORE                0x0001                                //双倍积分
#define     PT_USE_MARK_FOURE_SCORE                 0x0002                                //四倍积分
#define     PT_USE_MARK_GUARDKICK_CARD              0x0010                                //防踢道具
#define     PT_USE_MARK_POSSESS                     0x0020                                //附身道具
    
#define     MAX_PT_MARK                                 4                                    //标识数目
    
#define     VALID_TIME_DOUBLE_SCORE                 3600                                //有效时间
#define     VALID_TIME_FOUR_SCORE                   3600                                //有效时间
#define     VALID_TIME_GUARDKICK_CARD               3600                                //防踢时间
#define     VALID_TIME_POSSESS                      3600                                 //附身时间
#define     VALID_TIME_KICK_BY_MANAGER              3600                                //游戏时间
    
#define     DEVICE_TYPE_PC                          0x00                                //PC
#define     DEVICE_TYPE_ANDROID                     0x10                                //Android
#define     DEVICE_TYPE_ITOUCH                          0x20                                //iTouch
#define     DEVICE_TYPE_IPHONE                      0x40                                //iPhone
#define     DEVICE_TYPE_IPAD                        0x80                                //iPad
    
#define     VIEW_MODE_ALL                              0x0001                                //全部可视
#define     VIEW_MODE_PART                          0x0002                                //部分可视
    
#define     VIEW_INFO_LEVEL_1                          0x0010                                //部分信息
#define     VIEW_INFO_LEVEL_2                          0x0020                                //部分信息
#define     VIEW_INFO_LEVEL_3                          0x0040                                //部分信息
#define     VIEW_INFO_LEVEL_4                          0x0080                                //部分信息
    
#define     RECVICE_GAME_CHAT                          0x0100                                //接收聊天
#define     RECVICE_ROOM_CHAT                          0x0200                                //接收聊天
#define     RECVICE_ROOM_WHISPER                      0x0400                                //接收私聊
    
#define     BEHAVIOR_LOGON_NORMAL                      0x0000                                //普通登录
#define     BEHAVIOR_LOGON_IMMEDIATELY              0x1000                                //立即登录
    
#define     RESULT_ERROR                             -1                                  //处理错误
#define     RESULT_SUCCESS                             0                                      //处理成功
#define     RESULT_FAIL                             1                                      //处理失败
    
#define     SCORE_REASON_WRITE                          0                                     //写分变化
#define     SCORE_REASON_INSURE                     1                                     //银行变化
#define     SCORE_REASON_PROPERTY                   2                                    //道具变化
#define     SCORE_REASON_MATCH_FEE                  3                                    //比赛报名
#define     SCORE_REASON_MATCH_QUIT                 4                                    //比赛退赛
    
#define     LOGON_FAIL_SERVER_INVALIDATION          200                                 //登录房间失败原因
    
#define     ANDROID_SIMULATE                        0x01                                //相互模拟
#define     ANDROID_PASSIVITY                        0x02                                //被动陪打
#define     ANDROID_INITIATIVE                        0x04                                //主动陪打
    
#define     MATCH_FEE_TYPE_GOLD                        0x00                                //扣费类型
#define     MATCH_FEE_TYPE_MEDAL                    0x01                                //扣费类型
    
#define     MATCH_TYPE_LOCKTIME                        0x00                                //定时类型
#define     MATCH_TYPE_IMMEDIATE                    0x01                                //即时类型
    
#define     INVALID_ITEM                            65535                                //无效子项
#define     LEN_TASK_TEXT                            320                                    //任务文本
#define     MAX_PATH                                  260                                    //地址长度
    
#define     INVALID_BYTE                            ((BYTE)(0xff))                        //无效数值
#define     INVALID_WORD                            ((WORD)(0xffff))                    //无效数值
#define     INVALID_DWORD                            ((DWORD)(0xffffffff))                //无效数值
    
#define     CountArray(Array)                         (sizeof(Array)/sizeof(Array[0]))    //数组个数
    
#define     INTERFACE_OF(DST,SRC)                      ( SRC != NULL && NULL!=dynamic_cast<DST *>(SRC))    //转换判断
    
#define     EMPTY_CHAR(p)                            (p==NULL||p[0]=='\0')                //空字符
    
#define     LUA_BREAK(cond)                             if(cond) break                        //打断
    
#define     REV_CONTINUE                            0                                    //保持连接
#define     REV_CLOSE                                -1                                    //关闭连接
    
    
#define     MSG_SOCKET_CONNECT                        1                                    //网络链接
#define     MSG_SOCKET_DATA                            2                                    //网络数据
#define     MSG_SOCKET_CLOSED                        3                                    //网络关闭
#define     MSG_SOCKET_ERROR                        4                                    //网络错误
#define     MSG_HTTP_DOWN                            5                                     //网络下载
#define     MSG_UN_ZIP                              6                                   //解压缩
    
#define     DOWN_PRO_INFO                            1
#define     DOWN_COMPELETED                            3
#define     DOWN_ERROR_PATH                            4                                     //路径出错
#define     DOWN_ERROR_CREATEFILE                    5                                     //文件创建出错
#define     DOWN_ERROR_CREATEURL                    6                                     //创建连接失败
#define     DOWN_ERROR_NET                             7                                     //下载失败
#define     DOWN_ERROR_UNZIP                         8
    
#define     PATH_DIR                                "LYGame"
    
//授权信息
#ifdef     WIN32
    const TCHAR szCompilation[]=TEXT("B3D44854-9C2F-4C78-807F-8C08E940166D");
#else
#define  szCompilation  "B3D44854-9C2F-4C78-807F-8C08E940166D" //@compilation
#endif
#ifdef __cplusplus
}
#endif

#endif /* Define_h */
