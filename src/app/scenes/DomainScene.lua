local Tips = require("app.views.common.Tips");

local DomainScene = class("DomainScene", require("app.scenes.GameSceneBase"));

function DomainScene:init()
	print("DomainScene:init() 初来乍到。")
	self:initView("domainBattleView.DomainBattleView");
	self:requestDomainInfo();
end

function DomainScene:requestDomainInfo()
	Network:request("domain_battle.domainHandler.queryInfo", nil, function(rc, data)
		if data.code ~= 1 then
			Tips:create("请求公域混战界面信息失败");
			-- App:enterScene("MainScene");
			return;
		end
 -- 	dump(data);
 -- 	"<var>" = {
 --     "code"                  = 1
 --     "next_add_need_diamond" = 10
 --     "player_info" = {
 --         "damage"           = 0
 --         "damage_add_times" = 0
 --         "nickname"         = "布朗伊芙"
 --         "remain_times"     = 5
 --         "uid"              = "cfcde2685ab4a9c2360e6bd6d2caf292"
 --     }
 --     "rank_ten_info" = {
 --     }
 --     "receive_info" = {
 --         1 = 0
 --         2 = 0
 --         3 = 0
 --         4 = 0
 --         5 = 0
 --     }
 --     "remain_second"         = 1535224083255
 -- }
 		-- dump(data);

		App:getRunningScene():getViewBase():setViewData(data);
	end)
end

-- function DomainScene:updateMoney()
-- 	print("更新 金币，  钻石 。  ");
-- 	self.m_headBar:UpdateInfo();
-- end


return DomainScene;