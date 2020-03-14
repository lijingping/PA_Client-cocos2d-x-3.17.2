//
//  CCPomelo.hpp
//  PA
//
//  Created by sean on 15/12/1.
//
//

#ifndef CCPomelo_h
#define CCPomelo_h

#include "pomelo.h"
#include "cocos2d.h"

class CCPomelo : public cocos2d::Ref
{
public:
    virtual ~CCPomelo();

    static CCPomelo* getInstance();
    
    void connect(const char* host, int port);
    void disconnect();
    
    void request(int id, const char* route, const char* msg);
    
    int getState();
    void cleanup();
    
    std::map<std::string, std::string> getTable(std::map<std::string, std::string> table);
    
    std::vector<std::string> getArray(std::vector<std::string>table);
protected:
    CCPomelo();

public:
    static void requestCallBack(const pc_request_t* req, int rc, const char* resp);
    static void eventCallBack(pc_client_t* client, int ev_type, void* ex_data, const char* route, const char* msg);
    
protected:
    pc_client_t* m_client;
    int m_handler;
};

#endif /* CCPomelo_h */
