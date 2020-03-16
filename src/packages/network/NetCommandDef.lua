module("NetCommandDef", package.seeall)

------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------服-务-器-推-送---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-----战斗相关----
n_battle_end_wait = "notify.battle.end_wait" 	--匹配玩家超时
-- 返回参数
-- {
--    code:number; 
-- }

n_battle_baseInfo = "notify.battle.info"  --玩家对战信息
-- 返回参数
-- {
--   battle_id:number;
--   config: {
--     hp1:number;
--     hp2:number;
--     f1:number;
--     f2:number;
--     f3:number;
--     f4:number;
--     f5:number;
--     f6:number;
--     skin1:number;
--     skin2:number;
--     power_1: number; //战斗力
--     power_2: number;
--   };
--   uid_1: number;
--   uid_2: number;
--   name_1: string; //玩家名称
--   name_2: string; //玩家名称
--   power_1: number; //战斗力
--   power_2: number;
--   animation: number; //进场动画总时长
-- }
n_battle_ready = "notify.battle.ready"	--准备阶段
-- 返回参数
-- {
--    battle_id:string;
-- }
n_battle_start = "notify.battle.start"	--战斗开始
-- 返回参数
-- {
--   battle_id:number;
--   config: {
--     item1: {
--       ［index:string］:{
--          item_id:number; // 道具ID
--          count:number;   // 本场战斗消耗的数目
--          past:number;    // 上一次释放距今时长(秒)
--        }
--     }; //uid1的道具消耗信息
--     item2: {
--       ［index:string］:{item_id:number;count:number;past:number}
--     }; //uid2的道具消耗信息
--   };
--   uid_1: number;
--   uid_2: number;
-- }
n_battle_event = "notify.battle.event"	--战斗中使用技能，使用物品等事件
-- 返回参数
-- {
--   ship_index:number;
--   type:"fort_skill"|"use_item"|"surrender";
--   arg?:number;
--   fort_index?:number;
--   item_id?:number;
--   /** 服务增加的标识*/
--   frame:number;  //事件发生的帧数位置
--   seqnum:number; //事件的顺序号
-- }
n_battle_result = "notify.battle.result"	--战斗结果
-- 返回参数
-- {
--   code:number;
--   result: {
--     recoup:{item_id:number,count:number}[]; //系统补偿
--     trophy:{item_id:number,count:number}[]; //掠夺奖励,
--     lost:  {item_id:number,count:number}[]; //被掠夺物品
--     win: number; // 1:胜利 0:失败 2:平局
--   }
-- }
n_battle_over = "notify.battle.over" 		--战斗结束
-- 返回参数
-- {
--    code:number;
--    battle_id: string;
--    winner:string; //胜者UID
--    timeout: number; //plunder timout
--    scores:{[index:string]:number}; //比分, 形如: "scores":{"cfcde268586da7d23421b20a02753643":0,"cfcde268583e396ee88516a7edd50c29":3}
-- }

----复仇相关----
n_battle_revenge = "notify.battle.revenge_req"




------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------客-户-端-请-求---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

----登录相关--
s_gate_knock = "gate.knockHandler.knock" --获取逻辑服务器IP和port

s_login_reconnect = "login.userHandler.reconnect" -- 用户重连

s_ask_seed = "connector.entryHandler.askSeed" -- 请求种子



----战斗相关----
s_battle_check_exist = "battle.matchHandler.check_exists_battle" 	--是否存在未结束的战斗

s_battle_check_waiting = "battle.matchHandler.check_waiting"		--是否在匹配其他玩家（未使用）
-- 返回参数
-- {
--    code:number;
--    waiting:boolean;
-- }
s_battle_wait = "battle.matchHandler.wait_for_battle" 			--匹配玩家
-- 返回参数
-- {
--    //和`check_exists_battle`相似
--     code:number;
--     found:boolean;
--     data:Buffer;
--     config:any;
--     timeout:number; //最长等待时间[秒]
-- }
s_battle_cancel_wait = "battle.matchHandler.cancel_wait"			--取消匹配
-- 返回参数
-- {
--    code:number;
--    cancel:boolean; //是否成功取消等待
-- }
s_battle_emit_event = "battle.battleHandler.emitEvent"			--玩家操作
-- 上传玩家战斗操作, 用户的所有战斗操作通过这个消息上传
-- fort_skill:炮台释放技能
-- use_item: 使用道具
-- surrender: 投降
-- 样例:
-- 炮台技能 {type:"fort_skill", fort_index:2}
-- 道具使用 {type:"use_item", item_id: 1500, arg: 1}
-- 投降 {type: "surrender"}
-- 请求参数
-- {
--   name: "fort_skill"|"use_item"|"surrender"; //事件类型
--   arg?: number;　//仅在type为`use_item`时, 对应炮台索引/陨石ID
--   fort_index?:number; //仅在type为`fort_skill`时置值为炮台索引[0-5]
--   item_id?:number; //仅在type为`use_item`时,置为道具的`id`
-- }
-- 返回参数
-- {
--    code:number;
--    data:null|any; //
-- }
s_battle_download_snapshot = "battle.battleHandler.downloadSnapshot" --下载当前的最新的战斗快照, 主要用于快速更新. 不包含初始化战斗数据
-- 返回参数
-- {
--    code:number;
--    data:Buffer; //快照数据
--    frame:number; //当前帧数
-- }

