-----------------------------------------
  ---------------资源  管理器------------
-----------------------------------------

local ResourceMgr = class("ResourceMgr");

-- 图片资源
local shipViewPath = "res/resources/shipView/";
local commonPath = "res/resources/common/";
local itemIconPath = "res/itemIcon/"
local imagesPath = "res/images/";
local fontPath = "res/font/";
local mainViewPath = "res/resources/mainView/";
local rankIconPath = "res/rankIcon/";
local escortViewPath = "res/resources/escortView/";
local domainViewPath = "res/resources/domainBattleView/";
local mailViewPath = "res/resources/mailView/";
local packageViewPath = "res/resources/packageView/";
local demoViewPath = "res/resources/demo/";

-- 动画资源
local animPathOthers = "res/anims/others/";
local animPathMain = "res/anims/mainAnim/";
local animPathEscort = "res/anims/escort/";
local animPathProduce = "res/anims/produce/";
local animPathShip = "res/anims/ship/";
local animPathCommon = "res/anims/common/";
local animPathPackage = "res/anims/package/";
local animPathDecompose = "res/anims/decompose/";
local animPathRankResult = "res/anims/rankResult/";
local animPathDomain = "res/anims/domain/";
local animPathDemo = "res/anims/demo/";
local planeIconPath = "res/planeIcon/";

local imageFormat = ".png";
local animFormat = ".ExportJson";


---------------------------------------------------------
------------------------通用接口--------------------------
---------------------------------------------------------

 --图标相关设定：标签1为背景，2为道具图标，3为数量背景，4为品质框，5为数量，6为名字，7为装备状态，8为特效动画
ICON_TAG_BG = 1;
ICON_TAG_PIC = 2;
ICON_TAG_COUNT_BG = 3;
ICON_TAG_FRAME = 4;
ICON_TAG_COUNT = 5;
ICON_TAG_NAME = 6;
ICON_TAG_EQUIPPED = 7;
ICON_TAG_SELECTED = 8;
ICON_TAG_RECEIVED_RANK_AWARD_SHADE = 9;
ICON_TAG_RECEIVED_RANK_AWARD_MARK = 10;

TAG_ITEM_TIPS = 100;

ICON_Z_ORDER_BG = 1;
ICON_Z_ORDER_PIC = 2;
ICON_Z_ORDER_COUNT_BG = 3;
ICON_Z_ORDER_FRAME = 4;
ICON_Z_ORDER_COUNT = 5;
ICON_Z_ORDER_NAME = 6;
ICON_Z_ORDER_EQUIPPED = 7;
ICON_Z_ORDER_SELECTED = 8;
ICON_Z_ORDER_RECEIVED_RANK_AWARD_SHADE = 9;
ICON_Z_ORDER_RECEIVED_RANK_AWARD_MARK = 10;

--不同品质对应的文字颜色
CCC3_TEXT_GREEN = cc.c3b(51, 204, 102);
CCC3_TEXT_BLUE = cc.c3b(51, 204, 255);
CCC3_TEXT_PURPLE = cc.c3b(204, 51, 255);
CCC3_TEXT_GOLDEN = cc.c3b(255,255, 75);

function ResourceMgr:createItemIcon(itemID)
	local node = cc.Node:create();
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID) + 1;

	cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel))
		:addTo(node, ICON_Z_ORDER_BG, ICON_TAG_BG);
	cc.Sprite:create(ResourceMgr:getItemIconByID(ItemDataMgr:getItemIconIDByItemID(itemID)))
		:addTo(node, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel))
		:addTo(node, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);

	return node;
end

--创建完整的物品小图标
function ResourceMgr:createSmallItemIcon(itemID, itemCount)
	if itemID == nil then
		return nil;
	end

	local node = cc.Node:create();
	
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_"..itemLevel..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_"..itemLevel..".png");

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);

	---------- 以上是图标通用的显示方式，底图，物品图标，外框 ----------

	self:setItemCount(node, itemCount);

	node:setScale(0.8);
	return node;	
end

--更改小图标上的物品数量
function ResourceMgr:setItemCount(nodeParent, itemCount)
	local labelIconCount = nodeParent:getChildByTag(ICON_TAG_COUNT);
	if labelIconCount then
	 	labelIconCount:setString(itemCount);
	else
		labelIconCount = cc.LabelTTF:create(itemCount, "", 20);
		labelIconCount:setPosition(cc.p(45, -48));
		labelIconCount:setAnchorPoint(cc.p(1, 0));	
		nodeParent:addChild(labelIconCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);
	end

	if tonumber(itemCount) > 0 then
		labelIconCount:setColor(cc.WHITE);
	else
	 	labelIconCount:setColor(cc.RED);
	end	
end

--设置物品是否显示装备状态
function ResourceMgr:setItemEquipState(nodeParent, isEquip)
	if isEquip then
		local spriteEquipState = nodeParent:getChildByTag(ICON_TAG_EQUIPPED);
		if spriteEquipState == nil then
			spriteEquipState = cc.Sprite:create("ui_item_label01.png");
			nodeParent:addChild(spriteEquipState, ICON_Z_ORDER_EQUIPPED, ICON_TAG_EQUIPPED);
		else
			spriteEquipState:setVisible(true);
		end
	else
		local spriteEquipState = nodeParent:getChildByTag(ICON_TAG_EQUIPPED);
		if spriteEquipState then
			spriteEquipState:setVisible(false);
		end
	end
end

--创建完整的物品大图标，显示名字和数量
function ResourceMgr:createItemIconWithNameAndCount(itemID, itemCount)
	if itemID == nil then 
		return nil;
	end

	local node = cc.Node:create();
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_"..itemLevel..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_"..itemLevel..".png");

	local labelIconName = cc.LabelTTF:create(ItemDataMgr:getItemNameByID(itemID), "", 20);
	labelIconName:setPosition(cc.p(0, -80));

	local labelIconCount = cc.LabelTTF:create(itemCount, "", 20);
	labelIconCount:setPosition(cc.p(55, -60));
	labelIconCount:setAnchorPoint(cc.p(1, 0));

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end
	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	node:addChild(labelIconCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);
	node:addChild(labelIconName, ICON_Z_ORDER_NAME, ICON_TAG_NAME);

	return node;
end

