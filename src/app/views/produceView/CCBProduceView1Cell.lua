local ResourceMgr = require("app.utils.ResourceMgr");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

local CCBProduceView1Cell = class("CCBProduceView1Cell", function()
	return CCBLoader("ccbi/produceView/CCBProduceView1Cell.ccbi")
end)

function CCBProduceView1Cell:onEnter()
	
end

function CCBProduceView1Cell:onExit()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end
end

function CCBProduceView1Cell:ctor()
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self:enableNodeEvents();
end

function CCBProduceView1Cell:setInfoByCellIndex(cellIndex)
	self.m_showInfo = ProduceDataMgr:getProduceQueue()[cellIndex+1];

	local cellState = self.m_showInfo.isLock;
	if cellState == false then
		local produceItemID = self.m_showInfo.produceItemID;
		if produceItemID == -1 then
			self:setStateNoProducing();
		else
			self:setStateProducing();
		end
	else
		self:setStateLocking();
	end
end

function CCBProduceView1Cell:setStateLocking()
	self.m_ccbNodeStateLocking:setVisible(true);
	self.m_ccbNodeStateProducing:setVisible(false);	
	self.m_ccbNodeStateNoProducing:setVisible(false);
	self.m_ccbSpriteLocking:setVisible(true);
	self.m_ccbSpriteLight:setVisible(false);
	self.m_ccbNodeUnderLightAnim:removeAllChildren();
	self.m_ccbLabelState:setString(Str[20003]);
	self.m_ccbSpriteProducingIconBg:setVisible(false);
	self.m_ccbNodeOnLightAnim:removeAllChildren();

	--显示解锁需求，只显示下一个解锁
	local lastCellShowInfo = ProduceDataMgr:getProduceQueue()[self.m_showInfo.queuePos-1];
	if lastCellShowInfo.isLock == true then --上一个生产位置是未解锁则该开启条件不显示
		self.m_ccbNodeRichTextRequire:setVisible(false);
		self.m_ccbBtnUnlock:setVisible(false);
		self.m_ccbSpriteUnLockText:setVisible(false);
	else
		self.m_ccbBtnUnlock:setVisible(true);
		self.m_ccbSpriteUnLockText:setVisible(true);

		self.m_ccbNodeRichTextRequire:removeAllChildren();
		local richText = ccui.RichText:create();
		local reimg = ccui.RichElementImage:create(2, cc.c3b(255, 255, 255), 255, "res/images/icon_4010_button.png");
		local text = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, self.m_showInfo.require_items[1].count, "font/simhei.ttf", 25);
		richText:pushBackElement(reimg);
	    richText:pushBackElement(text);
		self.m_ccbNodeRichTextRequire:addChild(richText);
		self.m_ccbNodeRichTextRequire:setVisible(true);
	end
end

function CCBProduceView1Cell:setStateProducing()
	self.m_ccbNodeStateLocking:setVisible(false);
	self.m_ccbNodeStateProducing:setVisible(true);
	self.m_ccbNodeStateNoProducing:setVisible(false);
	self.m_ccbSpriteLocking:setVisible(false);
	self.m_ccbSpriteLight:setVisible(true);
	self.m_ccbSpriteProducingIconBg:setVisible(true);
	self.m_ccbNodeOnLightAnim:removeAllChildren();

	self.m_ccbNodeUnderLightAnim:addChild(ResourceMgr:getProducingArmature());

	self.m_ccbNodeIcon:removeAllChildren();
	local nodeIcon = ResourceMgr:getProduceItemWithEffect(self.m_showInfo.produceItemID, self.m_showInfo.produceItemCount)
	self.m_ccbNodeIcon:addChild(nodeIcon);

	self.m_ccbLabelState:setString(ItemDataMgr:getItemNameByID(self.m_showInfo.produceItemID));

	local pastTime = os.time() - self.m_showInfo.produceTime
	local showLeftTime = self.m_showInfo.produceLeftTime - pastTime;
	if showLeftTime > 0 then
		if self.m_ccbLabelLeftTime == nil then
			self.m_ccbLabelLeftTime = cc.LabelBMFont:create(str, "res/font/produce_time.fnt")
		    self.m_ccbLabelLeftTime:setAnchorPoint(cc.p(0.5, 0.5))
		    self.m_ccbLabelLeftTime:setPosition(cc.p(self.m_ccbNodeLeftTime:getPositionX(), self.m_ccbNodeLeftTime:getPositionY()))
		    self.m_ccbNodeStateProducing:addChild(self.m_ccbLabelLeftTime)
		end

		self.m_ccbLabelLeftTime:setString(self:showTimeFormat(showLeftTime));
		if self.m_updateScheduler == nil then
			self.m_showInfo.isAnimUpdateScheduler = true;
			self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(function() 
				showLeftTime = showLeftTime - 1;
				if showLeftTime < 1 then
					showLeftTime = 0;
					if self.m_updateScheduler then
						self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
						self.m_updateScheduler = nil;

						local armature = ResourceMgr:getProduceViewArmature("fx_ui_prod_finish");
						self.m_ccbNodeOnLightAnim:addChild(armature);
						armature:getAnimation():play("anim01");
						armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
							if movementType == ccs.MovementEventType.complete then
								self.m_ccbNodeOnLightAnim:removeAllChildren();
							end
						end)
					end
				end
				self.m_ccbLabelLeftTime:setString(self:showTimeFormat(showLeftTime));
			end, 1, false);
		end
	end