s_battle_choose_plunder = "battle.battleHandler.plunder" -- 战斗结束后,选择掠夺类型
-- 返回参数
-- {
--   type:"money"|"material";
-- }
-- //-resp
-- {
--   code:number;
-- }

s_battle_submit_crach_log = "battle.battleHandler.crashLog" -- 提交战斗错误日志
-- 请求需要参数
-- {
-- 	log:string;
-- }
-- 返回参数
-- {
-- 	code:number;
-- }


-------------------------好友----相关---------------------------

s_friend_list = "social.friendHandler.list" -- 请求好友列表
-- 请求需要参数 rep
-- 	 nil 
-- 返回参数 resp
-- {
--   code:number;
--   friends:{
--        uid:string;        //好友的uid
--        name:string;       //好友的名称
--        icon:string;       // 暂定为玩家的头像（待）
--        level:number;      //好友等级 
--        power:number;      //好友战斗力
--        famous_num:number; //当前的声望数值

--       //在其他好友列表中的数据
--       /** 好感度 */
--       favorability:number;
--       /** 赠送CD*/
--       wish_cd:number;
--       wish_item_id:number; //心愿
--     }[]
-- }

s_friend_friend_request = "social.friendHandler.friend_requests" -- 请求好友的申请列表
-- 请求需要参数 rep
--   nil
-- 返回参数 resp
-- {
--    code:number;
--    request:{
--        uid:string;        //好友的uid
--        name:string;       //好友的名称
--        icon:string;       // 暂定为玩家的头像（待）
--        level:number;      //好友等级 
--        power:number;      //好友战斗力
--     }[]; //同`social.friendHandler.list`#`friends`
-- }

s_friend_advice_friends = "social.friendHandler.advice_friends" -- 系统推荐好友列表
-- 请求需要参数 rep
--   nil
-- 返回参数 resp

-- 此功能有待开发

s_friend_gifts_list = "social.giftHandler.gifts" -- 好友赠送礼物列表
-- 请求需要参数 rep
--   nil
-- 返回参数 resp
-- {
--   code:number;
--   data:{
--        uid:string;
--        name:string;
--        icon:string;
--        level:number;
--        power:number;          
--        item_id:number;        //赠送的物品
--        item_count:number;     //赠送物品的数量（一般都是1）
--        gift_send_past:number; //最近一次馈赠到现在的秒数
--   }[]
-- }

s_friend_search = "social.friendHandler.search" -- 搜索指定的好友
-- 请求需要参数 req
-- {
--    name:string; //要查找的用户名
-- }
-- 返回参数 resp
-- {
--    code:number;
--    data:{
--        uid:string;
--        name:string;
--        icon:string;
--        level:number;
--        power:number;
--     }[]; //同`social.friendHandler.list`#`friends`
-- }