--动画播放完成事件
function ResourceMgr:setArmatureMovementEvent(armature, callFunction)
	if armature then
		armature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				callFunction(_, movementID)
			end
		end)
	end	
end

--动画帧事件
function ResourceMgr:setArmatureFrameEvent(armature, callFunction)
	if armature then
		armature:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			callFunction(_, evt);
		end)
	end
end

--炮台完整的炮台图标
function ResourceMgr:createFortIcon(fortID)
	
end

-- 字体
function ResourceMgr:getFont()
	return "res/resources/font/ui_font.fnt";
end

-- 战舰皮肤技能Icon
function ResourceMgr:getShipSkinSkillIcon(shipSkinSkillID)
	return itemIconPath .. "ship_skill_" .. shipSkinSkillID .. imageFormat;
end

-- 战舰炮台图标边框（道具等级1， 2， 3， quality + 1）
function ResourceMgr:getItemBoxFrameByQuality(quality)
	-- print(quality)
	return commonPath .. "item_frame_" .. quality .. imageFormat;
end

-- 图标黑色背景
function ResourceMgr:getItemBlackBG()
	return commonPath .. "item_default_bg" .. imageFormat;
end

-- 显示战舰炮台图标背景(item品质的 quality + 1)
function ResourceMgr:getItemBGByQuality(quality)                        
	return commonPath .. "item_bg_" .. quality .. imageFormat;
end

-- 道具图标
function ResourceMgr:getItemIconByID(ID)
	return itemIconPath  .. ID .. imageFormat;
end

-- 透明图片
function ResourceMgr:getAlpha0Sprite()
	return commonPath .. "alpha0" .. imageFormat;
end

-- item边框
function ResourceMgr:getItemBoxFrame()
	return commonPath .. "item_default_frame" .. imageFormat;
end

-- 炮台品质小图标
function ResourceMgr:getFortQualityIcon(quality)
	if quality == 1 then
		return commonPath .. "ui_grade_d" .. imageFormat;
	elseif quality == 2 then
		return commonPath .. "ui_grade_c" .. imageFormat;
	elseif quality == 3 then
		return commonPath .. "ui_grade_b" .. imageFormat;
	elseif quality == 4 then
		return commonPath .. "ui_grade_a" .. imageFormat;
	elseif quality == 5 then
		return commonPath .. "ui_grade_s" .. imageFormat; 
	else
		return commonPath .. "ui_icon_gold01" .. imageFormat;
	end
end

function ResourceMgr:getGreenBtnNormal()
	return commonPath .. "btn2_green_n" .. imageFormat;
end

function ResourceMgr:getGreenBtnHigh()
	return commonPath .. "btn2_green_h" .. imageFormat;
end

--  动画特效
function ResourceMgr:getAnimArmatureByNameOnOthers(animName)
	local animPath = animPathOthers .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getBtn03Red(stage)  -- 1 正常状态 2 高亮状态
	if stage == 1 then
		return commonPath .. "ui_btn_03red_n" .. imageFormat;
	elseif stage == 2 then
		return commonPath .. "ui_btn_03red_h" .. imageFormat;
	end
end

function ResourceMgr:getBtnSmallBlue(stage)
	if stage == 1 then
		return commonPath .. "ui_btn_smallblue_n" .. imageFormat;
	elseif stage == 2 then
		return commonPath .. "ui_btn_smallblue_h" .. imageFormat;
	end
end

-- 军衔图标
function ResourceMgr:getRankBigIconByLevel(level)
	return rankIconPath .. "icon_rank_" .. level .. imageFormat;
end

-- 军衔等级文字
function ResourceMgr:getRankTextByLevel(level)
	return rankIconPath .. "text_rank_" .. level .. imageFormat;
end

-- 联盟图标
function ResourceMgr:getLeagueBadgeByIconID(iconID)
	return "res/resources/leagueView/" .. string.format("league_badge%d_big", iconID) .. imageFormat;
end

-- 创建不带label的icon（正常大）
function ResourceMgr:createItemNodeJustIcon(itemID)
	if itemID == nil then 
		return nil;
	end

	local node = cc.Node:create();
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);

	local spriteIconBg = cc.Sprite:create(commonPath .. "item_bg_" .. itemLevel .. imageFormat);
	local spriteIcon = cc.Sprite:create(itemIconPath  .. itemID .. imageFormat);
	local spriteIconFrame = cc.Sprite:create(commonPath .. "item_frame_" .. itemLevel .. imageFormat);

	if spriteIcon == nil then
		print("icon 不存在");
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	return node;
end	

function ResourceMgr:getItemSelectFrame()
	return commonPath .. "item_selected" .. imageFormat;
end

function ResourceMgr:getChangeSign()
	return commonPath .. "item_change" .. imageFormat;
end

function ResourceMgr:getBlackChangeSign()
	return commonPath .. "item_change_black" .. imageFormat;
end

function ResourceMgr:getItemNodeBg()
	return commonPath .. "item_bg_6" .. imageFormat;
end

function ResourceMgr:getItemCountBg()
	return commonPath .. "bp_item_number" .. imageFormat;
end

-- 耗尽
function ResourceMgr:getItemUseUpMark()
	return commonPath .. "equip_item_deplete" .. imageFormat;
end

function ResourceMgr:getIconChangeAnimTouch()
	local animName = "fx_fort_change2";
	local animPath = animPathCommon .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getIconChangeAnim()
	local animName = "fx_fort_change";
	local animPath = animPathCommon .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getSliderBall()
	return commonPath .. "number_bar_point" .. imageFormat;
end

function ResourceMgr:getSliderBarBg()
	return commonPath .. "number_bar1_18_0_18_0" .. imageFormat;
end

function ResourceMgr:getSliderBar()
	return commonPath .. "number_bar2_18_0_18_0" .. imageFormat;
end

function ResourceMgr:getCommonArmature(animName)
	local animPath = animPathCommon .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getItemPathBtn(isNormalState, nType)
	if isNormalState then
		return commonPath .. "btn_access" .. nType .. imageFormat;
	else
		return commonPath .. "btn_access" .. nType .. "_h" .. imageFormat;
	end
end

function ResourceMgr:getNoItemPath()
	return commonPath .. "btn_access0" .. imageFormat;
end

function ResourceMgr:getSmallGoldIcon()
	return commonPath .. "icon_gold_small" .. imageFormat;
end

