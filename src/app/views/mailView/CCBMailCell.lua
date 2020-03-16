---------------
-- 邮件列表子控件
---------------
local ResourceMgr = require("app.utils.ResourceMgr");

local CCBMailCell = class("CCBMailCell", function ()
	return CCBLoader("ccbi/mailView/CCBMailCell.ccbi")
end)

local colorReaded = cc.c3b(123, 123, 123)
local colorUnread = cc.c3b(255, 255, 255)
local iconScale = 0.5;
-- local g_isCellBeTouch = 0

function CCBMailCell:ctor()
	self:cleanData();
end

-- 邮件SetData，设置数据
function CCBMailCell:setData(data)
	-- dump(data)
	self:cleanData()

	self.data = data
	self.m_ccbLabelTitle:setString(data.title) -- 邮件标题文本
	self.m_ccbLabelDate:setString(data.created_at) -- 邮件时间文本
	self:setIconByPresent(data.mail_state) --邮件图标
	-- 设置背景。
	self.m_ccbNodeMailBg:addChild(cc.Sprite:create(ResourceMgr:getMailUnreadBg()));
	if data.mail_state ~= 0 then
		self.m_ccbNodeGraySelect:addChild(cc.Sprite:create(ResourceMgr:getMailReadGrayBg()));
	end
	if MailDataMgr:getCurTouchMailData() and MailDataMgr:getCurTouchMailData().id == data.id then
		local sprite = cc.Sprite:create(ResourceMgr:getMailSelectFrame());
		self.m_ccbNodeGraySelect:addChild(sprite);
	end
end

-- 清除数据，为设置数据时用。
function CCBMailCell:cleanData()
	self.m_ccbLabelTitle:setString("");
	self.m_ccbLabelDate:setString("");
	self.m_ccbNodeIcon:removeAllChildren();
	self.m_ccbNodeMailBg:removeAllChildren();
	self.m_ccbNodeGraySelect:removeAllChildren();
end

-- 返回出这个Cell ，也就是这封邮件的Data
function CCBMailCell:getCellData()

	-- dump(self.data)
	return self.data
end


-- 设置与后台所改动的 mail_state 的值一样 
function CCBMailCell:setMail_state()
	-- print(#self.data.attachment,"                  *********    attachment   ")
	if self.data.mail_state ~= 4 then
		if #self.data.attachment == 0 then
			self.data.mail_state = 1
		else
			self.data.mail_state = 3
		end
	end
end


-- 根据mail_state的多少值，设置邮件图标
-- 0 未读， 1 已读， 2已删除， 3 有附件未领取 4 有附件已领取
function CCBMailCell:setIconByPresent(state)
	-- self.node_icon:removeAllChildren()
	-- TODO:update
	-- 1 礼物 2 信封 3 开了的信封
	if state == 0 then
		if #self.data.attachment == 0 then 
			self.m_ccbNodeIcon:addChild(cc.Sprite:create(ResourceMgr:getMailTypeIcon(2)));
		else 
			self.m_ccbNodeIcon:addChild(cc.Sprite:create(ResourceMgr:getMailTypeIcon(1)));
		end
	elseif state == 1 then 
		self.m_ccbNodeIcon:addChild(cc.Sprite:create(ResourceMgr:getMailTypeIcon(3)));
	elseif state == 3 then
		self.m_ccbNodeIcon:addChild(cc.Sprite:create(ResourceMgr:getMailTypeIcon(1)));
	elseif state == 4 then
		self.m_ccbNodeIcon:addChild(cc.Sprite:create(ResourceMgr:getMailTypeIcon(3)));
	end

end

-- 点击邮件 📧 保存数据，为实现邮件标记框的显示 ,及对点击Cell的保存
function CCBMailCell:onTouchMailCell()

	if self.data then
		MailDataMgr:setCurTouchMailData(self.data);
	end
end

return CCBMailCell