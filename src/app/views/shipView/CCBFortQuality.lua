local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");

-----------------
-- 炮台品级进阶窗口
-----------------
local CCBFortQuality = class("CCBFortQuality", function ()

	return CCBLoader("ccbi/shipView/CCBFortQuality.ccbi")
end)

function CCBFortQuality:ctor()
	-- print("--------------CCBFortQuality:ctor") 
	self.m_userDesignCount = 0;
	self.m_needDesignCount = 0;
	self.m_fortQuality = -1;
	self.m_fortLevel = 0;
	self:init()
end

--进度条
function CCBFortQuality:init()
	-- local loadingBar = ccui.LoadingBar:create()
	-- loadingBar:loadTexture(ResourceMgr:getFortQualityProgressBar())
	-- loadingBar:setScale9Enabled(true)
	-- loadingBar:setCapInsets(cc.rect(0, 0, 0, 0))
	-- loadingBar:setContentSize(cc.size(300, 54))
	-- loadingBar:setDirection(ccui.LoadingBarDirection.LEFT)
	-- loadingBar:setPercent(0)
	local loadingBarSprite = cc.Sprite:create(ResourceMgr:getFortQualityProgressBar());
	local loadingBar = cc.ProgressTimer:create(loadingBarSprite);
	loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	loadingBar:setBarChangeRate(cc.p(1, 0));
	loadingBar:setPercentage(0);
	loadingBar:setMidpoint(cc.p(0, 0));
	self.m_loadingBar = loadingBar
	self.m_ccbLayerMapBar:addChild(loadingBar);
	-- loadingBar:setPosition(-2, 2);
	self.m_ccbLabelMapCount:setLocalZOrder(1)
end

function CCBFortQuality:setData(data)
	-- dump(data)
	--     "advance_item" = 3001
	--     "fort_desc"    = "NO.1炮台"
	--     "fort_name"    = "零式刀锋"
	--     "fort_type"    = 1
	--     "id"           = 90001
	--     "skill_id"     = 50001
	--     "star_const"   = 1
	-- }

	if not data then
		print("data is nil")
		return
	end
	local fortID = data.id;
	local quality = FortDataMgr:getUnlockFortQuality(fortID);

	if self.m_fortQuality ~= quality then
			
		self:cleanData();
		self.m_fortQuality = quality;
		self.m_data = data;

		self.m_ccbNodeBtnLabelSprite:setVisible(true)
		self.m_ccbLabelMapCount:setVisible(true)
		self.m_ccbLabelLevelLimit:setVisible(true)
		self.m_ccbLabelNeedLevel:setVisible(true)

		local drawingId = data.advance_item; --设计图的IconID
		if not drawingId then
			print("drawingId is nil")
			return
		end
		local itemLevel = ItemDataMgr:getItemLevelByID(drawingId);
		self.m_ccbNodeDesignIcon:addChild(cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel + 1)));
		self.m_ccbNodeDesignIcon:addChild(cc.Sprite:create(ResourceMgr:getFortIconByID(drawingId)));
		self.m_ccbNodeDesignIcon:addChild(cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1))); -- 设计图纸边框是2级边框

		if quality == 5 then -- 当品质达到最大
			self.m_ccbNodeBtnLabelSprite:setVisible(false)
			self.m_loadingBar:setPercentage(100);
			-- self.m_ccbLabelMapCount:setVisible(false)
			self.m_ccbLabelMapCount:setString("MAX");
			self.m_ccbLabelLevelLimit:setVisible(false)
			self.m_ccbLabelNeedLevel:setVisible(false)
			-- local lastQuality = quality
			-- local lastId = data.id
			-- local lastData = FortDataMgr:getUnlockFortDataByID(fortID)
			local spritePosX = self.m_ccbBtnUpQuality:getPositionX();
			local spritePosY = self.m_ccbBtnUpQuality:getPositionY();
			local maxBtnSprite = cc.Sprite:create(ResourceMgr:getMaxSkillLevelSprite());
			self:addChild(maxBtnSprite);
			maxBtnSprite:setPosition(cc.p(spritePosX, spritePosY));

			self:updateQualitySprite(quality);
			self:updateMaxLevel(quality);
			return;

		end

		self.m_fortId = fortID;

		local advanceData = GameData:get("fort_advance", quality+1); 
		-- dump(advanceData); -- 获取需要设计图纸的数量和消耗的金币数
		self.m_ccbLabelCoinCount:setString(advanceData.consume_coin)

		local resItemCount = ItemDataMgr:getItemCount(drawingId);
		self.m_needDesignCount = advanceData.consume_item;
		if resItemCount <= 0 then
			self.m_ccbLabelMapCount:setString("0 / " .. self.m_needDesignCount);
			self.m_loadingBar:setPercentage(0);
			self.m_userDesignCount = 0;
		else
			self.m_ccbLabelMapCount:setString(resItemCount .. " / " .. advanceData.consume_item);
			if resItemCount < self.m_needDesignCount then
				self.m_loadingBar:setPercentage(resItemCount/advanceData.consume_item * 100);
			else
				self.m_loadingBar:setPercentage(100);
			end
			self.m_userDesignCount = resItemCount;
		end

		local level = "LV"..advanceData.required_level or "nil"
		self.m_limitLevel = advanceData.required_level;
		self.m_ccbLabelNeedLevel:setString(level)

		self:updateQualitySprite(quality)
		self:updateMaxLevel(quality)

		self.m_ccbBtnUpQuality:setEnabled(quality ~= 5)
	end