function ResourceMgr:getItemReceiveImg()
	return commonPath .. "item_label" .. imageFormat;
end

-- 显示物品弹出的提示框
function ResourceMgr:getItemTipFrame()
	return commonPath .. "boss_tip_50_20_50_20" .. imageFormat;
end

--抽奖界面和公域混战 特殊物品黄色环绕特效
function ResourceMgr:getAnimArmatureShowEffectCircle()
	local fileName = "fx_lottery_into";
	local animPath = "res/anims/common/" .. fileName .. "/" .. fileName .. animFormat;
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;	
end

--------------   获取 按钮  文字  -----------------
function ResourceMgr:getBtnEnsureTitleSprite()
	return fontPath .. "btn_font1_common" .. imageFormat;
end

--------------获取 文本Font --------------
function ResourceMgr:getPlayerLevelUpFont()
	return fontPath .. "level_num.fnt";
end

--------------军衔结算 --- 动画  ---------------------
function ResourceMgr:getRankResultAnimByName(name)
	local animPath = animPathRankResult .. name .. "/" .. name .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(name);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

---------------------------------------------------------
-------------------------主界面---------------------------
---------------------------------------------------------

-- 动画
function ResourceMgr:getAnimArmatureByNameOnMain(animName)
	local animPath = animPathMain .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getFamousBarPng()                                 -- 声望进度条（半圆）
	return mainViewPath .. "main_loading1_1" .. imageFormat;
end

function ResourceMgr:getBottonLightBtn()                                -- 亮光图标
	return mainViewPath .. "ui_main_button5_1" .. imageFormat;
end

function ResourceMgr:getBottonDarkBtn()                                 -- 无光图标
	return mainViewPath .. "ui_main_button5" .. imageFormat;
end

function ResourceMgr:getShipSpriteByIndex(index)                        -- 飞行飞船
	return imagesPath .. "bg_ship_" .. index .. imageFormat;
end

function ResourceMgr:getFloatingByIndex(index)                          -- 漂流物
	return imagesPath .. "floater" .. index .. imageFormat;
end

function ResourceMgr:getExploreNormalPopup()                            -- 探险：常规事件
	return mainViewPath .. "ui_main_explore1" .. imageFormat;
end

function ResourceMgr:getExploreFightPopup()                             -- 探险：遇敌事件
	return mainViewPath .. "ui_main_explore2" .. imageFormat;
end

function ResourceMgr:getExploreEnsureButton()                            -- 探险：确定按钮图片
	return mainViewPath .. "ui_main_name2" .. imageFormat;
end

function ResourceMgr:getExploreCancelButton()                            -- 探险：遇敌取消按钮图片
	return mainViewPath .. "ui_pvp1_button6" .. imageFormat;
end

function ResourceMgr:getExploreFightButton()                             -- 探险：遇敌夺宝按钮图片
	return mainViewPath .. "ui_pvp1_button7" .. imageFormat;
end

function ResourceMgr:getAramtureChannel()
	local fileName = "main_battle_list";
	local animPath = animPathMain .. fileName .. "/" .. fileName .. animFormat;
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

function ResourceMgr:getGameBeginMovie()
	return "res/movie/game_start.mp4";
end

function ResourceMgr:getUpMaskByDomainNum(domainNum)
	return mainViewPath .. "up_mask_" .. domainNum .. imageFormat;
end

--抽奖界面 显示宝箱动画
function ResourceMgr:getAnimArmatureShowTreasure()
	local fileName = "fx_lottery_box";
	local animPath = "res/anims/lottery/" .. fileName .. "/" .. fileName .. animFormat;
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

--抽奖界面 显示普通物品闪白光动画
function ResourceMgr:getAnimArmatureShowWhiteLight()
	local fileName = "fx_lottery_item1";
	local animPath = "res/anims/lottery/" .. fileName .. "/" .. fileName .. animFormat;
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;	
end

--抽奖界面 显示特殊物品闪黄光动画
function ResourceMgr:getAnimArmatureShowYellowLight()
	local fileName = "fx_lottery_item2";
	local animPath = "res/anims/lottery/" .. fileName .. "/" .. fileName .. animFormat;
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;	
end

-- 抽奖界面 界面闪光特效
function ResourceMgr:getLotteryBoxLightAnim()
	local animName = "ui_seek_light";
	local animPath = "res/anims/lottery/" .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getRevengeTipBg()
	return mainViewPath .. "main_tip1" .. imageFormat;
end

function ResourceMgr:getRevengeBtnAccaptHigh()
	return mainViewPath .. "btn_tip_accept_h" .. imageFormat;
end

function ResourceMgr:getRevengeBtnAccaptNormal()
	return mainViewPath .. "btn_tip_accept_n" .. imageFormat;
end

function ResourceMgr:getRevengeBtnRejectHigh()
	return mainViewPath .. "btn_tip_refuse_h" .. imageFormat;
end

function ResourceMgr:getRevengeBtnRejectNormal()
	return mainViewPath .. "btn_tip_refuse_n" .. imageFormat;
end


---------------------------------------------------------
------------------------战舰页面--------------------------
---------------------------------------------------------

-- ①、图片
function ResourceMgr:getFortIconByID(fortID)                            -- 炮台
	-- print("炮台ID",fortID)
	return itemIconPath .. fortID .. imageFormat;
end

function ResourceMgr:getFortQualityProgressBar()                        -- 炮台品质进度条
	return shipViewPath .. "loading_fort_part" .. imageFormat;
end

function ResourceMgr:getFortQualitySpriteByQuality(quality)             -- 炮台品质的字母
	if quality == "D" then
		return shipViewPath .. "ui_fort_quality_d" .. imageFormat;
	elseif quality == "C" then
		return shipViewPath .. "ui_fort_quality_c" .. imageFormat;
	elseif quality == "B" then
		return shipViewPath .. "ui_fort_quality_b" .. imageFormat;
	elseif quality == "A" then
		return shipViewPath .. "ui_fort_quality_a" .. imageFormat;
	elseif quality == "S" then
		return shipViewPath .. "ui_fort_quality_s" .. imageFormat;
	elseif quality == "S+" then
		return shipViewPath .. "ui_fort_quality_max" .. imageFormat;
	end
end

