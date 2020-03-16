local ProtocolMapper = {}

ProtocolMapper["notify.item.delta"] 						= "notifyUpdateItems" 				-- 玩家的＿背包＿更新物品列表
ProtocolMapper["notify.activity.has_floating_obj"] 			= "notifyHasFloatingObj" 			-- 漂浮物出现在主界面
ProtocolMapper["notify.money.update"] 						= "notifyMoneyUpdate" 				-- 更新货币
ProtocolMapper["notify.produce.produceQueue"] 				= "notifyProduceQueue" 				-- 生产列表解锁
ProtocolMapper["notify.syncHandler.activeEquips"] 			= "notifySyncEquips" 				-- 同步装备资源库列表
ProtocolMapper["notify.fort.update_active"] 				= "notifySyncFortEquip" 			-- 同步炮台装备列表
ProtocolMapper["notify.ship.add"] 							= "notifyAddUnlockedSkin" 			-- 添加解锁皮肤
ProtocolMapper["notify.fort.add"] 							= "notifyAddUnlockedFort" 			-- 添加解锁炮台
ProtocolMapper["notify.fort.update"] 						= "notifyFortUpdate" 				-- 炮台数据更新


ProtocolMapper["notify.social.friend_req"]					= "notifyFriendApplication"					-- 用于主界面显示小红点(仅在线状态下)
ProtocolMapper["notify.social.add_friend"]					= "notifyBeAddedFromFriend"			-- 好友申请被通过
ProtocolMapper["notify.social.remove_friend"]				= "notifyBeDeletedFromFriend"		-- 被好友删除的通知
ProtocolMapper["notify.social.gift_recv"]					= "notifyGift_recv"					-- 用于主界面显示礼物馈赠小红点(仅在线状态下)
ProtocolMapper["notify.info.change"]						= "notifyInfoChange"				-- 玩家信息更新
ProtocolMapper["notify.battle.revenge_req"] 				= "notifyRevengeRequest"			-- 有玩家要进行复仇请求
ProtocolMapper["notify.battle.revenge_refuse"]				= "notifyIsAcceptRevenge"			-- 玩家请求复仇后得到的回应

ProtocolMapper["notify.battle.info"]						= "notifyBattleInfo"
ProtocolMapper["notify.battle.ready"]						= "notifyBattleReady"
ProtocolMapper["notify.battle.start"] 						= "notifyBattleStart" 				-- 战斗开始
ProtocolMapper["notify.battle.event"] 						= "notifyBattleEvent" 				-- 战斗事件
ProtocolMapper["notify.battle.over"] 						= "notifyBattleOver" 				-- 战斗结束
ProtocolMapper["notify.battle.end_wait"] 					= "notifyBattleEndWait" 			-- 结束战斗等待
ProtocolMapper["notify.battle.result"] 						= "notifyBattleResult" 				-- 战斗结果

ProtocolMapper["notify.mail.recv"]                     		= "notifyNewMailHint"           	-- 接收新邮件后界面上的小红点提示

ProtocolMapper["notify.chat.friend_msg"]               		= "notifyChatNews"              	-- 接收聊天信息


ProtocolMapper["notify.battle.find_merchant_timeout"]		= "notifySearchOverTime"			--搜索贩售舰超时 
ProtocolMapper["notify.battle.escort_has_float"]			= "notifyEscortHasFloat"			--漂浮物生成(护送贩售舰过程中)
ProtocolMapper["notify.battle.change_merchant_ship_level"]	= "notifyReloadMerchantShipLevel"	--重置贩售舰等级
ProtocolMapper["notify.battle.escort_animation"]			= "notifyMeetEnemyArmature"			--护送的遇敌动画
ProtocolMapper["notify.battle.remain_escort_times"]			= "notifyRemainEscortNum"			--护送剩余次数
ProtocolMapper["notify.battle.remain_loot_times"]			= "notifyRemainLootNum"				--剩余打劫次数

-- 新
ProtocolMapper["notify.loot_battle.loot_log"]               = "notifyEscortLootLog"             -- 护送打劫日志(单条)
ProtocolMapper["notify.loot_battle.escort_over"]            = "notifyEscortOver"				-- 护送结束
ProtocolMapper["notify.loot_battle.escort_log"]             = "notifyEscortLog"                 -- 护送日志
ProtocolMapper["notify.loot_battle.escort_s_ship_broadcast"]= "notifyShowAllSShip"              -- 全服通知玩家护送S级贩售舰
ProtocolMapper["notify.loot_battle.find_ship"]              = "notifyLootFindShip"              -- 打劫搜寻中找到玩家


ProtocolMapper["notify.game.power_change"]					= "notifyPlayerPowerChange"			--玩家战斗力改变
ProtocolMapper["notify.battle.escort_s_ship_broadcast"]		= "notifyLvSEscort"					--S级护送舰全服通知

ProtocolMapper["notify.battle.update_data"]                 = "notifyBattleUpdate"              --战斗同步数据（暂定3秒）

ProtocolMapper["notify.chat.world_chat"]               		= "notifyWorldNews"              	-- 接收世界聊天信息
ProtocolMapper["notify.chat.alliance_chat"]					= "notifyAllianceNews"				-- 接收联盟频道消息

return ProtocolMapper