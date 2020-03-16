cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


require "config"
require "constant"
require "cocos.init"

App = require("app.MyApp");	
Network = require("packages.network.Network");		-- 网络连接相关接口

Utils = require("app.utils.Utils");
GameData = require("app.data.GameData");

Audio = require("packages.audio.Audio");				-- 声音相关接口
Str = require("app.data.stringData");					-- 中文文本
UserDataMgr = require("app.data.UserDataMgr");			-- 玩家的数据
BattleDataMgr = require("app.data.BattleDataMgr");		-- 战斗中使用的数据
FortDataMgr = require("app.data.FortDataMgr");			-- 炮台的数据
ShipDataMgr = require("app.data.ShipDataMgr");			-- 战舰的数据
ItemDataMgr = require("app.data.ItemDataMgr");			-- 玩家的物品数据
ServerCode = require("app.constants.code")				-- 服务器的错误码
ProduceDataMgr = require("app.data.ProduceDataMgr");	-- 生产的数据
EscortDataMgr = require("app.data.EscortDataMgr");		-- 护送贩售舰的数据
MailDataMgr = require("app.data.MailDataMgr");			-- 邮件系统的数据
FriendDataMgr = require("app.data.FriendDataMgr");		-- 好友相关的数据
RevengeDataMgr = require("app.data.RevengeDataMgr");	-- 复仇相关的数据
ChatDataMgr = require("app.data.ChatDataMgr");			-- 聊天相关的数据
-------------
-- 游戏入口 --
-------------
local function main()
	Network:init()
	Audio:init()
	Utils:ctor();
	GameData:ctor();

	--初始化数据表
	ItemDataMgr:Init();
	FortDataMgr:Init();
	ProduceDataMgr:Init();
	UserDataMgr:Init();
	ShipDataMgr:Init();
	EscortDataMgr:Init();
	MailDataMgr:Init();
	FriendDataMgr:Init();
	RevengeDataMgr:Init();
	ChatDataMgr:Init();

	-- App = require("app.MyApp"):create() -- 创建APP
	App:ctor();    
    App:run() --从正常游戏流程启动，调用AppBase的run方法
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(" ~ main.lua ~ ", msg);
end