function ResourceMgr:getFortQualitySpriteByQualityNumber(quality)
	if quality == 1 then
		return shipViewPath .. "fort_quality_d" .. imageFormat;
	elseif quality == 2 then
		return shipViewPath .. "fort_quality_c" .. imageFormat;
	elseif quality == 3 then
		return shipViewPath .. "fort_quality_b" .. imageFormat;
	elseif quality == 4 then
		return shipViewPath .. "fort_quality_a" .. imageFormat;
	elseif quality == 5 then
		return shipViewPath .. "fort_quality_s" .. imageFormat;
	end
end

function ResourceMgr:getFortMaxSprite()
	return shipViewPath .. "icon_max" .. imageFormat;
end

function ResourceMgr:getFortLockPic()                                   -- 炮台未解锁（道具不够）
	return shipViewPath .. "ui_skin_unlock1" .. imageFormat;
end

function ResourceMgr:getFortUnlockPic()                                 -- 炮台未解锁（道具够了）
	return shipViewPath .. "ui_skin_lock1" .. imageFormat;
end

function ResourceMgr:getMarkEquipSprite()                               -- 炮台已装备标记图标
	return commonPath .. "item_installed" .. imageFormat;
end

function ResourceMgr:getMarkSuitSprite()                                -- 炮台套装标记图标
	return shipViewPath .. "ui_skin_item01" .. imageFormat;
end

function ResourceMgr:getFortLevelExpBar()                               -- 炮台等级经验进度条
	return shipViewPath .. "loading_exp" .. imageFormat;
end

function ResourceMgr:getShipSkinByID(skinID)                            -- 战舰皮肤
	return imagesPath .. "skin_original_" .. skinID .. imageFormat;
end

function ResourceMgr:getLockShipSkinSprite()
	return shipViewPath .. "ui_ship_unlock1" .. imageFormat;
end

function ResourceMgr:getFortTypeIcon(fortType)
	return shipViewPath .. "ui_fort_type" .. fortType .. imageFormat;
end

function ResourceMgr:getFortTalentTag(talentIndex)
	return shipViewPath .. "fort_label" .. talentIndex .. imageFormat;
end

function ResourceMgr:getUpQualityArrow()
	return shipViewPath .. "icon_upgrade" .. imageFormat;
end

function ResourceMgr:getMaxSkillLevelSprite()
	return shipViewPath .. "label_max" .. imageFormat;
end

function ResourceMgr:getGoldBarSprite()
	return shipViewPath .. "ui_fort_quality_progressbar03" .. imageFormat;
end

function ResourceMgr:getBarBgSprite()
	return shipViewPath .. "ui_fort_bar1_1" .. imageFormat;
end

function ResourceMgr:getShipNameByIndex(index)
	return shipViewPath .. "ship_name" .. index .. imageFormat;
end

function ResourceMgr:getFortSuitLogo()
	return shipViewPath .. "icon_fort_suit" .. imageFormat;
end

function ResourceMgr:getShipUnlockFightAnim()
	local animName = "ship_atn";
	local animPath = animPathShip .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

function ResourceMgr:getShipSuitFortUnlockTitle()
	return shipViewPath .. "ship_fort_get" .. imageFormat;
end

function ResourceMgr:getShipSuitFortLockTitle()
	return shipViewPath .. "ship_fort_lock" .. imageFormat;
end

function ResourceMgr:getBtnUpGradeLabel()
	return shipViewPath .. "font_btn2_3" .. imageFormat;
end

function ResourceMgr:getFortLockNotEnough()
	return shipViewPath .. "icon_fort_lock" .. imageFormat;
end

function ResourceMgr:getFortLockEnoughMaterial()
	return shipViewPath .. "icon_fort_unlock" .. imageFormat;
end

function ResourceMgr:getFortListTitleSprite(type)
	return shipViewPath .. "font_fort_title" .. type .. imageFormat;
end

function ResourceMgr:getFortAdvanceMaterialBar()
	return shipViewPath .. "loading_fort_part" .. imageFormat;
end

function ResourceMgr:getBtnGainTitle()
	return shipViewPath .. "font_btn2_8" .. imageFormat;
end

function ResourceMgr:getBtnUnlockTitle()
	return shipViewPath .. "font_btn2_9" .. imageFormat;
end

function ResourceMgr:getBtnAdvanceTitle()
	return shipViewPath .. "font_btn2_7" .. imageFormat;
end

function ResourceMgr:getViewLabelMax()
	return shipViewPath .. "label_max" .. imageFormat;
end

function ResourceMgr:getUnlockFortAnim()
	local animName = "fx_fort_lock";
	local animPath = animPathShip .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

---------------------------------------------------------
-----------------------打劫贩售舰-------------------------
---------------------------------------------------------

--护送界面贩售舰动画
-- function ResourceMgr:merchantShipArmatrue(shipLv)
-- 	print("战舰的等级是", shipLv)
-- 	local animPath = animPathEscort.."ship_escort"..shipLv.."/ship_escort"..shipLv..".ExportJson"
-- 	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
-- 	local merchantShipArmatrue = ccs.Armature:create("ship_escort"..shipLv);
-- 	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
-- 	return merchantShipArmatrue;
-- end

--搜索动画
-- function ResourceMgr:getSearchArmature()
-- 	local searchArmaturePath = animPathEscort.."choose_robbery1/choose_robbery1.ExportJson";
-- 	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(searchArmaturePath);
-- 	local searchArmature = ccs.Armature:create("choose_robbery1");
-- 	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(searchArmaturePath);
-- 	return searchArmature;
-- end

--进入战斗遇敌动画
-- function ResourceMgr:enterBattleArmature()
-- 	local enterBattleArmaturePath = animPathEscort.."robbery_title/robbery_title.ExportJson"
-- 	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(enterBattleArmaturePath);
-- 	local enterBattleArmature = ccs.Armature:create("robbery_title");
-- 	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(enterBattleArmaturePath);
-- 	return enterBattleArmature;
-- end

--护送获得星际币特效
-- function ResourceMgr:gainGoldArmature()
-- 	local gainGoldArmaturePath = animPathEscort .. "store_gas1/store_gas1.ExportJson";
-- 	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(gainGoldArmaturePath);
-- 	local gainGoldArmature = ccs.Armature:create("store_gas1");
-- 	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(gainGoldArmaturePath);
-- 	return gainGoldArmature;
-- end

