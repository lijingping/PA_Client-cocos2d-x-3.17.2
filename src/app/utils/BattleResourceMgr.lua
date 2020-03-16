local BattleResourceMgr = class("BattleResourceMgr")

--资源路径
local pathBattleAnimation = "res/anims/battle/"
local pathItemIcon = "res/itemIcon/"
local pathCommonResource = "res/resources/common/"
local pathOtherAnimation = "res/anims/others/"
local pathBattleBullet = "res/bullet/";
local pathPackageResource = "res/resources/packageView/";


--动画通用接口
function BattleResourceMgr:createBattleArmature(fileName)
	local animPath = pathBattleAnimation .. fileName .. "/" ..  fileName .. ".ExportJson"
	--检查文件是否存在，正式版可以注释掉不检查
	if cc.FileUtils:getInstance():isFileExist(animPath) == false then		
		print(string.format("没有找到动画文件: %s", animPath));
		return nil;
	end

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

function BattleResourceMgr:createOtherArmature(fileName)
	local animPath = pathOtherAnimation .. fileName .. "/" ..  fileName .. ".ExportJson"

	--检查文件是否存在，正式版可以注释掉不检查
	if cc.FileUtils:getInstance():isFileExist(animPath) == false then		
		print(string.format("没有找到动画文件: %s", animPath));
		return nil;
	end

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create(fileName);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);

	return armature;
end

--子弹动画
-- function BattleResourceMgr:getBulletArmature(fortSpecialId)
-- 	local bulletFileName = "bullet_" .. fortSpecialId;
-- 	return self:createBattleArmature(bulletFileName);
-- end

-- 子弹图片
function BattleResourceMgr:getBulletSprite(bulletID, isPlayer)
	if isPlayer then
		return pathBattleBullet .. "bullet_" .. bulletID .. "_blue.png";
	else
		return pathBattleBullet .. "bullet_" .. bulletID .. "_red.png";
	end
end

--炮台
function BattleResourceMgr:getFortArmatureByFortID(fortID)
	local fortIconId = FortDataMgr:getFortBaseSpecialID(fortID)
	local fortFileName = "fort_" .. fortIconId;
	return self:createBattleArmature(fortFileName);
end

--战斗背景动画
function BattleResourceMgr:getBackGroundArmatureByLevel(playerLevel)
	print("加载战斗背景动画的 time", os.time());
	local sceneNum = math.floor(playerLevel / 20) + 1; --当前星域
	-- print("当前星域：", sceneNum);
	local fileName =  "bg_pvp_scene" .. sceneNum;

	return self:createBattleArmature(fileName);
end

function BattleResourceMgr:getBossBackGroundArmature()
	return self:createBattleArmature("scene_boss");
end

--云雾，（目前只有一个云雾） 又多了个boss战的云雾了
function BattleResourceMgr:getCloudArmatureByLevel(playerLevel)
	local sceneNum = math.floor(playerLevel / 20) + 1;
	return self:createBattleArmature("mask_pvp_scene" .. sceneNum);
end
-- boss 云雾
function BattleResourceMgr:getBossCloudArmature()
	return self:createBattleArmature("scene_boss2");
end

--飞船入场动画（不用）
function BattleResourceMgr:getLoadShipArmature()
	return self:createBattleArmature("begin_ship");
end

--甲板展开动画（不通用，每艘战舰甲板配一个甲板）
function BattleResourceMgr:getDeckArmatureByShipID(shipID)
	local fileName = "deck_ship" .. shipID
	return self:createBattleArmature(fileName);
end

--飞船动画（不通用，每艘都是单独的一个动画）
function BattleResourceMgr:getShipArmatureByShipID(shipID)
	local fileName = "pvp_ship_" .. shipID;
	return self:createBattleArmature(fileName);
end

--飞船损毁动画，通用的
function BattleResourceMgr:getShipDestroyArmature()
	local fileName = "destroy_ship1"
	return self:createBattleArmature(fileName);
