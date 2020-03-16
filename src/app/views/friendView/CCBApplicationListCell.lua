---------------------
-- 好友申请列表子控件
---------------------
local RankIcon = require("app.views.common.RankIcon");
local ResourceMgr = require("app.utils.ResourceMgr");

local CCBApplicationListCell = class("CCBApplicationListCell", function ()
	return CCBLoader("ccbi/friendView/CCBApplicationListCell.ccbi")
end)


function CCBApplicationListCell:ctor()

end

function CCBApplicationListCell:setShowInfo(info)
	-- body
	-- dump(info);
	if info.nickname == nil or info.nickname == "" then
		info.nickname = "玩家未取名（旧号）"
	end

	self.m_showInfo = info;

	self.m_ccbNodeIcon:removeAllChildren();
	local rankSprite = RankIcon:getZoomRankIcon(info.famous_num, 0.2);
	self.m_ccbNodeIcon:addChild(rankSprite);
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self.m_ccbLabelPower:setString("战斗力: ".. info.power);
end

function CCBApplicationListCell:onBtnRefuse()
	Network:request("social.friendHandler.reject_friend", {friend = self.m_showInfo.uid}, function (rc, receiveData)
		--print("拒绝好友请求")
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		App:getRunningScene():getViewBase().m_ccbFriendView:requestApplicationList();
	end)
end

function CCBApplicationListCell:onBtnAdd()
	Network:request("social.friendHandler.accept_friend", {friend = self.m_showInfo.uid}, function (rc, receiveData)
		--print ( "接受好友申请 ")
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		App:getRunningScene():getViewBase().m_ccbFriendView:requestApplicationList();
	end)	
end



-- 接受按钮点击事件
function CCBApplicationListCell:onBtnCellProposeAccept()
	App:getRunningScene():requestAcceptFriend(self.data);
end

-- 拒绝按钮点击事件
function CCBApplicationListCell:onBtnCellProposeRefuse()
	App:getRunningScene():requestRejectFriend(self.data);
end

function CCBApplicationListCell:setData(data)
	self.data = data
	-- dump(data)
	-- - "<var>" = {
	-- -     "famous_num" = 0
	-- -     "icon"       = "default"
	-- -     "level"      = 1
	-- -     "nickname"       = "test_02"
	-- -     "power"      = 0
	-- -     "uid"        = "cfcde268585b83e52760e9da5d135925"
	-- - }

	local name = data.nickname or "***"
	local power = data.power or 0
	local grade = data.famous_num or 0
	local icon = data.icon

	self.m_ccbLabelName:setString(name)
	self.m_ccbLabelPower:setString(Str[5011] .. ": "..power)
	self:setGrade(grade);
	self:setIcon(icon);
end

function CCBApplicationListCell:setGrade(grade)
	
	local rankExp = table.clone(require("app.constants.rank_exp"))

	local icon = "";
	local rankName = "";
	local level = 0;

	for k, v in pairs(rankExp) do
		if tonumber(k) < 12 then
			if grade >= rankExp[k].exp and grade < rankExp[tostring(tonumber(k) + 1)].exp then
				icon = rankExp[k].id_icon;
				rankName = rankExp[k].name;
				level = rankExp[k].level
				break;
			end  
		else
			if grade >= rankExp[k].exp then
				icon = rankExp[k].id_icon;
				rankName = rankExp[k].name;
				level = rankExp[k].level;
				break;
			end
		end
	end
	local spriteIcon = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(level));
	spriteIcon:setScale(0.8);
	self.m_ccbNodeIcon:addChild(spriteIcon);

	self.m_ccbLabelGrade:setString(Str[5010] .. ": " .. rankName);
end

function CCBApplicationListCell:setIcon(icon)
	--TODO: set icon
end

return CCBApplicationListCell