function ResourceMgr:getEscortResultTitle(resultType)
	if resultType == 1 then    -- 护送成功
		return escortViewPath .. "ui_escort_tittle3" .. imageFormat;
	elseif resultType == 2 then   -- 护送失败
		return escortViewPath .. "ui_escort_tittle2" .. imageFormat;
	elseif resultType == 3 then   -- 打劫成功
		return escortViewPath .. "ui_escort_tittle1" .. imageFormat;
	elseif resultType == 4 then
		return escortViewPath .. "ui_escort_tittle4" .. imageFormat;
	end 
end

function ResourceMgr:getEscortResultBlueFrameBg()
	return escortViewPath .. "ui_1escort_76_120_76_100" .. imageFormat;
end

function ResourceMgr:getEscortResultRedFrameBg()
	return escortViewPath .. "ui_2escort_76_120_76_100" .. imageFormat;
end

function ResourceMgr:getEscortResultEscortGainBg()
	return escortViewPath .. "ui_escort_part2" .. imageFormat;
end


----------------------------   新   护送   --------------------------------------------
function ResourceMgr:getEscortItemSelectFrame()
	return escortViewPath .. "convoy_item_selected" .. imageFormat;
end

function ResourceMgr:getEscortShipLabelByLevel(level)
	return escortViewPath .. "escort_ship_title" .. level .. imageFormat;
end

function ResourceMgr:getEscortBtnEscortTitle()
	return escortViewPath .. "convoy_font4_btn" .. imageFormat;
end

function ResourceMgr:getEscortBtnAbandonEscortTitle()
	return escortViewPath .. "convoy_font7_btn" .. imageFormat;
end

-- 护送结算
function ResourceMgr:getEscortResultBg(nResult)
	if nResult == 1 then  -- 胜利
		return escortViewPath .. "convoy_item3_bg" .. imageFormat;
	else
		return escortViewPath .. "convoy_item4_bg" .. imageFormat;
	end
end

function ResourceMgr:getEscortResultTitleLine(nResult)
	if nResult == 1 then
		return escortViewPath .. "convoy_part10" .. imageFormat;
	else
		return escortViewPath .. "convoy_part12" .. imageFormat;
	end
end

function ResourceMgr:getEscortResultSprite(nResult)
	if nResult == 1 then
		return escortViewPath .. "convoy_part9" .. imageFormat;
	else
		return escortViewPath .. "convoy_part11" .. imageFormat;
	end
end

function ResourceMgr:getEscortResultTitle(nResultType, nResult)
	if nResult == 1 then
		if nResultType == 1 then
			return escortViewPath .. "convoy_font8" .. imageFormat;
		else
			return escortViewPath .. "convoy_font9" .. imageFormat;
		end
	else
		if nResultType == 1 then
			return escortViewPath .. "convoy_font10" .. imageFormat;
		else
			return escortViewPath .. "convoy_font11" .. imageFormat;
		end
	end
end

function ResourceMgr:getEscortLootSearchExitBtn(state)
	if state == 1 then
		return escortViewPath .. "button_esc_n" .. imageFormat;
	else
		return escortViewPath .. "button_esc_h" .. imageFormat;
	end
end

function ResourceMgr:getEscortLogLine()
	return escortViewPath .. "convoy_item6_bg" .. imageFormat;
end

function ResourceMgr:getLootLogLine()
	return escortViewPath .. "convoy_item5_bg" .. imageFormat;
end

function ResourceMgr:getEscortProgressBallArmature()
	local animName = "convoy_idle_icon";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getEscortLootSearchArmature()
	local animName = "convoy_search";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

function ResourceMgr:getEscortLootBattleStartArmature()
	local animName = "convoy_start1";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

function ResourceMgr:getEscortSceneArmature()
	local animName = "convoy_scene";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

function ResourceMgr:getEscortSelectLight()
	local animName = "convoy_selected_light1";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

function ResourceMgr:getEscortShipArmatureByLevel(level)
	local animName = "convoy_ship" .. level;
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

function ResourceMgr:getEscortCoinGotAnim()
	local animName = "get_gold_coins";
	local animPath = animPathEscort .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end


--------------------------------------------------------------------------------

function ResourceMgr:getDomainGoldArrowImg()
	return domainViewPath .. "boss_icon_arrow2" .. imageFormat;
end

function ResourceMgr:getDomainWhiteArrowImg()
	return domainViewPath .. "boss_icon_arrow1" .. imageFormat;
end

function ResourceMgr:getDomainRank1()
	return domainViewPath .. "boss_icon_rank1" .. imageFormat;
end

function ResourceMgr:getDomainRank2()
	return domainViewPath .. "boss_icon_rank2" .. imageFormat;
end

function ResourceMgr:getDomainRank3()
	return domainViewPath .. "boss_icon_rank3" .. imageFormat;
end

function ResourceMgr:getDomainNameLine()
	return domainViewPath .. "boss_name_line1" .. imageFormat;
end

function ResourceMgr:getDomainShowCurRank()
	return domainViewPath .. "bossbattle_part1" .. imageFormat;
end

-------------
function ResourceMgr:getDomainAwardRedBg()
	return domainViewPath .. "boss_rank_part2" .. imageFormat;
end

function ResourceMgr:getDomainRankTitle()
	return domainViewPath .. "text_rank1" .. imageFormat;
end

function ResourceMgr:getDomainAwardRankByIndex(index)
	return domainViewPath .. "boss_rank_number" .. index .. imageFormat;
end

function ResourceMgr:getLeagueAwardRankByIndex(index)
	return "res/resources/leagueFight/" .. "league_rank_number" .. index .. imageFormat;
end

function ResourceMgr:getDomainUIAnim(name)
	local animName = name;
	local animPath = animPathDomain .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animName);
	return armature;
end

---------------------------------------------------------
-------------------------生产界面-------------------------
---------------------------------------------------------

--解锁新生产位置的动画
function ResourceMgr:getProducePosUnlockArmature()
	local animName = "ui_product_unlock1";
	local animPath = animPathProduce .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	armature:getAnimation():play("anim01");

	return armature;
end

--生产时图标的背景动画
function ResourceMgr:getProducingArmature()
	local animName = "ui_product_on1";
	local animPath = animPathProduce .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	armature:getAnimation():play("anim01");

	return armature;
end

