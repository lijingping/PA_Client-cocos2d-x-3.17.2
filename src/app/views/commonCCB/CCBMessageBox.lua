local CCBMessageBox = class("CCBMessageBox", function ()
	return CCBLoader("ccbi/commonCCB/CCBMessageBox.ccbi")
end)

--按钮声明	
MB_OK = 1;			-- 一个“确定”按钮
MB_OKCANCEL = 2;	-- 一个“确定”按钮，一个“取消”按钮
MB_YESNO = 3;		-- 一个“是”按钮，一个“否”按钮
MB_RETRYCANCEL = 4;	-- 一个“重试”按钮， 一个“取消”按钮

function CCBMessageBox:ctor(title, text, btnType)--参数1:标题，参数2：提示内容，参数3：按钮显示类型
	if display.resolution  >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	local listener=cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function() return true; end, cc.Handler.EVENT_TOUCH_BEGAN);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);
	listener:setSwallowTouches(true);

	if title and title ~= "" and string.len(title) ~= 0 then
		self.m_ccbLabelViewTitle:setString(title);
	end

	if text and text ~= "" and string.len(text) ~= 0 then
		self.m_ccbLabelComtent:setString(text);
	end

	if btnType == MB_OK then		
		self.m_ccbBtnOK:getTitleLabel():setString(Str[1001]);		--“确定”
		self.m_ccbBtnOK:setPositionX(0);
		self.m_ccbBtnCancel:setVisible(false);
	elseif btnType == MB_OKCANCEL then
		self.m_ccbBtnOK:getTitleLabel():setString(Str[1001]);		--“确定”
		self.m_ccbBtnCancel:getTitleLabel():setString(Str[1002]);	--“取消”
	elseif btnType == MB_YESNO then
		self.m_ccbBtnOK:getTitleLabel():setString(Str[1003]);		--“是”
		self.m_ccbBtnCancel:getTitleLabel():setString(Str[1004]);	--“否”
	elseif btnType == MB_RETRYCANCEL then
		self.m_ccbBtnOK:getTitleLabel():setString(Str[1015]);		--“重试”
		self.m_ccbBtnCancel:getTitleLabel():setString(Str[1002]);	--“取消”
	end

	self:addTo(App:getRunningScene(), display.Z_MESSAGE_HINT-1, display.Z_MESSAGE_HINT-1);
end

function CCBMessageBox:setTitel(title)
	if title and title ~= "" and string.len(title) ~= 0 then
		self.m_ccbLabelViewTitle:setString(title);
	end
end

function CCBMessageBox:setText(text)
	if text and text ~= "" and string.len(text) ~= 0 then
		self.m_ccbLabelComtent:setString(text);
	end	
end

function CCBMessageBox:onBtnOK()

end

function CCBMessageBox:onBtnCancel()

end


return CCBMessageBox