end

--获取Icon图标
function BattleResourceMgr:getItemIcon(itemID)
	local baseData = GameData:get("item", itemID);
	-- dump(baseData)
	if baseData == nil then
		print("Error: Bad ItemID");
		return nil;
	end
	local node = cc.Node:create();

	local pathGrade = "";
	if baseData.level == 1 then
		pathGrade = pathCommonResource .. "item_bg_0.png";
	elseif baseData.level == 2 then
		pathGrade = pathCommonResource .. "item_bg_1.png";
	elseif baseData.level == 3 then
		pathGrade = pathCommonResource .. "item_bg_2.png";
	elseif baseData.level == 4 then
		pathGrade = pathCommonResource .. "item_bg_3.png";
	elseif baseData.level == 5 then
		pathGrade = pathCommonResource .. "item_bg_4.png";
	end	

	cc.Sprite:create(pathGrade):addTo(node, 1, 1);

	cc.Sprite:create(pathItemIcon .. baseData.item_icon .. ".png"):addTo(node, 2, 2);


	return node;
end

function BattleResourceMgr:getItemWithFrameAndCount(itemID, count)
	local baseData = ItemDataMgr:getItemBaseInfo(itemID)
	-- dump(baseData)
	if baseData == nil then
		print("Error: Bad ItemID");
		return nil;
	end
	local node = cc.Node:create();

	local pathGrade = "";	
	pathGrade = pathCommonResource .. "item_bg_" .. baseData.level + 1 .. ".png";
	cc.Sprite:create(pathGrade):addTo(node, 1, 1);

	cc.Sprite:create(pathItemIcon .. baseData.item_icon .. ".png"):addTo(node, 2, 2);

	cc.Sprite:create(pathCommonResource .. "bp_item_number" .. ".png"):setPosition(13, -35):addTo(node, 3, 3);

	cc.LabelTTF:create(count, "", 18):addTo(node, 4, 4):setPosition(cc.p(42, -35)):setAnchorPoint(cc.p(1,0.5));

	cc.Sprite:create(pathCommonResource .. "item_frame_".. baseData.level + 1 .. ".png"):addTo(node, 5, 5);
	return node;
end

function BattleResourceMgr:getCoinFrameAndCount(itemID, count)
	local node = cc.Node:create();
	local pathGrade = pathCommonResource .. "item_bg_1.png";
	cc.Sprite:create(pathGrade):addTo(node, 1, 1);
	cc.Sprite:create(pathItemIcon .. itemID .. ".png"):addTo(node, 2, 2);
	cc.LabelTTF:create(count, "", 18):addTo(node, 3, 3):setPosition(cc.p(48, -40)):setAnchorPoint(cc.p(1,0.5));
	cc.Sprite:create(pathCommonResource .. "item_frame_0.png"):addTo(node, 4, 4);
	return node
end

-- function BattleResourceMgr:setItemGray(node)
-- 	local sprite1 = node:getChildByTag(1)
-- 	local sprite2 = node:getChildByTag(2)
-- 	display.setGray(sprite1);
-- 	display.setGray(sprite2);
-- end

function BattleResourceMgr:getBattleItemIcon(itemID)
	-- local baseData = GameData:get("item", itemID);
	-- -- dump(baseData);
	-- if baseData == nil then
	-- 	print("Error: Bad ItemID");
	-- 	return nil;
	-- end
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local itemIcon = ItemDataMgr:getItemIconIDByItemID(itemID);

	local node = cc.Node:create();
	local pathGrade = pathPackageResource .. "equip_item_bg_" .. itemLevel .. ".png";
	--品质
	cc.Sprite:create(pathGrade):addTo(node, 1, 1);
	--图标
	cc.Sprite:create(pathItemIcon .. itemIcon .. ".png"):addTo(node, 2, 2);

	return node;
end