function ResourceMgr:getProduceViewArmature(animName)
	local animPath = animPathProduce .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	armature:getAnimation():play("anim01");

	return armature;
end


function ResourceMgr:getProduceItemWithEffect(itemID, itemCount)
	if itemID == nil then 
		return nil;
	end

	local node = cc.Node:create();
	
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_".. (itemLevel+1) ..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_".. (itemLevel+1) ..".png");

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);

	---------- 以上是图标通用的显示方式，底图，物品图标，外框 ----------

	self:setItemCount(node, itemCount);

	local animName = "ui_product_on2";
	local animPath = animPathProduce .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	armature:getAnimation():play("anim01");

	node:addChild(armature, ICON_Z_ORDER_SELECTED, ICON_TAG_SELECTED);

	return node;
end

function ResourceMgr:createProduceFormulationIcon(itemID)
	if itemID == nil then
		return nil;
	end

	local node = cc.Node:create();
	
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
	local itemName = ItemDataMgr:getItemNameByID(itemID)
	local itemCount = ItemDataMgr:getItemCount(itemID)

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_"..(itemLevel+1) ..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_"..(itemLevel+1) ..".png");
	local labelItemName = cc.Label:createWithTTF(itemName and itemName or "未知", "res/font/simhei.ttf", 16)
	local labelItemCount = cc.Label:createWithTTF(itemCount and itemCount or 0, "res/font/simhei.ttf", 16)
	local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg());

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	node:addChild(countBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);
	node:addChild(labelItemName, ICON_Z_ORDER_NAME, ICON_TAG_NAME);
	node:addChild(labelItemCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);

	spriteIconBg:setPosition(cc.p(65, 72));
	spriteIcon:setPosition(cc.p(65, 72));
	spriteIconFrame:setPosition(cc.p(65, 72));

	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
    labelItemName:setPosition(cc.p(65, 6))
    :setColor(qualityColor[itemLevel])

	labelItemCount:setAnchorPoint(cc.p(1, 0.5))
	:setPosition(cc.p(110, 35));

	countBg:setAnchorPoint(labelItemCount:getAnchorPoint());
	countBg:setPosition(labelItemCount:getPositionX(), labelItemCount:getPositionY());

	node:setContentSize(130, 130);
	node:setAnchorPoint(0.5, 0.5);

	return node;
end

function ResourceMgr:changeProduceFormulationIcon(node, itemID)
	if node == nil then
		return;
	end	

	local spriteIconBg = node:getChildByTag(ICON_TAG_BG);
	local spriteIcon = node:getChildByTag(ICON_TAG_PIC);
	local spriteIconFrame = node:getChildByTag(ICON_TAG_FRAME)

	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	spriteIconBg:setTexture("res/resources/common/item_bg_"..(itemLevel+1) ..".png");
	spriteIcon:setTexture("res/itemIcon/"..iconID..".png");
	spriteIconFrame:setTexture("res/resources/common/item_frame_"..(itemLevel+1) ..".png");

	local itemName = ItemDataMgr:getItemNameByID(itemID)
	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
	node:getChildByTag(ICON_TAG_NAME)
		:setString(itemName and itemName or "未知")
		:setColor(qualityColor[itemLevel])

	local itemCount = ItemDataMgr:getItemCount(itemID)
	node:getChildByTag(ICON_TAG_COUNT)
		:setString(itemCount and itemCount or 0)

	local armature = node:getChildByTag(ICON_TAG_SELECTED);
	if armature then
		node:removeChildByTag(ICON_TAG_SELECTED);
	end
end

function ResourceMgr:setFormulationIconState(node, isSelected)
	if node == nil then
		return;
	end

	local spriteSelect = node:getChildByTag(ICON_TAG_SELECTED)
	if spriteSelect == nil then
		spriteSelect = cc.Sprite:create("res/resources/common/item_selected.png")
		spriteSelect:setPosition(cc.p(65, 72))

		node:addChild(spriteSelect, ICON_Z_ORDER_SELECTED, ICON_TAG_SELECTED)	
	end
	spriteSelect:setVisible(isSelected)
end

function ResourceMgr:getSlotsIconWithScale(itemID, rate)
	if itemID == nil then
		return nil;
	end

	if rate == nil then
		rate = 1;
	end

	local node = cc.Node:create();
	
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID)+1;
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_"..itemLevel..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_"..itemLevel..".png");

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);

	spriteIconBg:setScale(rate);
	spriteIcon:setScale(rate);
	spriteIconFrame:setScale(rate);

	spriteIconBg:setPosition(cc.p(65, 65));
	spriteIcon:setPosition(cc.p(65, 65));
	spriteIconFrame:setPosition(cc.p(65, 65));

	return node;
end

------------------------------------------------------
------------             邮件              -----------
------------------------------------------------------

function ResourceMgr:getMailBtnReceive()
	return mailViewPath .. "mail_font2_btn" .. imageFormat;
end

function ResourceMgr:getMailBtnReceiveAlready()
	return mailViewPath .. "mail_font3_btn" .. imageFormat;
end

-- 1 有附件， 2 未读， 3 已读
function ResourceMgr:getMailTypeIcon(mailType)
	return mailViewPath .. "mail_icon" .. mailType .. imageFormat;
end

function ResourceMgr:getMailReceiveShade()
	return mailViewPath .. "mail_shade4" .. imageFormat;
end

function ResourceMgr:getMailPresentReceiveLabelImg()
	return mailViewPath .. "mail_label" .. imageFormat;
end

function ResourceMgr:getMailReadGrayBg()
	return mailViewPath .. "mail_tab_btn_d" .. imageFormat;
end

function ResourceMgr:getMailUnreadBg()
	return mailViewPath .. "mail_tab_btn_n" .. imageFormat;
end

function ResourceMgr:getMailSelectFrame()
	return mailViewPath .. "mail_tab_btn_s" .. imageFormat;
end


--------------------------------------------------------
------------------资源库----------------------
--------------------------------------------------------

function ResourceMgr:getPackageEquipBtnEquip()
	return packageViewPath .. "btn_equip_install" .. imageFormat;
end

function ResourceMgr:getPackageEquipBtnComplete()
	return packageViewPath .. "btn_equip_complete" .. imageFormat;
end

function ResourceMgr:getPackageEquipSlotBg(level)
	return packageViewPath .. "equip_item_bg_" .. level .. imageFormat;
