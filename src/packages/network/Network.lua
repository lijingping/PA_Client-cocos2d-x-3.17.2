local ProtocolMapper = import(".ProtocolMapper")
local NetworkConst = require("app.constants.NetworkConst")
local Crypto = require("app.utils.Crypto")

-- import ".NetCommand"
require "packages.network.NetCommand"

local Network = {}--class("Network")

local PC_EV_USER_DEFINED_PUSH = 0
local PC_EV_CONNECTED = 1
local PC_EV_CONNECT_ERROR = 2
local PC_EV_CONNECT_FAILED = 3
local PC_EV_DISCONNECT = 4
local PC_EV_KICKED_BY_SERVER = 5
local PC_EV_UNEXPECTED_DISCONNECT = 6
local PC_EV_PROTO_ERROR = 7
local PC_EV_COUNT = 8

local MAX_REQUEST_ID = 256

Network.EVENT_CONNECTED = "event_connected"
Network.EVENT_DISCONNECT = "event_disconnect"

Network.GATE_HOST = NetworkConst.TEST1_GATE_HOST
Network.GATE_PORT = NetworkConst.TEST1_GATE_PORT

function Network:init()
    self.request_id = 0
    self.request_cbs = {}
    self.connect_cb = nil
    self.disconnect_cb = nil

    self.isConnected = false
    self.tryReconnect = false
    self.ccPomelo = pomelo.CCPomelo:getInstance()
end

function Network:cleanup()
    self.ccPomelo:cleanup()
end

function Network:getNextRequestId(request_id)
    if request_id >= MAX_REQUEST_ID then
        request_id = 0
    else
        request_id = request_id + 1
    end
    
    return request_id
end

function Network:connect(host, port, callback)
	self.connect_cb = callback
    self.ccPomelo:connect(host, port)
end

function Network:disconnect(callback)
    self.disconnect_cb = callback
    self.ccPomelo:disconnect()
end

function Network:request(route, data, callback)
	if not route then
		print("Network:request send route is nil")
		return
	end

	self.request_id = self:getNextRequestId(self.request_id)
	self.request_cbs[self.request_id] = callback

    local json_str
    if data ~= nil then
        json_str = json.encode(data)
    else
        json_str = "{}"
    end

    -- 网络请求后加个等待
    if App:getRunningSceneName() ~= "BattleScene" then
        if self.m_waitLayer == nil then
            self.m_waitLayer = require("app.views.common.WaitMsg"):create();
        end
    end

    self.ccPomelo:request(self.request_id, route, json_str)
end

--服务器推送的消息
function Network:onPush(ev_type, route, msg)
	-- print("Network:onPush ", ev_type, route, msg)
	if ev_type == PC_EV_CONNECTED then
		print("ev_type:PC_EV_CONNECTED")

        if self.tryReconnect then
            self.tryReconnect = false
            self:reconnect()
            return
        end

        self.isConnected = true
        if self.connect_cb and type(self.connect_cb) == "function" then
            self.connect_cb()
            self.connect_cb = nil
        end
	end

    if ev_type == PC_EV_USER_DEFINED_PUSH then
        print("ev_type:PC_EV_USER_DEFINED_PUSH")
        local data = {}
        if msg then
            data = json.decode(msg)
        end
        
        local listener = ProtocolMapper[route]
        if listener ~= nil then
            print("server notify, server protocol:",route,",local function name:",listener);
            if App:getRunningScene() and App:getRunningScene()[listener] then
                App:getRunningScene()[listener](App:getRunningScene(), data);--把notify函数写在scenes的文件里
            end
        end
    end

    if ev_type == PC_EV_DISCONNECT then
        print("ev_type:PC_EV_DISCONNECT")
        -- self:cleanup()
        self.isConnected = false
        if self.disconnect_cb and type(self.disconnect_cb) == "function" then
            self.disconnect_cb()
            self.disconnect_cb = nil
        end
    end

    if ev_type == PC_EV_CONNECT_ERROR or ev_type == PC_EV_CONNECT_FAILED or ev_type == PC_EV_UNEXPECTED_DISCONNECT then
        print("ev_type:OTHER");
        self.tryReconnect = true;
        App:getRunningScene():showLoading();
    end
end

function Network:onResponse(requestId, rc, resp)
	-- print("Network:onResponse", requestId, rc, resp)
    if self.m_waitLayer and self.m_waitLayer.close then
        self.m_waitLayer:close();
    end
    self.m_waitLayer = nil;

    local requestCallback = self.request_cbs[requestId]
    if not requestCallback or type(requestCallback) ~= "function" then
        print("Network:onResponse Can't find callback method")
        return
    end

    local data = nil;
    if resp then
        data = json.decode(resp)
        
        if not data then
            data = {
                code = 556,
                message = "json parse failed"
            }
        end
    end
     
    if data ~= nil then       
        requestCallback(rc, data)
    end
end

function Network:reconnect()
    print("Network:reconnect")
    Network:init()
    local host = nil
    local port = nil
    local seed = nil

    -- 连接Gate服务器
    local function connectGate(callback)
        print("Network@ connectGate")
        Network:connect(Network.GATE_HOST, Network.GATE_PORT, callback)
    end

    -- 请求地址端口
    local function knock(callback)
        print("Network@ knock")
        Network:request("gate.knockHandler.knock", "", callback)
    end

    local function knock_callback(rc, data)
        print("Network@ knock_callback")
        if rc == 0 then
            host = data.host
            port = data.port
        end
    end

    -- 断开Gate服务器连接
    local function disconnect(callback)
        print("Network@ disconnect")
        Network:disconnect(callback)
    end

    -- 连接connection服务器
    local function connect(callback)
        print("Network@ connect")
        Network:connect(host, port, callback)
    end

    -- 请求种子
    local function askSeed(callback)
        print("Network@ askSeed")
        Network:request("connector.entryHandler.askSeed", nil, callback)
    end

    local function askSeed_callback(rc, data)
        print("Network@ askSeed_callback")
        seed = data
    end

    -- 登录游戏
    local function login(callback)
        print("Network@ login")
        local userDefault = cc.UserDefault:getInstance()
        local session = userDefault:getStringForKey("usession")
        local uid = userDefault:getStringForKey("uid")

        if session == "" or uid == "" or App:getRunningSceneName() == "LoginScene" then
            App:getRunningScene():onConnectSuccessed(seed);
            return
        end

        local token = Crypto:decrypt(session)
        local hash = Crypto:md5(token .. "|" .. uid .. "|" .. seed)

        local data = {
            uid = uid,
            hash = hash,
        }

        Network:request("login.userHandler.reconnect", data, callback)
    end

    local function login_callback(rc, data)
        print("Network@ login_callback")
        -- dump(data)
        if data.code == 1 then
            App:getRunningScene():hideLoading()
            if App:getRunningScene()["onLoginSuccessed"] then
                App:getRunningScene():onLoginSuccessed();
            end
        else
            print("Login failed")
        end
    end

    local t = {
        {disconnect, nil},
        {connectGate, nil },
        {knock, knock_callback},
        {disconnect, nil},
        {connect, nil},
        {askSeed, askSeed_callback},
        {login, login_callback},
    }

    local co = coroutine.create(
        function (target, syncTable)
            for k, v in pairs(syncTable) do
                local function callback(...)
                    if v[2] and type(v[2]) == "function" then
                        v[2](...)
                    end
                    coroutine.resume(target)
                end
                v[1](callback)
                coroutine.yield()
            end
        end)
    coroutine.resume(co, co, t);
end


return Network