end

function CCBProduceView1Cell:showTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBProduceView1Cell:setStateNoProducing()
	self.m_ccbNodeStateLocking:setVisible(false);
	self.m_ccbNodeStateProducing:setVisible(false);
	self.m_ccbNodeStateNoProducing:setVisible(true);
	self.m_ccbSpriteLocking:setVisible(false);
	self.m_ccbSpriteLight:setVisible(true);
	self.m_ccbNodeUnderLightAnim:removeAllChildren();
	self.m_ccbLabelState:setString(Str[20004]);
	self.m_ccbSpriteProducingIconBg:setVisible(false);
	self.m_ccbNodeOnLightAnim:removeAllChildren();
end

function CCBProduceView1Cell:onBtnUnlock()
	local itemID = self.m_showInfo.require_items[1].item_id;
	local haveCount = ItemDataMgr:getItemCount(itemID);
	local needCount = self.m_showInfo.require_items[1].count;
	
	if haveCount >= needCount then
		local hintContent = string.format(Str[4013], needCount);
		local ccbMessageBox = CCBMessageBox:create(Str[3013], hintContent, MB_OKCANCEL);-- 标题：解锁，提示内容：是否花费%d个扩充道具进行解锁？
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
			self.m_ccbSpriteLocking:setVisible(false);
			self.m_ccbNodeUnlockAnim:removeAllChildren()
			local unlockArmature = ResourceMgr:getProducePosUnlockArmature()
			self.m_ccbNodeUnlockAnim:addChild(unlockArmature);

			App:getRunningScene():getViewBase().m_ccbProduceView1:setTableViewTouchEnabled(false);
			ResourceMgr:setArmatureMovementEvent(unlockArmature, self.requestUnlockNewQueue)
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local ccbMessageBox = CCBMessageBox:create(Str[3005], Str[10015], MB_OKCANCEL); -- 标题：材料不足，提示内容：您当前材料不足，是否前去商店购买。
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();

			CCBCommonGetPath:create(itemID);
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	end
end

function CCBProduceView1Cell:requestUnlockNewQueue()
	Network:request("game.itemsHandler.unlockProduceQueue", "", function (rc, receiveData)--这里只发请求，列表状态更新统一由一个notify处理
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
		end
	end);

	App:getRunningScene():getViewBase().m_ccbProduceView1:setTableViewTouchEnabled(true);
end

function CCBProduceView1Cell:onBtnShowView2()
	ProduceDataMgr:setCurProducePos(self.m_showInfo.queuePos);
	App:enterScene("ProduceScene2");
end

function CCBProduceView1Cell:onBtnSpeedUp()
	ProduceDataMgr:setProduceSpeedUpPos(self.m_showInfo.queuePos)
	App:getRunningScene():getViewBase().m_ccbProduceView1:createViewSpeedUp(self);
end

return CCBProduceView1Cell