end

function CCBFortQuality:cleanData()
	self.m_ccbNodeLeftCharacter:removeAllChildren();
	self.m_ccbNodeRightCharacter:removeAllChildren();
	self.m_ccbNodeDesignIcon:removeAllChildren();
end

function CCBFortQuality:updateQualitySprite(qualityStr)
	local leftRes = nil
	local rightRes = nil

	leftRes = ResourceMgr:getFortQualitySpriteByQualityNumber(qualityStr);
	if qualityStr < 5 then
		rightRes = ResourceMgr:getFortQualitySpriteByQualityNumber(qualityStr + 1);
	else
		rightRes = ResourceMgr:getFortMaxSprite();
	end

	if not leftRes or not rightRes then
		print("res is nil")
		return
	end

	local leftSprite = cc.Sprite:create(leftRes);
	self.m_ccbNodeLeftCharacter:addChild(leftSprite);
	-- leftSprite:setScale(1.5);
	local rightSprite = cc.Sprite:create(rightRes);
	self.m_ccbNodeRightCharacter:addChild(rightSprite);
	-- rightSprite:setScale(1.5);
	-- 获取精灵帧，是这样使用的。self.label_right_1 是一个在CCB 里面的精灵，把图片给这个精灵设置进去。
	-- local rightSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(rightRes)
	-- self.label_right_1:setSpriteFrame(rightSpriteFrame)
end

function CCBFortQuality:updateMaxLevel(qualityStr)
	local leftLevel = nil
	local rightLevel = nil

	if qualityStr == 1 then
		leftLevel = 20
		rightLevel = 40
	end

	if qualityStr == 2 then
		leftLevel = 40
		rightLevel = 60
	end

	if qualityStr == 3 then
		leftLevel = 60
		rightLevel = 80
	end

	if qualityStr == 4 then
		leftLevel = 80
		rightLevel = 99
	end

	if qualityStr == 5 then
		leftLevel = 99
		rightLevel = 99
	end

	self.m_ccbLabelLevelLeft:setString(leftLevel)
	self.m_ccbLabelLevelRight:setString(rightLevel)
end

function CCBFortQuality:onAdvanceTouched()

	 -- 进阶条件：先判断等级是否符合，再判断进阶材料是否足够
	-- print("  297  self.m_userDesignCount  self.m_needDesignCount", self.m_userDesignCount, self.m_needDesignCount);
	local str = nil;

    if UserDataMgr:getPlayerLevel() < self.m_limitLevel then  -- ①、等级不够FortDataMgr:getUnlockFortLevel(self.m_data.id)
        str = string.format(Str[7001], self.m_limitLevel);
        Tips:create(str);
    elseif self.m_userDesignCount < self.m_needDesignCount then  -- ②、材料不够
    	print("玩家设计图数量", self.m_userDesignCount, "升级需要设计图数量", self.m_needDesignCount);
        str = string.format(Str[7002],self.m_data.frot_name);
        Tips:create(str);
    else                    -- ③、等级材料都够就给服务器发消息。
        if self.m_fortId ~= nil then
        	-- self.m_ccbBtnUpQuality:setEnabled(false);
            Network:request("game.fortHandler.advanceFort", {fort_id = self.m_fortId}, function (rc, receivedData)
				print("---------------------请求进阶炮台------------------------")
				-- dump(receivedData)
				self.m_ccbBtnUpQuality:setEnabled(true);
				if receivedData["code"] ~= 1 then
					Tips:create(GameData:get("code_map", receivedData.code)["desc"]);
					return;
				end
				if App:getRunningScene():getChildByTag(150) then
					App:getRunningScene():getChildByTag(150):updataFortData();
					local equipFortData = FortDataMgr:getEquipFortData();
					if equipFortData[receivedData.fort.fort_id] ~= nil then
						App:getRunningScene():getChildByTag(150):setEquipFort();
					end
				end
				App:getRunningScene():getViewBase().m_ccbShipMainView:updateEquipFort(receivedData.fort.fort_id);
				Tips:create(FortDataMgr:getFortBaseName(receivedData.fort.fort_id) .. "成功进阶");
				self:playUpQualityAnim();
			end)
        end
	end
end

function CCBFortQuality:playUpQualityAnim()
	-- print("    CCBFortQuality:playUpQualityAnim() 播放品质提升动画   ");
	local upSuccessAnim = ResourceMgr:getCommonArmature("common_up");
	App:getRunningScene():addChild(upSuccessAnim, 200, 200);
	upSuccessAnim:setPosition(display.center);
	upSuccessAnim:getAnimation():play("anim01");
	upSuccessAnim:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			upSuccessAnim:removeSelf();
			upSuccessAnim = nil;
		end
	end);
end

return CCBFortQuality