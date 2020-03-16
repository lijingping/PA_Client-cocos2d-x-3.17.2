local Tips = require("app.views.common.Tips");
local CCBEscortResult = require("app.views.escortView.CCBEscortResult");

local EscortScene = class("EscortScene",require("app.scenes.GameSceneBase"))

function EscortScene:init()	
	self.m_escortView = self:initView("escortView.EscortView");
end

function EscortScene:notifyEscortLootLog(data)
	self.m_escortView.m_ccbEscortView:receiveNotifyLootLog(data);
end

function EscortScene:notifyEscortOver(data)
	dump(data);
	self.m_escortView.m_ccbEscortView:notifyEscortOverResponse(data);
end

function EscortScene:notifyEscortLog(data)
	-- dump(data);
	self.m_escortView.m_ccbEscortView:receiveNotifyEscortLog(data);
end

function EscortScene:notifyLootFindShip(data)
	dump(data);
	-- self.m_escortView.m_ccbEscortView:lootFindShip();
end

-- ***
-- # 新抢劫贩售舰  
-- > 2019年01月16日 long

-- ## interface
-- * 获取打劫贩售舰功能界面信息  
-- `loot_battle.lootHandler.query_interface_info`  
-- param:`{}`  
-- return:  
--     ```
--         {
--             code:number,
--             activity_remain_second:number,  //活动剩余秒数
--             merchant_ship_level:number, //护送贩售舰等级 1~5=DCBAS
--             escort_remain_times:number, //剩余护送次数
--             loot_remain_times: number,  //剩余打劫次数
--             escort_remain_second: number,   //护送剩余秒数
--             escort_log: string[],   //护送日志
--             award_list: {item_id,count}[], //护送奖励
--             loot_count: number  //打劫收益的数量
--         }
--     ```

-- 说明:  
--     1. 当护送剩余秒数>0即有在护送
--     2. 当client收到award_list不为空时,进行展示奖励
--     3. 护送日志格式:  x时:y分|内容, 请按|分割字符串

-- * 护送贩售舰  
-- `loot_battle.lootHandler.escort_merchant_ship`  
-- param:`{}`  
-- return:`{code,remain_second?:number}`  
-- 说明:  
--     1. remian_second:剩余护送时间(秒)

-- * 放弃护送贩售舰  
-- `loot_battle.lootHandler.abandon_merchant_ship`  
-- param:`{}`  
-- return:`{code, award_list?:{item_id,count}[],level:number}`  
-- 说明:  
--     1. award_list:护送奖励
--     2. level:刷新后的贩售舰等级

-- * 进行搜寻贩售舰(打劫贩售舰)  
-- `loot_battle.lootHandler.find_merchant_ship`  
-- param:`{}`  
-- return:`{code}`  
-- 说明:  

-- * 取消打劫贩售舰搜寻  
-- `loot_battle.lootHandler.cancel_find_merchant_ship`  
-- param:`{}`  
-- return:`{code}`  
-- 说明:  

-- * 查看打劫日志  
-- `loot_battle.lootHandler.query_loot_log`  
-- param:`{}`  
-- return:`{code, log:string[]}`  
-- 说明:  
--     1. 打劫日志格式:  x时:y分|内容, 请按|分割字符串


------------------------------------------------------------
-- * 接收护送奖励  
-- `loot_battle.lootHandler.receive_escort_award`  
-- param:`{}`  
-- return:`{code,award_list?:{item_id,count}[]}`  
-- 说明:  
--     1. 使用情况:护送结束后,client收到护送结束通知(当用户在界面时)  
------------------------------------------------------------



-- * 刷新贩售舰等级  
-- `game.itemsHandler.refresh_merchant_ship_level`  
-- param:`{}`  
-- return:`{code, level?:number}`  
-- 说明:  
--     1. level:刷新后等级 1~5(即DCBAS)

-- * 刷新贩售舰等级为S级  
-- `game.itemsHandler.appoint_s_level`  
-- param:`{}`  
-- return:`{code, level?:number}`  
-- 说明:  

-- * 购买打劫次数  
-- `game.itemsHandler.buy_loot_times`  
-- param:`{}`  
-- return:`{code}`  
-- 说明:  

-- * 查询购买打劫次数所需钻石数量  
-- `game.itemsHandler.query_buy_loot_need`  
-- param:`{}`  
-- return:`{code, count}`  
-- 说明:  
--     1. count所需钻石数量

-- ## notify
-- * 护送S级贩售舰，全服通知  
-- `notify.loot_battle.escort_s_ship_broadcast`  
-- return:`{uid:string,nickname:string,merchant_level:number=5}`  
-- 说明:

-- * 搜寻到贩售舰的等级  
-- `notify.loot_battle.find_ship`  
-- return:`{level:level}`  
-- 说明:  

-- * 护送日志(单条)  
-- `notify.loot_battle.escort_log`  
-- return:`{log:string,count:number}`  
-- 说明:  
--     1. count: 星际币数量  
--     正数代表收益,负数失去

-- * 打劫日志(单条)  
-- `notify.loot_battle.loot_log`  
-- return:`{log:string,count:number,enemy_info}`  
-- 说明:  
--     1. count: 星际币数量  
--     正数代表收益,负数失去
--     2. enemy_info:
--     ```
--     {
--         ship:number,
--         fort1:number,
--         fort2:number,
--         fort3:number
--     }
--     ```

-- * 护送结束  
-- `notify.loot_battle.escort_over`  
-- return:`{ is_success: boolean,level:number }`  
-- 说明:  
--     1. is_success: true正常护送完成|false活动结束强制结束护送
--     2. level: 刷新的贩售舰等级


return EscortScene