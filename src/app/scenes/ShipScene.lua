local Tips = require("app.views.common.Tips");
------------------
-- 战舰皮肤场景
------------------
local ShipScene = class("ShipScene", require("app.scenes.GameSceneBase"))

function ShipScene:init()
	self:initView("shipView.ShipMainView")
end



-- 同步玩家炮台装备列表           
function ShipScene:notifySyncFortEquip(data)
	print("------------更新玩家炮台装备数据------------")
	-- dump(data)
	-- 	"<var>" = {
	--     "code"  = 1
	--     "forts" = {
	--         1 = {
            -- "exp"         = 0
            -- "fort_id"     = 90007
            -- "fort_type"   = 1
            -- "level"       = 1
            -- "skill_id"    = 50007
            -- "skill_level" = 1
	--         }
	--         2 = {
            -- "exp"         = 0
            -- "fort_id"     = 90007
            -- "fort_type"   = 1
            -- "level"       = 1
            -- "skill_id"    = 50007
            -- "skill_level" = 1
	--         }
	--         3 = {
            -- "exp"         = 0
            -- "fort_id"     = 90007
            -- "fort_type"   = 1
            -- "level"       = 1
            -- "skill_id"    = 50007
            -- "skill_level" = 1
	--         }
	-- }

	if data.code ~= 1 then
		Tips:create(GameData:get("code_map", data.code)["desc"])
		return
	end
	FortDataMgr:setEquipFortsTableNone();
	for k,v in pairs(data.forts) do
		local fortSkillid = FortDataMgr:getUnlockFortSkillID(v.fort_id);
		local skinInfo = {
			exp = v.exp,
			fort_id = v.fort_id,
			level = v.level,
			pos = k,
			skill_id = fortSkillid
		}
		FortDataMgr:setShipFortsInfo(skinInfo)
	end
	-- self:getViewBase():updateEquipFort();
end

function ShipScene:notifyAddUnlockedSkin(data)
	print("------------添加解锁皮肤---------")


	
	-- dump(data)
	-- "<var>" = {
	--     "code"        = 1
	--     "ship_id"     = 70003
	--     "skill_level" = 1
	-- }
	if data.code ~= 1 then
		Tips:create(GameData:get("code_map", data.code)["desc"])
		return
	end
	self:updateSkinList(data) --战舰皮肤更新
	-- ShipDataMgr:setShipSkinData(data) -- 战舰皮肤添加到ShipDataMgr
end

--战舰皮肤更新
function ShipScene:updateSkinList(data)
	local shipInfo = {}
	shipInfo.ship_id = data.ship_id;
	shipInfo.skill_level = data.skill_level;
	ShipDataMgr:setShipSkinData(shipInfo);
end

function ShipScene:notifyAddUnlockedFort(data)
	print("------------添加解锁炮台---------")
	-- dump(data)
	-- "<var>" = {
	--     "exp"         = 0
	--     "fort_id"     = 90011
	--     "level"       = 1
	--     "skill_id"    = 50011
	--     "skill_level" = 1
	-- }

	FortDataMgr:addUnlockFortData(data);	--更新炮塔数据
	-- self:getViewBase().m_ccbShipMainView:resetFortsData(data.fort_id, true);
	-- Tips:create("获得炮台 " .. FortDataMgr:getFortBaseInfo(data.fort_id).fort_name)
	-- self:getChildByTag(150):updataFortData(); -- 装备炮台界面
end

function ShipScene:notifyFortUpdate(data)
	print("------------炮台数据更新---------")
	-- dump(data)
-- "<var>" = {
--     "exp"         = 0
--     "fort_id"     = 90007
--     "level"       = 20
--     "quality"     = 2
--     "skill_id"    = 50007
--     "skill_level" = 1
-- }
	FortDataMgr:addUnlockFortData(data);
	local equipFortData = FortDataMgr:getEquipFortData();
	if equipFortData[data.fort_id] ~= nil then
		FortDataMgr:UpDateEquipFort(data);
	end
	-- self:getViewBase().m_ccbShipMainView:resetFortsData(data.fort_id, false);
end


return ShipScene