s_friend_befriend = "social.friendHandler.befriend" -- 发送好友请求
-- 请求需要参数 req
-- {
-- 	friend:string;  // 目标玩家的uid
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_accept_friend = "social.friendHandler.befriend" -- 接收好友申请
-- 请求需要参数 req
-- {
-- 	friend:string; // 置空则接受所有好友
-- }
-- 返回参数resp
-- {
-- 	code:number;
-- }

s_friend_reject_friend = "social.friendHandler.reject_friend" -- 拒绝好友请求
-- 请求需要参数 req
-- {
-- 	friend:string; // 置空则拒绝所有好友
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_gift_wish = "social.giftHandler.wish" -- 向好友发布祈愿
-- 请求需要参数 req
-- {
-- 	item_id:number; // 祈愿想要得到的物品id
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_gift_give = "social.giftHandler.give" -- 给好友赠送物品
-- 请求需要参数 req
-- {
-- 	friend:string; //
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_gift_take = "social.giftHandler.take" -- 接受所有礼物
-- 请求需要参数 req
-- 	nil
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_breakup = "social.friendHandler.breakup" -- 删除好友(接触两个人的好友关系)
-- 请求需要参数 req
-- {
-- 	friend:string;
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_have_new_msg = "social.friendHandler.have_new_msg" -- 请求看看是否有好友的新消息
-- 请求需要参数 req
-- 	nil
-- 返回参数 resp
-- {
--   	code:number;
--   	data:string[];  //对应有新消息的好友uid数组
-- }

s_friend_update_chat_read = "social.friendHandler.update_chat_read" -- 更换好友消息（聊天记录）为已读
-- 打开聊天窗口和关闭聊天窗口时调用
-- 请求需要参数 req
-- {
-- 	friend:string;
-- }
-- 返回参数 resp
-- {
-- 	code:number;
-- }

s_friend_unread_chat_log = "social.friendHandler.unread_chat_log" -- 请求获取未读的好友消息
-- 请求需要参数 req
-- {
-- 	friend:string;
-- }
-- 返回参数 resp
-- {
-- 	code:number;
--    	unread_chat:{      //所有聊天记录
--         sender: string;    //发送者uid
--     	receiver: string;  //接收者uid
--     	msg: string;       //这条消息的内容
--     	time: string;      //发件时间，格式yyyy-mm-dd HH:MM:ss
--     	is_read: boolean;  //是否已读
--     }[];
-- }

s_friend_all_chat_log = "social.friendHandler.all_chat_log" -- 请求获取好友间全部聊天记录（ 未用 ）
-- 请求需要参数 req
-- {
-- 	friend:string;
-- }
-- 返回参数 resp
-- {
-- 	code:number;
--     all_chat:{  //所有聊天记录
--      	sender: string;  //发送者uid
--      	receiver: string;  //接收者uid
--      	msg: string;
--      	time: string;  //发件时间，格式yyyy-mm-dd HH:MM:ss
--      	is_read: boolean;  //是否已读
--     }[];
-- }

s_friend_chat_push_msg_to_friend = "chat.chatHandler.push_msg_to_friend" -- 发送消息给好友
-- 请求需要参数 req
-- {
-- 	friend:string;  // 好友的uid
-- 	msg:string; // 发送消息的内容
-- }
-- 返回参数 resp
-- {
--   	code:number;
--   	chat:{
--    		sender:string;  // 发送人的uid
--    		receiver:string;// 接收者的uid
--    		msg:string;     // 发送消息的内容
--    		time:string;    // 发送消息的时间
-- 	};
-- }

n_friend_chat_friend_msg = "notify.chat.friend_msg" -- 接收好友私聊发来的消息
-- 返回参数 resp02
-- {
-- 	any:{
--     	msg:string;
--     	time:Date;      //发件日期,格式:yyy-mm-dd HH:MM:ss
--     	sender:string;  //发送人
--     }
-- }

n_friend_gift_receive = "notify.social.gift_recv" -- 接收好友赠送的物品
-- 返回参数 resp
-- {
-- 	code:number;
-- }

n_friend_friend_request = "notify.social.friend_req" -- 响应发来的好友申请
-- 返回参数 resp
-- {
-- 	code:number;
-- }




----------------------- 战舰-- 相关------------------------------

s_ship_fort_list = "game.syncHandler.fortList"  -- 登录后初始化加载玩家所有炮台信息（在loginScene中）
-- 请求需要参数 
-- 	nil
-- 返回参数
-- {
--    code:number;
--    forts:{
--         fort_id:number; //服务器标记炮台的id
--         ref_id: number; //配表中的ID（每一炮台对应等级的一个id)
--         exp:number;     //炮台当前经验
--         level:number;   //炮台等级
--         skill_id:number;//技能id
--     }[]; 
-- }

s_ship_puton_fort = "game.fortHandler.putonFort" -- 放置/使用炮台（请求变更炮台装备）
-- 请求需要参数
-- {
-- 	fort_id:number;	  炮台的fort_id
-- 	pos:number;       炮台放置的位置（0-2）
-- }
-- 返回参数
-- {
-- 	code:number;
--     forts: {fort_id:number, ref_id: number}[]; //3个位置的fort, 不存在则置为-1. 
-- }

s_ship_unlock_fort = "game.fortHandler.unlockFort" --解锁炮台
-- 请求需要参数
-- {
-- 	ref_id:number;
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_ship_upgrade_fort = "game.fortHandler.upgradeFort" -- 升级炮台
-- 请求需要参数
-- {
-- 	item_id: number;  //用于升级的物品id
--     fort_id: number;  // 炮台的ID
--     count: number;    //使用道具的数目, 默认1
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_ship_advance_fort = "game.fortHandler.advanceFort" --进阶炮台
-- 请求需要参数
-- {
--     fort_id:number; //炮台ID
-- }
-- 返回参数//--resp
-- {
--     code:number;
-- }

s_ship_upgrade_fort_skill = "game.fortHandler.upgradeFortSkill" -- 进阶炮台技能
-- 请求需要参数
-- {
-- 	fort_id:number;
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_ship_unlock_skin = "game.shipHandler.unlockShip" -- 解锁皮肤
-- 请求需要参数
-- {
-- 	skin_id:number; // 配表中的warship_id;
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_ship_use_skin = "game.shipHandler.activeShip" -- 请求使用皮肤
-- 请求需要参数
-- {
-- 	skin_id:number; // warship_id
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_ship_skin_list = "game.syncHandler.skinList" -- 请求皮肤列表
-- 请求需要参数
--  nil 
-- 返回参数
-- {
--    code:number;
--    skins:number[]; //配表中的warship_id _列表	
-- }

n_ship_fort_update = "notify.fort.update" -- 炮台信息变更
-- 返回参数
-- {
-- 	code:number;       // 新炮台的数据
--     fort_id:number;
--     ref_id: number; 
--     exp: number;
--     level:number;
--     skill_id:number;
-- }

n_ship_fort_add = "notify.fort.add" -- 通知新增炮台
-- 返回参数
-- {
--     code:number;
--     fort_id: number;   // 给的是新增炮台的信息
--     ref_id: number;    // 90000
-- }

n_ship_fort_remove = "notify.fort.remove" -- 炮台被删除（仅在作弊时候有效）
-- 返回参数
-- {
--     code:numbe;
--     fort_id:number;
--     ref_id:number;	
-- }

n_ship_fort_update_active = "notify.fort.update_active" -- 变更装备的炮台
-- 返回参数
-- {
-- 	code:number;
-- 	forts:number[];  //3个位置的fort, 不存在则置为-1.
-- }

n_ship_skin_add = "notify.skin.add" -- 新增皮肤的通知
-- 返回参数
-- {
--    code:number;
--    skin_id:number;//配表中的warship_id
-- }

n_ship_skin_remove = "notify.ship.remove" -- 皮肤删除（仅在作弊命令中推送）
-- 返回参数
-- {
-- 	code:number;
--     skin_id:number;
-- }



-----------------------  复仇 --- 相关 -------------------------

s_revenge_revenge_list = "social.friendHandler.revenge_list" -- 查看仇恨列表
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
--     code:number;
--     data:{
--     	uid:string;      //复仇对象uid
--    		name:string;	 //复仇对象的名字
--     	level:number;    //复仇对象的等级
--     	power:number;    //xxxxxx的战斗力
--     	icon:string;     //
--   		famous_num:number;// 声望
--     	online:boolean; //是否在线
--     }[]; // 玩家列表	
-- }

s_revenge_revenge_req = "battle.matchHandler.revenge_req" -- 发起复仇请求
-- 请求需要参数
-- {
-- 	enemy:string;     //敌人的uid
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_revenge_revenge_resp = "battle.matchHandler.revenge_resp" -- 接收/拒绝复仇
-- 请求需要参数
-- {
-- 	enemy:string;    // 敌人的uid
-- 	accept:boolean;  // 是否接受
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

n_revenge_revenge_req = "notify.battle.revenge_req"  -- 有玩家进行复仇请求，推送对方结果
-- 返回参数
-- {
-- 	code:number;
--     from:string;       // uid
--     timeout: number;   // 时间

--     name:string;       // 名字
--     level:number;
--     power:number;
--     icon:string;
--     famous_num:number;
-- }

n_revenge_revenge_refuse = "notify.battle.revenge_refuse"  -- 玩家请求复仇后得到的回复
-- 返回参数
-- {
-- 	code:number;
--     accept:bool; // 是否结束复仇.  true-准备战斗 false-不战斗
-- }


-------------------- 贩售舰--相关-----------------------------

s_shop_buy_item = "game.shopHandler.buyItem"  -- 购买物品
-- 请求需要参数
-- {
-- 	product_id: number;  //购买物品的ID
--     count: number;       //购买数量
-- }
-- 返回参数
-- {
-- 	code:number;
--     items?:{
--         item_id:number; 
--         count:number;
--     }[];
-- }



--------------------资源库--相关 ---------------------------

s_resource_active_equips = "game.syncHandler.activeEquips" -- 请求道具装备列表  （在loginScene里请求）
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
-- 	code: 1;
--     items: {
--         item_id:number
--     }[];       // 装备道具id的table
-- }

s_resource_request_change_equips = "game.itemsHandler.activeEquips" -- 请求变更装备
-- 请求需要参数
-- {
-- 	item_id:number;    // item_id 为 -1时, 效果和deactiveEquipByPos相同
--     pos:number;     // 0 - 4, 位置
-- }
-- 返回参数
-- {
-- 	code: 1;
--     items: {
--         item_id:number
--     }[];       // 装备道具id的table
-- }

s_resource_deactive_equip = "game.itemsHandler.deactiveEquipByPos" -- 卸载装备（未用）
-- 请求需要参数
-- {
-- 	pos:number;  //卸载装备的位置 0-4
-- }
-- 返回参数
-- {
-- 	code: 1;
--     items: {
--         item_id:number
--     }[];       // 装备道具id的table
-- }

s_resource_upgrade_item = "game.itemsHandler.upgradeItem" -- 升级装备（单个/多个）
-- 请求需要参数
-- {
--      item_id:number; //升级的物品ID
--      count?: number; //数目
-- }
-- 返回参数
-- {
-- 	    code:number;
-- }

n_resource_active_equip = "notify.syncHandler.activeEquips" -- 同步装备资源库列表（装备变更）
-- 返回参数
-- {
-- 	code: 1;
--     items: {
--         item_id:number
--     }[];       // 装备道具id的table
-- }


-------------------- 生产 -- 相关 ----------------------

s_produce_produce_queue = "game.syncHandler.produceQueue" -- 请求生产队列
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
-- 	code:number;
--     max_size: number; //生产队列大小（解锁了的）
--     items: {
--         item_id: number; // 如果为空,值为-1
--         count: number; 
--         remain: number; //剩余的升级时间, 单位[毫秒]
--         index: number;  //位置 0~9
--     }[];
-- }

s_produce_unlock_produce_queue = "game.itemsHandler.unlockProduceQueue" -- 使用道具解锁生产队列
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
--     code:numer;
-- }

s_produce_speed_up_produce = "game.itemsHandler.speedupProduceQueue" -- 加速生产（使用加速器，立即完成）
-- 请求需要参数
-- {
--     item_id:number;  //用于加速的物品, 4009 or 10002 ?
--     queue_id:number; //加速的格子 0~9
--     count?:number;   //为4009预留字段, 暂时不做处理	
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_produce_produce_item = "game.itemsHandler.produceItem" -- 生产物品
-- 请求需要参数
-- {
--     item_id: number;   //目标 物品
--     count: number;     //数目
--     queue_id: number;  //生成队列的位置: 0~9. 	
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

n_produce_produce_queue = "notify.produce.produceQueue"  -- 更新生产队列
-- 返回参数
-- {
-- 	code:number;
--     max_size: number; //生产队列大小（解锁了的）
--     items: {
--         item_id: number; // 如果为空,值为-1
--         count: number; 
--         remain: number; //剩余的升级时间, 单位[毫秒]
--         index: number;  //位置 0~9
--     }[];	
-- }


----------------------邮件--相关---------------------------

s_mail_load_mail = "mail.mailHandler.load_mail" -- 请求邮件列表
-- 请求需要参数
-- 	nil -- 为空请求所有邮件，不为空（即可选填邮件类型）
-- 	邮件类型: 系统邮件:system | 打劫贩售舰:ship | 反攻地球:earth | 公域混战:domain | 联盟PK:alliance
-- 返回参数
-- {
--     code:number;
--     mail_list:{
--     	id:number;                 //邮件唯一标识 - id
--     	type:string;               //邮件类型
--    	content:string;            //邮件内容
--     	title:string;              //邮件标题
--    	attachment:{item_id:number,count:number}[]; //附件数组
--     	created_at:string;         //创建时间的字符串，如2017-03-06
--     	mail_state: number;        //邮件状态
--     }[];
-- }

s_mail_mark_read = "mail.mailHandler.mark_read" -- 标记邮件状态
-- 请求需要参数
-- {
-- 	mail_id:number;
-- }
-- 返回参数
-- {
-- 	code:number;
-- }

s_mail_recv_mail = "mail.mailHandler.recv_mail" -- 接收邮件
-- 请求需要参数
-- {
-- 	mail_id:number;  //接收单一邮件，创建mail_id并带值
-- 	is_all:boolean;  //接收所有邮件，创建is_all并赋值true
-- }
-- 返回参数
-- {
--     code:number;
--     attachment_list?:{item_id:number,count:number}[];	// 接收到了的附件数据
-- }

s_mail_delete_mail = "mail.mailHandler.delete_mail" -- 删除邮件
-- 请求需要参数
-- {
-- 	mail_id:number;  //删除单一邮件，创建mail_id并带值
-- 	is_all:boolean;  //删除所有邮件，创建is_all并赋值true
-- }
-- 返回参数
-- {
--     code:number;
-- }

n_mail_recv = "notify.mail.recv" -- 接收新来的邮件，系统推送过来的。
-- 返回参数
-- {
--     	id:number;                 //邮件唯一标识 - id
--     	type:string;               //邮件类型
--    	content:string;            //邮件内容
--     	title:string;              //邮件标题
--    	attachment:{item_id:number,count:number}[]; //附件数组
--     	created_at:string;         //创建时间的字符串，如2017-03-06
--     	mail_state: number;        //邮件状态
-- }


----------------------主界面---相关------------------------

s_main_search_floating_obj = "game.activityHandler.search_floating_obj" -- 请求漂流物奖励数据
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
-- 	code:number;
--     count:number;	   //漂流物数量
--     item_id:number;    //漂流物id
-- }

n_main_has_floating_obj = "notify.activity.has_floating_obj" -- 漂流物的浮现
-- 返回参数
-- {
-- 	code:number;
-- }


---------------------登录--相关------------------------
s_login_load_items = "game.syncHandler.loadItems"  -- 请求资源库物品
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
--     code:number;
--     items:{
--         item_id:number;
--         item_count:number;
--         active:boolean; //是否处于装备列表中
--     }[];	
-- }

s_login_user_info = "game.syncHandler.userInfo" -- 请求玩家数据
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
--     code: number;
--     global_id?:string;		 //玩家uid
--     nickname?:string;        //昵称
--     alliance_coin?:number;   //联盟币
--     universal_coin?:number;  //星际币
--     diamond?:number;         //钻石
--     power?:number;           //战斗力
--     defence?:number;         //
--     exp?:number;             //经验
--     max_exp?:number;         //
--     famous_num?: number;  //玩家的声望
--     famous_id?: number; //在配表rank_exp中的军衔ID	
-- }

s_login_shipInfo = "game.syncHandler.shipInfo"  --请求战舰信息
-- 请求需要参数
-- 	nil
-- 返回参数
-- {
--     code:number;
--     global_id:string;     //uid
--     skin:number;          //皮肤号
--     forts:{ref_id:number, exp?:number, level?:number}[]	//装备中的炮台
-- }

s_login_active_equips = "game.syncHandler.activeEquips" -- 同上s_resource_active_equips（请求道具装备列表）

s_login_fort_list = "game.syncHandler.fortList"  -- 同上 s_ship_fort_list（登录后，加载玩家所有炮台信息）

s_login_skin_list = "game.syncHandler.skinList" -- 同上s_ship_skin_list（请求皮肤列表）

----------------------------------------------------------------------------------

n_game_item_delta = "notify.item.delta" -- 玩家背包中增加或减少物品
-- 返回参数
-- {
--     code:number;
--     item_id:number;
--     count: number; //当前的总量,最终
--     delta: number;　//变换的数目, 正数增加/负数减少	
-- }

n_game_money_update = "notify.money.update" -- 货币的变更
-- 返回参数
-- {
--     code:number,
--     universal_coin: number; //星际币
--     alliance_coin: number; //联盟币
--     diamond: number; //钻石
-- }

n_game_info_change = "notify.info.change" -- 更新玩家信息：比如声望、等级的改变
-- 返回参数
-- {
--     code: number; 
--     level: number;       // 玩家等级
--     exp: number;         //玩家经验; 
--     famous_num?: number;  //玩家的声望
--     famous_id?: number;  //在配表rank_exp中的军衔ID	
-- }





