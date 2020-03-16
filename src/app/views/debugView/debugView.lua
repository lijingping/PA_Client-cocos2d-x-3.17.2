-- local ResourceTool = require("app.utils.ResourceTool")
--local Crypto = require("app.utils.Crypto")
--local ScrollView = require("app.views.common.ScrollView")


---------------------
-- 用于测试, 作弊码入口
---------------------
local debugView = class("debugView", function ()
  return CCBLoader("ccbi/debugView/debugView.ccbi")
end)
function debugView:ctor()
	-- ResourceTool:addFrameCache("loginView")
    if display.resolution >= 2 then
        self:setScale(display.reduce);
    end
    
  --self:createTouchEvent();
	self:init()
end

function debugView:createTouchEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)--设为false向下传递触摸
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColorShelter)
end

function debugView:onTouchBegan(touch, event)
    print("touchbegin")
    return true;
end

function debugView:onTouchMoved(touch, event)
    
end

function debugView:onTouchEnded(touch, event)

end

function debugView:init()
	local size = self.layer_input:getContentSize()
	local spriteEditBox = cc.Scale9Sprite:create("resources/loginView/login_input.png")
	-- spriteEditBox:initWithSpriteFrameName()
	spriteEditBox:setContentSize(size)

	local editBox = cc.EditBox:create(size, spriteEditBox, nil, nil);

    editBox:setFontSize(28)
    editBox:setFontColor(cc.c3b(255,255,255))
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	editBox:setAnchorPoint(cc.vec2(0,0))
    self.layer_input:add(editBox)

    self.editBox = editBox

  	local data = {
  		cmd = "help",
  	}

  local scrollView = ccui.ScrollView:create();
  scrollView:setContentSize(self.layer_content:getContentSize());
  scrollView:setBounceEnabled(true);
  scrollView:setScrollBarEnabled(false);
  self.layer_content:add(scrollView);
  scrollView:setInnerContainerSize(cc.size(900, 1100));


  local label = cc.Label:createWithTTF("", "res/font/simhei.ttf", 20);
  label:align(cc.p(0,1), 0, scrollView:getInnerContainerSize().height);
	scrollView:add(label);

	--关闭按钮	
	local btnClose = ccui.Button:create("res/resources/common/btn2_close2_n.png", 
												"res/resources/common/btn2_close2_h.png",
												"res/resources/common/btn2_close2_n.png")
    btnClose:setAnchorPoint(cc.p(0, 0))
    btnClose:setPosition(cc.p( display.cx + display.width * 0.5 * 0.8, 630))
    btnClose:addClickEventListener(function() self:removeSelf() end)
    self.m_ccbNodeCenter:add(btnClose)

	--创建所有物品，
	local btnAddAllItem = ccui.Button:create("res/resources/common/btn2_green_n.png", 
												"res/resources/common/btn2_green_h.png",
												"res/resources/common/btn2_green_n.png")
    
    btnAddAllItem:setAnchorPoint(cc.p(0, 0))
    btnAddAllItem:setPosition(cc.p( display.cx + display.width * 0.5 * 0.43, 468))
    btnAddAllItem:addClickEventListener(function() 
        Network:request("game.cheatHandler.exec", { cmd = "item add_all" }, function(rc, data) end);
    end)
    btnAddAllItem:setTitleText("添加物品");
    btnAddAllItem:setTitleFontSize(20);
    --btnAddAllItem:setEnabled(false);
    self.m_ccbNodeCenter:add(btnAddAllItem);

  Network:request("game.cheatHandler.exec", data, function(rc, data)
    label:setString(data.result);
  end);

	--邮件
	local btnAddAllItem2 = ccui.Button:create("res/resources/common/btn2_green_n.png", 
												"res/resources/common/btn2_green_h.png",
												"res/resources/common/btn2_green_n.png")
    
    btnAddAllItem2:setAnchorPoint(cc.p(0, 0))
    btnAddAllItem2:setPosition(cc.p( display.cx + display.width * 0.5 * 0.43, 396))
    btnAddAllItem2:addClickEventListener(function() 

    	local content = { cmd = "mail add_mail system 测试内容1 测试标题1 [] []" }
	    Network:request("game.cheatHandler.exec", content, function(rc, data)
			--label:setString(data.result)
		end);
	 --    local content = { cmd = "mail new_mail system 0 测试内容 测试标题 1001 66 2001 76" }
	 --    Network:request("game.cheatHandler.exec", content, function(rc, data)
		-- 	label:setString(data.result)
		-- end);
	end)


	btnAddAllItem2:setTitleText("添加邮件");
	btnAddAllItem2:setTitleFontSize(20);
  self.m_ccbNodeCenter:add(btnAddAllItem2);

    -- 添加金币
    local btnAddCoin = ccui.Button:create("res/resources/common/btn2_green_n.png", 
    										"res/resources/common/btn2_green_h.png",
												"res/resources/common/btn2_green_n.png")
    btnAddCoin:setAnchorPoint(cc.p(0, 0));
    btnAddCoin:setPosition(cc.p(display.cx + display.width * 0.5 * 0.43, 320));
    btnAddCoin:addClickEventListener(function()
    	local content = {cmd = "item add 10001 100000"};
    	Network:request("game.cheatHandler.exec", content, function(rc, data)
			--label:setString(data.result)
		end);
    end)
    btnAddCoin:setTitleText("10万Coins");
    btnAddCoin:setTitleFontSize(20);
    self.m_ccbNodeCenter:add(btnAddCoin);

    -- 添加钻石
    local btnAddDiamond = ccui.Button:create("res/resources/common/btn2_green_n.png", 
    										"res/resources/common/btn2_green_h.png",
												"res/resources/common/btn2_green_n.png")
    btnAddDiamond:setAnchorPoint(cc.p(0, 0));
    btnAddDiamond:setPosition(cc.p(display.cx + display.width * 0.5 * 0.43, 245));
    btnAddDiamond:addClickEventListener(function()
    	local content = {cmd = "item add 10002 100000"};
    	Network:request("game.cheatHandler.exec", content, function(rc, data)
			--label:setString(data.result)
		end);
    end)
    btnAddDiamond:setTitleText("10万diamonds");
    btnAddDiamond:setTitleFontSize(20);
    self.m_ccbNodeCenter:add(btnAddDiamond);

    -- 请求人机
    local btnAddDiamond = ccui.Button:create("res/resources/common/btn2_green_n.png", 
                                            "res/resources/common/btn2_green_h.png",
                                                "res/resources/common/btn2_green_n.png")
    btnAddDiamond:setAnchorPoint(cc.p(0, 0));
    btnAddDiamond:setPosition(cc.p(display.cx + display.width * 0.5 * 0.43, 170));
    btnAddDiamond:addClickEventListener(function()
        local content = {cmd = "battle.battleHandler.fight_with_robot"};
        Network:request("battle.battleHandler.fight_with_robot", content, function(rc, data)
            --label:setString(data.result)
        end);
    end)
    btnAddDiamond:setTitleText("请求人机");
    btnAddDiamond:setTitleFontSize(20);
    self.m_ccbNodeCenter:add(btnAddDiamond);

        -- 请求BOSS
    local btnAddDiamond = ccui.Button:create("res/resources/common/btn2_green_n.png", 
                                            "res/resources/common/btn2_green_h.png",
                                                "res/resources/common/btn2_green_n.png")
    btnAddDiamond:setAnchorPoint(cc.p(0, 0));
    btnAddDiamond:setPosition(cc.p(display.cx + display.width * 0.5 * 0.43, 95));
    btnAddDiamond:addClickEventListener(function()
        local content = {cmd = "domain_battle.domainHandler.attackBoss"};
        Network:request("domain_battle.domainHandler.attackBoss", content, function(rc, data)
            --label:setString(data.result)
        end);
    end)
    btnAddDiamond:setTitleText("公域混战");
    btnAddDiamond:setTitleFontSize(20);
    self.m_ccbNodeCenter:add(btnAddDiamond);

    --提高等级
    local btnAddLevel = ccui.Button:create("res/resources/common/btn2_green_n.png", 
                                           "res/resources/common/btn2_green_h.png",
                                           "res/resources/common/btn2_green_n.png")
    btnAddLevel:setAnchorPoint(cc.p(0, 0));
    btnAddLevel:setPosition(cc.p(display.cx + display.width * 0.5 * 0.43 , 20));
    btnAddLevel:addClickEventListener(function()
   local playerLevel = UserDataMgr:getPlayerLevel()
    local level =  playerLevel + 5; 
        local content = {cmd = "player level " .. level};
        Network:request("game.cheatHandler.exec", content, function(rc, data)
            --label:setString(data.result)
        end);
    end)
    btnAddLevel:setTitleText("提高等级");
    btnAddLevel:setTitleFontSize(20);
    self.m_ccbNodeCenter:add(btnAddLevel);
end

function debugView:OnSendClicked()

	local cheatCode = self.editBox:getText()

	if cheatCode == "reconnect" then
		Network:reconnect()
		return
	end

	if cheatCode == "allitem" then
		local items = table.clone(require("app.constants.item"))
		for k, v in pairs(items) do
		  	local data = {
				cmd = "item add " .. v.id,
  			}
		  	Network:request("game.cheatHandler.exec", data, function(rc, data)
				display.getRunningScene():info(data.result)
			end);
		end
		self:removeSelf()

		return
	end

	if cheatCode == "disconnect" then
		Network:disconnect(function ()
			print("disconnect OK!")
		end)
		return
	end


  	local data = {
  		cmd = cheatCode,
  	}

  	Network:request("game.cheatHandler.exec", data, function(rc, data)
		display.getRunningScene():info(data.result)
	end);

  	self:removeSelf()
end

return debugView