end

function ResourceMgr:getPackageUseItemLow()
	return packageViewPath .. "equip_usage_count1" .. imageFormat;
end

function ResourceMgr:getPackageUseItemHigh()
	return packageViewPath .. "equip_usage_count2" .. imageFormat;
end

function ResourceMgr:getPackageUpgradeBtnSprite()
	return packageViewPath .. "depot_font1_btn" .. imageFormat;
end

function ResourceMgr:getPackageUseBtnSprite()
	return packageViewPath .. "depot_font3_btn" .. imageFormat;
end

function ResourceMgr:getPackagePropUpgradeBgGray()
	return packageViewPath .. "prop_update_bg2" .. imageFormat;
end

function ResourceMgr:getPackagePropUpgradeBgLight()
	return packageViewPath .. "prop_update_bg1" .. imageFormat;
end

function ResourceMgr:getPackageEquipSlotAnim()
	local animName = "equip_idle";
	local animPath = animPathPackage .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	armature:getAnimation():play("anim01");

	return armature;
end

--------------------------------------------------------
------------------分解----------------------
--------------------------------------------------------
function ResourceMgr:createDecompseFormulationIcon(itemID, count)
	if itemID == nil then
		return nil;
	end

	local node = cc.Node:create();

	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
	local itemName = ItemDataMgr:getItemBaseInfo(itemID).name;
	local itemCount = count or ItemDataMgr:getItemCount(itemID);

	local spriteIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel+1));
	local spriteIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
	local spriteIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel+1));
	local labelItemName = cc.Label:createWithTTF(itemName and itemName or "未知", "res/font/simhei.ttf", 16);
	local labelItemCount = cc.Label:createWithTTF(itemCount, "res/font/simhei.ttf", 16);
	local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg());

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	node:addChild(countBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);
	node:addChild(labelItemName, ICON_Z_ORDER_NAME, ICON_TAG_NAME);
	node:addChild(labelItemCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);

	spriteIconBg:setPosition(cc.p(65, 72));
	spriteIcon:setPosition(cc.p(65, 72));
	spriteIconFrame:setPosition(cc.p(65, 72));

	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
    labelItemName:setPosition(cc.p(65, 6))
    	:setColor(qualityColor[itemLevel])

	labelItemCount:setAnchorPoint(cc.p(1, 0.5))
	:setPosition(cc.p(110, 35));

	countBg:setAnchorPoint(labelItemCount:getAnchorPoint());
	countBg:setPosition(labelItemCount:getPositionX(), labelItemCount:getPositionY());

	node:setContentSize(130, 130);
	node:setAnchorPoint(0.5, 0.5);

	return node;
end

function ResourceMgr:changeDecompseFormulationIcon(node, itemID, count)
	if node == nil then
		return;
	end	

	local spriteIconBg = node:getChildByTag(ICON_TAG_BG);
	local spriteIcon = node:getChildByTag(ICON_TAG_PIC);
	local spriteIconFrame = node:getChildByTag(ICON_TAG_FRAME);

	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
	local itemName = ItemDataMgr:getItemBaseInfo(itemID).name;
	local itemCount = count or ItemDataMgr:getItemCount(itemID);

	spriteIconBg:setTexture(ResourceMgr:getItemBGByQuality(itemLevel+1));
	spriteIcon:setTexture(ResourceMgr:getItemIconByID(iconID));
	spriteIconFrame:setTexture(ResourceMgr:getItemBoxFrameByQuality(itemLevel+1));

	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
	node:getChildByTag(ICON_TAG_NAME)
		:setString(itemName and itemName or "未知")
		:setColor(qualityColor[itemLevel])

	node:getChildByTag(ICON_TAG_COUNT):setString(itemCount);

	local armature = node:getChildByTag(ICON_TAG_SELECTED);
	if armature then
		node:removeChildByTag(ICON_TAG_SELECTED);
	end
end

function ResourceMgr:getDecompseSlotsIconWithScale(itemID, rate)
	if itemID == nil then
		return nil;
	end

	if rate == nil then
		rate = 1;
	end

	local node = cc.Node:create();
	
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID) + 1;
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel));
	local spriteIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
	local spriteIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel));
	local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg());

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end

	node:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	node:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	node:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	node:addChild(countBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);

	countBg:setAnchorPoint(cc.p(1, 0));
	local pos = cc.p(spriteIconFrame:getPositionX(), spriteIconFrame:getPositionY());
	pos.x = pos.x + spriteIconFrame:getContentSize().width*(1-spriteIconFrame:getAnchorPoint().x);
	pos.y = pos.y + spriteIconFrame:getContentSize().height*(0-spriteIconFrame:getAnchorPoint().y);
	countBg:setPosition(pos.x, pos.y);

	spriteIconBg:setScale(rate);
	spriteIcon:setScale(rate);
	spriteIconFrame:setScale(rate);

	return node;
end
-- 动画
function ResourceMgr:getAnimArmatureByNameOnDecompose(animName)
	local animPath = animPathDecompose .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

local function closeDescripProp()
	local descripProp = App:getRunningScene():getChildByName("DescripProp");
	if descripProp then
		descripProp:removeSelf();
	end
end

function ResourceMgr:createRankAwardIcon(itemID, itemCount)
	local node = ResourceMgr:createItemIcon(itemID);
	ResourceMgr:setItemCount(node, itemCount);

	local labelItemName = cc.LabelTTF:create(ItemDataMgr:getItemNameByID(itemID), "", 16);
	labelItemName:setPosition(cc.p(0, -70));
	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
	--[[local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
    if itemID ~= 10001 then--金币
    	labelItemName:setColor(qualityColor[itemLevel]);
    end
    ]]

	node:addChild(labelItemName, ICON_Z_ORDER_NAME, ICON_TAG_NAME);

	local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg());
	node:addChild(countBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);

	local labelItemCount = node:getChildByTag(ICON_TAG_COUNT);
	countBg:setAnchorPoint(labelItemCount:getAnchorPoint());
	countBg:setPosition(labelItemCount:getPositionX(), labelItemCount:getPositionY());