--buff状态机
function BattleResourceMgr:getBattleBuffName(buffNum)
	local  strBuffName;
	if buffNum == 1 then 	 	--火力增幅状态
		strBuffName = 0
	elseif buffNum == 2 then 	--持续维修状态
		strBuffName = 2
	elseif buffNum == 3 then 	--护盾状态
		strBuffName = 3
	elseif buffNum == 4 then 	--被动技能加强
		strBuffName = 4
	elseif buffNum == 5 then 	--瘫痪状态
		strBuffName = 5
	elseif buffNum == 6 then 	--燃烧状态
		strBuffName = 6
	elseif buffNum == 7 then 	--火力干扰状态
		strBuffName = 0
	elseif buffNum == 8 then 	--维修干扰状态
		strBuffName = 8
	elseif buffNum == 9 then 	--能量干扰状态
		strBuffName = 9
	elseif buffNum == 10 then 	--破甲状态
		strBuffName = 10
	elseif buffNum == 11 then 	--禁用导弹
		strBuffName = 0
	end
	return strBuffName;
end

--能量体
function BattleResourceMgr:getEnergyArmature()
	local fileName = "energy";
	return self:createBattleArmature(fileName);
end

--能量体箭头
function BattleResourceMgr:getEnergyArrowsArmature()
	local fileName = "energy_arrows";
	return self:createBattleArmature(fileName);
end

--能量体获得
function BattleResourceMgr:getEnergyGainArmature()
	local fileName = "energy_gain1"
	return self:createBattleArmature(fileName);
end

--炮台损毁动画
function BattleResourceMgr:getFortDestroyArmature()
	local fileName = "destroy_fort1";
	return self:createBattleArmature(fileName);
end

-- -- NPC动画
-- function BattleResourceMgr:getNPCArmature()
-- 	local fileName = "npc_anim01";
-- 	return self:createBattleArmature(fileName);
-- end

-- -- NPC子弹
-- function BattleResourceMgr:getNPCBulletArmature()
-- 	local fileName = "npc_bullet";
-- 	return self:createBattleArmature(fileName);
-- end

--火力支援飞船动画（原NPC取消）
function BattleResourceMgr:getFireSupportArmature()
	local fileName = "npc_starfields1";
	return self:createBattleArmature(fileName)
end


--物品选择动画
function BattleResourceMgr:getSelectItemArmature()
	local fileName = "pvp_selected";
	return self:createBattleArmature(fileName);
end

--道具使用目标--我方
function BattleResourceMgr:getTargetShipPlayer()
	local fileName = "aim_ship_player"
	return self:createBattleArmature(fileName);
end

--道具使用目标--我方炮台
function BattleResourceMgr:getTargetFortPlayer()
	local fileName = "aim_fort_player"
	return self:createBattleArmature(fileName);
end

--道具攻击目标--敌方战舰
function BattleResourceMgr:getTargetShipEnemy()
	local fileName = "aim_ship_enemy"
	return self:createBattleArmature(fileName);	
end

--目标攻击目标--敌方炮台
function BattleResourceMgr:getTargetFortEnemy()
	local fileName = "aim_fort_enemy"
	return self:createBattleArmature(fileName);
end

--普通子弹的hit特效
function BattleResourceMgr:getNormalHitEffect()
	local fileName = "hit_bullet1"
	return self:createBattleArmature(fileName);
end

--激光的hit特效
function BattleResourceMgr:getspecialHitEffect()
	local fileName = "hit_laser1"
	return self:createBattleArmature(fileName);
end

--炮台技能技能特效
function BattleResourceMgr:getSkill(skillID)
	local fileName = "skill_" .. skillID
	return self:createBattleArmature(fileName);
end

--技能释放前，炮台上的闪光特效
function BattleResourceMgr:getSkillIntro()
	local fileName = "skill_intro"
	return self:createBattleArmature(fileName);
end

