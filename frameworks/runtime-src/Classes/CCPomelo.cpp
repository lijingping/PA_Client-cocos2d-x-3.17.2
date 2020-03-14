//
//  CCPomelo.cpp
//  PA
//
//  Created by sean on 15/12/1.
//
//

#include "CCPomelo.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include <map>

#define TIME_OUT (10)
#define NOTIFY_HANDLER_EX ((void*)0x02)
#define EV_HANDLER_EX ((void*)0x10)
#define SCHEDULE_KEY "PomeloSchedule"
#define LOOP_INTERVAL (0.2f)

USING_NS_CC;

static CCPomelo *s_pomelo = nullptr;

CCPomelo* CCPomelo::getInstance()
{
    if (!s_pomelo)
    {
        s_pomelo = new (std::nothrow) CCPomelo();
        CCASSERT(s_pomelo, "FATAL: Not enough memory");
    }
    
    return s_pomelo;
}

static void disable_log(int level, const char* msg, ...)
{
    /* do nothing */
}

CCPomelo::CCPomelo()
:m_client(nullptr),
m_handler(-1)
{
    // 初始化 pomelo lib
    pc_lib_init(disable_log, NULL, NULL, NULL);
    
    // 初始化客户端
    pc_client_config_t config = {
        30, /* conn_timeout */
        1, /* enable_reconn */
        PC_ALWAYS_RETRY, /* reconn_max_retry */
        2, /* reconn_delay */
        30, /* reconn_delay_max */
        1, /* reconn_exp_backoff */
        1, /* enable_polling */
        NULL, /* local_storage_cb */
        NULL, /* ls_ex_data */
        PC_TR_NAME_UV_TCP /* transport_name */
    };
    
    m_client = (pc_client_t*)malloc(pc_client_size());
    pc_client_init(m_client, (void*)0x0, &config);
    
    // set callback
    m_handler = pc_client_add_ev_handler(m_client, &CCPomelo::eventCallBack, EV_HANDLER_EX, NULL);
    
    
    Director::getInstance()->getScheduler()->unschedule(SCHEDULE_KEY, this);
    Director::getInstance()->getScheduler()->schedule([=](float delta){
        pc_client_poll(m_client);
    }, this, LOOP_INTERVAL, kRepeatForever, 0.0f, 0, SCHEDULE_KEY);
    CCLOG("pomelo lib init OK!");
}

CCPomelo::~CCPomelo()
{

    Director::getInstance()->getScheduler()->unschedule(SCHEDULE_KEY, this);

    if(m_client)
    {
        pc_client_disconnect(m_client);
        pc_client_rm_ev_handler(m_client, m_handler);
        pc_client_cleanup(m_client);
        free(m_client);
        m_client = nullptr;
    }

    pc_lib_cleanup();
}

// ------------------------
// Callback method
// ------------------------
void CCPomelo::eventCallBack(pc_client_t* client, int ev_type, void* ex_data, const char* route, const char* msg)
{
    std::stringstream ss;

    ss << "Network:onPush(";
    ss << ev_type;
    ss << ",";
    if (route) {
        ss << "'" << route << "'";
    }else
    {
        ss << "nil";
    }
    
    ss << ",";
    if (msg) {
        ss << "'" << msg << "'";
    }else
    {
        ss << "nil";
    }
    
    ss << ")";

//    CCLOG("%s", ss.str().c_str());

    LuaEngine::getInstance()->executeString(ss.str().c_str());
}


void CCPomelo::requestCallBack(const pc_request_t* req, int rc, const char* resp)
{
    int id = (intptr_t)pc_request_ex_data(req);

    std::stringstream ss;

    ss << "Network:onResponse(";
    ss << id << "," << rc;
    if (resp) {
        ss << ", '" << resp << "'";
    }
    
    ss << ")";
    
//    CCLOG("%s", ss.str().c_str());
    
    LuaEngine::getInstance()->executeString(ss.str().c_str());
}

std::map<std::string, std::string> CCPomelo::getTable(std::map<std::string, std::string> table)
{

    std::map<std::string, std::string> map;
    std::map<std::string, std::string>::iterator it;

    for(it=table.begin();it!=table.end();++it)
    {
        CCLOG("key=%s, value=%s", it->first.c_str(), it->second.c_str());
        map.insert(std::pair<std::string, std::string>(it->first, it->second));
    }
    
    return map;
}

std::vector<std::string> CCPomelo::getArray(std::vector<std::string> table)
{
    std::vector<std::string> result;
    std::vector<std::string>::iterator it;

    for(it=table.begin();it!=table.end();++it)
    {
        CCLOG("%s", (*it).c_str());
        std::string s = *it;
        result.push_back(s);
    }
    return result;
}



// ------------------------
// Handler
// ------------------------
void CCPomelo::connect(const char* host, int port)
{
    // try to connect to server.
    CCLOG("[pomelo] connecting to %s : %d\n", host, port);
    int result = pc_client_connect(m_client, host, port, nullptr);
    CCLOG("%d", result);
}

void CCPomelo::disconnect()
{
    pc_client_disconnect(m_client);
}

void CCPomelo::request(int id, const char* route, const char* msg)
{
//    CCLOG("[pomelo] request route = %s, msg = %s\n", route, msg);
    pc_request_with_timeout(m_client, route, msg, (void*)(intptr_t)id, TIME_OUT, &CCPomelo::requestCallBack);
}

int CCPomelo::getState()
{
    if(m_client)
    {
        return pc_client_state(m_client);
    }
    return PC_ST_NOT_INITED;
}

void CCPomelo::cleanup()
{
    CCLOG("cleanup");
    Director::getInstance()->getScheduler()->unschedule(SCHEDULE_KEY, this);

    pc_client_rm_ev_handler(m_client, m_handler);
    pc_client_cleanup(m_client);
    free(m_client);
    m_client = nullptr;
    
    pc_lib_cleanup();
}