--[[
	local size = node:getChildByTag(ICON_TAG_PIC):getContentSize();
	local btnJump = cc.Scale9Sprite:create(ResourceMgr:getAlpha0Sprite());
	local btnJumpStoryAnime = cc.ControlButton:create(cc.Label:createWithSystemFont("", "", 0), btnJump); 
	btnJumpStoryAnime:setPreferredSize(size);
	btnJumpStoryAnime:addTo(node, ICON_Z_ORDER_RECEIVED_RANK_AWARD_MARK+1, ICON_TAG_RECEIVED_RANK_AWARD_MARK+1);
	btnJumpStoryAnime:registerControlEventHandler(function()
		local descripProp = require("app.views.common.DescripProp"):create(2);
		descripProp:setName("DescripProp");

		local itemBase = ItemDataMgr:getItemBaseInfo(itemID);
		descripProp:setData({item_id=itemID, count=itemCount, item_desc=(itemBase.desc and itemBase.desc or itemBase.name)});
		descripProp:flushPos(btnJumpStoryAnime);
		descripProp:addTo(App:getRunningScene());
	end, cc.CONTROL_EVENTTYPE_TOUCH_DOWN);
	btnJumpStoryAnime:registerControlEventHandler(function()
		closeDescripProp();
	end, cc.CONTROL_EVENTTYPE_DRAG_EXIT);--拖动刚离开内部时（保持触摸状态下）
	btnJumpStoryAnime:registerControlEventHandler(function()
		closeDescripProp();
	end, cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE);--在内部抬起手指（保持触摸状态下）
	btnJumpStoryAnime:registerControlEventHandler(function()
		closeDescripProp();
	end, cc.CONTROL_EVENTTYPE_TOUCH_CANCEL);--取消触点时
]]
	return node;
end

function ResourceMgr:changeRankAwardIcon(node, itemID, itemCount)
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	node:getChildByTag(ICON_TAG_BG):setTexture(ResourceMgr:getItemBGByQuality(itemLevel+1));
	node:getChildByTag(ICON_TAG_PIC):setTexture(ResourceMgr:getItemIconByID(ItemDataMgr:getItemIconIDByItemID(itemID)));
	node:getChildByTag(ICON_TAG_FRAME):setTexture(ResourceMgr:getItemBoxFrameByQuality(itemLevel+1));
	node:getChildByTag(ICON_TAG_COUNT):setString(itemCount);

	--local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
	local labelItemName = node:getChildByTag(ICON_TAG_NAME);
    --if itemID ~= 10001 then--金币
    	--labelItemName:setColor(qualityColor[itemLevel]);
    --end
    labelItemName:setString(ItemDataMgr:getItemNameByID(itemID));
--[[
	local btn = node:getChildByTag(ICON_TAG_RECEIVED_RANK_AWARD_MARK+1);
	btn:registerControlEventHandler(function()
		local descripProp = require("app.views.common.DescripProp"):create(2);
		descripProp:setName("DescripProp");

		local itemBase = ItemDataMgr:getItemBaseInfo(itemID);
		descripProp:setData({item_id=itemID, count=itemCount, item_desc=(itemBase.desc and itemBase.desc or itemBase.name)});
		descripProp:flushPos(btn);
		descripProp:addTo(App:getRunningScene());
	end, cc.CONTROL_EVENTTYPE_TOUCH_DOWN);
]]
	return node;
end

function ResourceMgr:createReceiveRankAwardIcon(itemID, itemCount)
	local node = ResourceMgr:createRankAwardIcon(itemID, itemCount);

	local size = node:getChildByTag(ICON_TAG_PIC):getContentSize();
	size.width = size.width - 10;
	size.height = size.height - 10;
	local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 160))
		:setPosition(-size.width*0.5, -size.height*0.5)
		:setContentSize(size)
		:setVisible(false);
	node:addChild(layerColor, ICON_Z_ORDER_RECEIVED_RANK_AWARD_SHADE, ICON_TAG_RECEIVED_RANK_AWARD_SHADE);
	
	local rankAwardReceiveMark = cc.Sprite:create(ResourceMgr:getMailPresentReceiveLabelImg())
		:setVisible(false);
	node:addChild(rankAwardReceiveMark, ICON_Z_ORDER_RECEIVED_RANK_AWARD_MARK, ICON_TAG_RECEIVED_RANK_AWARD_MARK);

	return node;
end

function ResourceMgr:changeRankAwardIconReceiveState(node, isReceive)
	node:getChildByTag(ICON_TAG_RECEIVED_RANK_AWARD_SHADE):setVisible(isReceive);
	node:getChildByTag(ICON_TAG_RECEIVED_RANK_AWARD_MARK):setVisible(isReceive);
end

--------------------------------------------------------
------------------demo----------------------
--------------------------------------------------------
function ResourceMgr:getDemoEnergySliderBall()
	return demoViewPath .. "pvp_energy_part5" .. imageFormat;
end

function ResourceMgr:getDemoEnergySliderBar()
	return demoViewPath .. "pvp_energy_part4" .. imageFormat;
end

function ResourceMgr:getDemoHPProgressBar()
	return demoViewPath .. "pvp_plane_hp3" .. imageFormat;
end

function ResourceMgr:getDemoHPBar()
	return demoViewPath .. "pvp_plane_hp2" .. imageFormat;
end

function ResourceMgr:getDemoHPBarBack()
	return demoViewPath .. "pvp_plane_hp1" .. imageFormat;
end

function ResourceMgr:getDemoProduceBar()
	return demoViewPath .. "production_time2" .. imageFormat;
end

function ResourceMgr:getDemoProduceBarBack()
	return demoViewPath .. "production_time1" .. imageFormat;
end

function ResourceMgr:getDemoIconFrame(id)
	return demoViewPath .. "pvp_plane_box".. id .. imageFormat;
end

function ResourceMgr:getDemoIconLevel(level)
	return demoViewPath .. "pvp_plane_level".. level .. imageFormat;
end

function ResourceMgr:getDemoArmature(animName)
	local animPath = animPathDemo .. animName .. "/" .. animName .. animFormat;
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(animName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	return armature;
end

function ResourceMgr:getDemoPlaneIconById(id)
	return planeIconPath .. "plane".. id .. imageFormat;
end

function ResourceMgr:getDemoGuideArrow()
	return demoViewPath .. "arrow_guide_part1" .. imageFormat;
end

function ResourceMgr:getDemoGuideBack()
	return demoViewPath .. "arrow_guide_130_0_130_0" .. imageFormat;
end

return ResourceMgr;