--buff图标
function BattleResourceMgr:getBuffIcon(strBuffName)
	local path = "res/resources/buffIcon/icon_buff_" .. strBuffName .. ".png"
	return cc.Sprite:create(path);
end

--buff特效
function BattleResourceMgr:getBuffEffect(strBuffName)
	local fileName = "buff_" .. strBuffName;
	return self:createBattleArmature(fileName);
end

--倒计时动画
function BattleResourceMgr:getCountdownArmature()
	local fileName = "time_count1"
	return self:createBattleArmature(fileName);
end

--结算时胜利文字动画
function BattleResourceMgr:getWinArmature()
	local fileName = "complete_win1"
	return self:createBattleArmature(fileName);	
end

--结算时的失败文字动画
function BattleResourceMgr:getLoseArmature()
	local fileName = "complete_lose1"
	return self:createBattleArmature(fileName);	
end

--结算时的平局动画
function BattleResourceMgr:getDrawArmature()
	local fileName = "complete_draw1"
	return self:createBattleArmature(fileName);	
end

--结算时分数显示背景底动画
function BattleResourceMgr:getScoreArmature()
	local fileName = "complete_score1"
	return self:createBattleArmature(fileName);
end

--结算时分数显示的蓝色数字
function BattleResourceMgr:getScoreTextureBlue(num)
	local texture = {};
	texture[4] = "res/resources/battle/ui_account01_0001.png";
	texture[3] = "res/resources/battle/ui_account01_0002.png";
	texture[2] = "res/resources/battle/ui_account01_0003.png";
	texture[1] = "res/resources/battle/ui_account01_0004.png";
	return texture[num+1];
end

--结算时分数显示的黄色数字
function BattleResourceMgr:getScoreTextureYellow(num)
	local texture = {};
	texture[4] = "res/resources/battle/ui_account01_0005.png";
	texture[3] = "res/resources/battle/ui_account01_0006.png";
	texture[2] = "res/resources/battle/ui_account01_0007.png";
	texture[1] = "res/resources/battle/ui_account01_0008.png";
	return texture[num+1];
end

function BattleResourceMgr:getDomainBossPic(fileName)
	return "res/resources/domainView/bossbattle_" .. fileName .. ".png";
end

function BattleResourceMgr:getBattleResultRobTitle()
	return "res/resources/battle/ui_account_text03.png";
end

function BattleResourceMgr:getBattleResultBeRobTitle()
	return "res/resources/battle/ui_account_text04.png";
end

function BattleResourceMgr:getBattleResoultExploreTetle()
	return "res/resources/battle/ui_explore_title1.png";
end

function BattleResourceMgr:getBattleBuffTip(buffType)
	return "res/resources/battle/number_buff_" .. buffType .. ".png";
end

-- 声望提升进图条
function BattleResourceMgr:getBattleRankBarBg()
	return "res/resources/battle/ui_rank_download1.png";
end

function BattleResourceMgr:getBattleRankBar()
	return "res/resources/battle/ui_rank_download2.png";
end

function BattleResourceMgr:getBattleBuffWordByBuffID(buffID)
	return "res/resources/battle/number_buff_" .. buffID .. ".png";
end

function BattleResourceMgr:getBattleTopRankIconByLevel(level)
	return "res/rankIcon/icon_rank_" .. level .. ".png";
end

function BattleResourceMgr:getBattleFortTypeIcon(fortType)
	return "res/resources/battle/pvp_hp1_part" .. 3 + fortType .. ".png";
end

function BattleResourceMgr:getBattleItemCountLow()
	return pathPackageResource .. "equip_usage_count1.png";
end

function BattleResourceMgr:getBattleItemCountHigh()
	return pathPackageResource .. "equip_usage_count2.png";
end

function BattleResourceMgr:getBattleItemUseUp()
	return "res/resources/battle/pvp_icon_deplete.png";
end

function BattleResourceMgr:getBattleItemUnmissileState()
	return "res/resources/battle/pvp_icon_disable.png";
end

return BattleResourceMgr