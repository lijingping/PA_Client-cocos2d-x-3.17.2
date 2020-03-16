local CCBHelpView = class("CCBHelpView", function ()
	return CCBLoader("ccbi/helpView/CCBHelpView.ccbi")
end)

function CCBHelpView:ctor()
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self:createCoverLayer();

	self.m_helpViewCell = self.m_ccbScrollView:getChildren()[1];
	self.m_ccbScrollView.copyHeight = self.m_ccbScrollView:getContentSize().height;
	self:onBtnSlot(1);
end

function CCBHelpView:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBHelpView:onBtnSlot(index)
	for i=1, self.m_ccbNodeBtn:getChildrenCount() do
		self.m_ccbNodeBtn:getChildByTag(i):setEnabled(i ~= index);
		self.m_helpViewCell:getChildByTag(i):setVisible(i == index);
	end
	self.m_ccbLabelTitle:setString(Str[21000+index]);

	local size = self.m_helpViewCell:getChildByTag(index):getContentSize();
	if size.height < self.m_ccbScrollView.copyHeight then
		size.height = self.m_ccbScrollView.copyHeight；
	end
	self.m_ccbScrollView:setContentSize(size);
end

function CCBHelpView:onBtnPVP()
	self:onBtnSlot(1);
end

function CCBHelpView:onBtnExplore()
	self:onBtnSlot(2);
end

function CCBHelpView:onBtnEscort()
	self:onBtnSlot(3);
end

function CCBHelpView:onBtnDomain()
	self:onBtnSlot(4);
end

function CCBHelpView:onBtnClose()
	self:removeSelf();
	
	if App:getRunningScene():getViewBase().m_ccbMainView then
		App:getRunningScene():getViewBase().m_ccbMainView:onBtnSet();
	end
end

return CCBHelpView