local BattleResourceMgr = require("app.utils.BattleResourceMgr")
local BulletMgr = class("BulletMgr")

local g_bulletNum = 6; 	--子弹的初始缓存个数
local playerShip = 1;
local enemyShip = 2 ;

local BATTLE_WIDTH = 1280; --1280做整体缩放
local BATTLE_HEIGHT = 720; 	--720做整体缩放

function BulletMgr:Init(nodeBullet)
	-- print("BulletMgr:ctor")
	self.m_nodeParent = nodeBullet;
	-- self.m_armatureBullet = {}; --old
	self.m_playerArmatureBullet = {};--子弹动画容器（包含子弹id序号，动画节点，出现的子弹个数），容器初始化
	self.m_enemyArmatureBullet = {};
	--玩家
	for i= 1, 3 do
		local fortID = BattleDataMgr:getFortIDByfortPos(i, playerShip);
		-- print("炮台ID", fortID)
		local bulletID = FortDataMgr:getFortBaseInfo(fortID).id;
		-- print("子弹ID", bulletID)
		self.m_playerArmatureBullet[bulletID] = {};
		self.m_playerArmatureBullet[bulletID].armatures = {};
		self.m_playerArmatureBullet[bulletID].actives = {};

		local batchNode = cc.SpriteBatchNode:create(BattleResourceMgr:getBulletSprite(bulletID, true));
		self.m_nodeParent:addChild(batchNode);

		self.m_playerArmatureBullet[bulletID].batchNode = batchNode;
		for j = 1, g_bulletNum do
			-- local armature = BattleResourceMgr:getBulletArmature(bulletID);
			-- self.m_nodeParent:addChild(armature);
			local bulletSprite = cc.Sprite:createWithTexture(batchNode:getTexture());
			batchNode:addChild(bulletSprite);
			-- self.m_playerArmatureBullet[bulletID].armatures[j] = armature;
			self.m_playerArmatureBullet[bulletID].armatures[j] = bulletSprite;
			self.m_playerArmatureBullet[bulletID].actives[j] = -1;
			self.m_playerArmatureBullet[bulletID].bulletNum = 1;
			-- armature:setVisible(false);
			bulletSprite:setVisible(false);
		end
	end
	--敌人
	if BattleDataMgr:getBattleType() ~= 3 then
		for i= 1, 3 do
			local fortID = BattleDataMgr:getFortIDByfortPos(i, enemyShip);
			local bulletID = FortDataMgr:getFortBaseInfo(fortID).id;
			self.m_enemyArmatureBullet[bulletID] = {};
			self.m_enemyArmatureBullet[bulletID].armatures = {};
			self.m_enemyArmatureBullet[bulletID].actives = {};
			local batchNode = cc.SpriteBatchNode:create(BattleResourceMgr:getBulletSprite(bulletID, false));
			self.m_nodeParent:addChild(batchNode);

			self.m_enemyArmatureBullet[bulletID].batchNode = batchNode;
			for j= 1, g_bulletNum do
				-- local armature = BattleResourceMgr:getBulletArmature(bulletID);
				-- self.m_nodeParent:addChild(armature);
				local bulletSprite = cc.Sprite:createWithTexture(batchNode:getTexture());
				batchNode:addChild(bulletSprite);
				-- self.m_enemyArmatureBullet[bulletID].armatures[j] = armature;
				self.m_enemyArmatureBullet[bulletID].armatures[j] = bulletSprite;
				self.m_enemyArmatureBullet[bulletID].actives[j] = -1;
				self.m_enemyArmatureBullet[bulletID].bulletNum = 1;
				-- armature:setVisible(false);
				bulletSprite:setVisible(false);
			end
		end
	end
	self.m_playerHitEffect = {};
	self.m_enemyHitEffect = {};
end

--战斗开始时的子弹数据刷新
function BulletMgr:refreshPlayerBullets()
	-- print("BulletMgr:refreshPlayerBullets")
	local playerBullets = newBattle.playerBulletData();
	-- print("玩家子弹")
	-- dump(playerBullets)
-- 	{
-- 	bulletID
-- 	bulletIndex (双方各自计算)
-- 	fortIndex
-- 	owner_isEnemy
-- 	x
-- 	y
-- }
	local shipPos = 1;
	for k, v in pairs(playerBullets) do	
		local armature = self:showPlayerBulletArmature(v.bulletID, v.bulletIndex); -- 显示子弹动画
		if armature ~= nil then
			armature:setPosition(v.x - BATTLE_WIDTH * 0.5, v.y - BATTLE_HEIGHT * 0.5);
		end
	end
end

function BulletMgr:refreshEnemyBullets()
	-- print("BulletMgr:refreshEnemyBullets")
	local enemyBullets = newBattle.enemyBulletData();
	-- print("对方子弹")
	-- dump(enemyBullets)
	local shipPos = 2;
	for k,v in pairs(enemyBullets) do
		local armature = self:showEnemyBulletArmature(v.bulletID, v.bulletIndex); -- 显示子弹动画
		if armature ~= nil then
			armature:setScaleX(-1);
			armature:setPosition(v.x - BATTLE_WIDTH * 0.5, v.y - BATTLE_HEIGHT*0.5);
		end
	end
end

--显示动画
function BulletMgr:showPlayerBulletArmature(bulletID, bulletIndex)
	-- print("子弹的动画ID", bulletID, "子弹的Index", bulletIndex);
	local bulletKey = table.find(self.m_playerArmatureBullet[bulletID].actives, bulletIndex);
	if bulletKey ~= nil then
		-- print(bulletID,"中存在子弹",bulletIndex);
		return self.m_playerArmatureBullet[bulletID].armatures[bulletKey]
	else
		if self.m_playerArmatureBullet[bulletID].bulletNum > g_bulletNum then
			-- print("超出容量，增加子弹",self.m_playerArmatureBullet[bulletID].bulletNum);
			g_bulletNum = self.m_playerArmatureBullet[bulletID].bulletNum;
			self.m_playerArmatureBullet[bulletID].bulletNum = g_bulletNum+1;
			self.m_playerArmatureBullet[bulletID].actives[g_bulletNum] = bulletIndex;
			-- local armature = BattleResourceMgr:getBulletArmature(bulletID);
			local bulletSprite = cc.Sprite:createWithTexture(self.m_playerArmatureBullet[bulletID].batchNode:getTexture());
			-- self.m_playerArmatureBullet[bulletID].armatures[g_bulletNum] = armature;
			self.m_playerArmatureBullet[bulletID].armatures[g_bulletNum] = bulletSprite;
			-- self.m_playerArmatureBullet[bulletID].armatures[g_bulletNum]:getAnimation():play("loop");
			-- self.m_nodeParent:addChild(armature);
			self.m_nodeParent:addChild(bulletSprite);
			return self.m_playerArmatureBullet[bulletID].armatures[g_bulletNum];
		else
			for i= 1, g_bulletNum do
				if self.m_playerArmatureBullet[bulletID].actives[i] == -1 then	
					if not self.m_playerArmatureBullet[bulletID].armatures[i] then	
						dump(self.m_playerArmatureBullet);
						print("   bullet ID  == : ", bulletID, "   index  === i : ", i);
					end								
					self.m_playerArmatureBullet[bulletID].armatures[i]:setVisible(true);			
					-- self.m_playerArmatureBullet[bulletID].armatures[i]:getAnimation():play("loop")
					self.m_playerArmatureBullet[bulletID].actives[i] = bulletIndex;
					self.m_playerArmatureBullet[bulletID].bulletNum = self.m_playerArmatureBullet[bulletID].bulletNum + 1;
					-- print("创建子弹", bulletID, bulletID, i);
					return self.m_playerArmatureBullet[bulletID].armatures[i];
				end
			end
		end
	end
end

function BulletMgr:showEnemyBulletArmature(bulletID, bulletIndex)
	-- print("子弹的动画ID", bulletID, "子弹的Index", bulletIndex);
	local bulletKey = table.find(self.m_enemyArmatureBullet[bulletID].actives, bulletIndex);
	if bulletKey ~= nil then
		-- print(bulletID,"中存在子弹",bulletIndex);
		return self.m_enemyArmatureBullet[bulletID].armatures[bulletKey]
	else
		if self.m_enemyArmatureBullet[bulletID].bulletNum > g_bulletNum then
			-- print("超出容量，增加子弹",self.m_enemyArmatureBullet[bulletID].bulletNum);
			g_bulletNum = self.m_enemyArmatureBullet[bulletID].bulletNum;
			self.m_enemyArmatureBullet[bulletID].bulletNum = g_bulletNum+1;
			self.m_enemyArmatureBullet[bulletID].actives[g_bulletNum] = bulletIndex;
			-- local armature = BattleResourceMgr:getBulletArmature(bulletID);
			local bulletSprite = cc.Sprite:createWithTexture(self.m_enemyArmatureBullet[bulletID].batchNode:getTexture());
			-- self.m_enemyArmatureBullet[bulletID].armatures[g_bulletNum] = armature;	
			self.m_enemyArmatureBullet[bulletID].armatures[g_bulletNum] = bulletSprite;							
			-- self.m_enemyArmatureBullet[bulletID].armatures[g_bulletNum]:getAnimation():play("loop");
			-- self.m_nodeParent:addChild(armature);
			self.m_nodeParent:addChild(bulletSprite);
			return self.m_enemyArmatureBullet[bulletID].armatures[g_bulletNum];
		else
			for i= 1, g_bulletNum do
				if self.m_enemyArmatureBullet[bulletID].actives[i] == -1 then
					if not self.m_enemyArmatureBullet[bulletID].armatures[i] then
						print( " bulletID : ", bulletID, "  i: ", i);
						dump(self.m_enemyArmatureBullet);
					end
					self.m_enemyArmatureBullet[bulletID].armatures[i]:setVisible(true);			
					-- self.m_enemyArmatureBullet[bulletID].armatures[i]:getAnimation():play("loop")
					self.m_enemyArmatureBullet[bulletID].actives[i] = bulletIndex;
					self.m_enemyArmatureBullet[bulletID].bulletNum = self.m_enemyArmatureBullet[bulletID].bulletNum + 1;
					-- print("创建子弹", bulletID, bulletID, i);
					return self.m_enemyArmatureBullet[bulletID].armatures[i];
				end
			end
		end
	end
end

--隐藏动画
function BulletMgr:hidePlayerBulletArmature(bulletID, bulletIndex)
	for i = 1, g_bulletNum do
		--消除小于等于bulletIndex的子弹
		if self.m_playerArmatureBullet[bulletID] and self.m_playerArmatureBullet[bulletID].actives[i] and self.m_playerArmatureBullet[bulletID].actives[i] ~= -1 
			and bulletIndex >= self.m_playerArmatureBullet[bulletID].actives[i] then
			self.m_playerArmatureBullet[bulletID].bulletNum = self.m_playerArmatureBullet[bulletID].bulletNum - 1;
			-- print("消除玩家子弹", bulletID, bulletIndex)
    		self.m_playerArmatureBullet[bulletID].armatures[i]:setVisible(false);
    		self.m_playerArmatureBullet[bulletID].actives[i] = -1;
		end
	end
end

function BulletMgr:hideEnemyBulletArmature(bulletID, bulletIndex)
	for i = 1, g_bulletNum do
		if self.m_enemyArmatureBullet[bulletID] and self.m_enemyArmatureBullet[bulletID].actives[i]
		 and self.m_enemyArmatureBullet[bulletID].actives[i] ~= -1 and
		 bulletIndex >= self.m_enemyArmatureBullet[bulletID].actives[i] then
		 	self.m_enemyArmatureBullet[bulletID].bulletNum = self.m_enemyArmatureBullet[bulletID].bulletNum-1;
		 	-- print("消除敌人子弹",bulletID,bulletIndex);
		 	self.m_enemyArmatureBullet[bulletID].armatures[i]:setVisible(false);
		 	self.m_enemyArmatureBullet[bulletID].actives[i] = -1;
		end
	end
end

function BulletMgr:refreshBulletEvent()
	local events = newBattle.hitBulletData();
--     1 = {
--		   "isEnemy"	 = true
--         "bulletIndex" = 31
--         "bulletID"	 = 90101
--         "x"           = 1110
--         "y"           = 460
--      }
	-- local shipPos = -1;
	if #events ~= 0 then
		-- dump(events)
		for k, v in pairs(events) do
			if v.isEnemy == true then
				local isHitBullet = table.find(self.m_enemyArmatureBullet[v.bulletID].actives, v.bulletIndex)
				if isHitBullet ~= nil then
					self:hideEnemyBulletArmature(v.bulletID, v.bulletIndex); --判断条件隐藏子弹动画
					self:enemyHitEffect(v.bulletIndex, v.x, v.y);		
				else
					-- print("error:敌人hit子弹错误发送");
					return;
				end
			else
				local isHitBullet = table.find(self.m_playerArmatureBullet[v.bulletID].actives, v.bulletIndex)
				if isHitBullet ~= nil then
					self:hidePlayerBulletArmature(v.bulletID, v.bulletIndex); --判断条件隐藏子弹动画
					self:playerHitEffect(v.bulletIndex, v.x, v.y);	
				else
					-- print("error:玩家hit子弹错误发送");
					return;
				end
			end
		end
	else
		return;
	end
end

function BulletMgr:enemyHitEffect(bulletIndex, posX, posY)
	-- print("enemyHitEffect", bulletIndex, posX, posY);
	if self.m_enemyHitEffect[bulletIndex] == nil then
		self.m_enemyHitEffect[bulletIndex] = BattleResourceMgr:getNormalHitEffect();
	end
	if self.m_enemyHitEffect[bulletIndex] then
		self.m_enemyHitEffect[bulletIndex]:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5);

		self.m_nodeParent:getParent().m_ccbNodeEnergy:addChild(self.m_enemyHitEffect[bulletIndex]);
		self.m_enemyHitEffect[bulletIndex]:getAnimation():play("anim01");
		self.m_enemyHitEffect[bulletIndex]:getAnimation():setMovementEventCallFunc(
			function (armatureBack, movementType, movementID)
				if movementType == ccs.MovementEventType.complete then
					-- if self.m_enemyHitEffect[bulletIndex] ~= nil then
						self.m_enemyHitEffect[bulletIndex]:removeSelf();
						self.m_enemyHitEffect[bulletIndex] = nil;
					-- end
				end
			end)
	end
end

function BulletMgr:playerHitEffect(bulletIndex, posX, posY)
	-- print("playerHitEffect", bulletIndex,posX,posY)
	if self.m_playerHitEffect[bulletIndex] == nil then
		self.m_playerHitEffect[bulletIndex] = BattleResourceMgr:getNormalHitEffect();
	end
	if self.m_playerHitEffect[bulletIndex] then
		self.m_playerHitEffect[bulletIndex]:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5);

		self.m_nodeParent:getParent().m_ccbNodeEnergy:addChild(self.m_playerHitEffect[bulletIndex]);


		self.m_playerHitEffect[bulletIndex]:getAnimation():play("anim01");
		self.m_playerHitEffect[bulletIndex]:getAnimation():setMovementEventCallFunc(
			function (armatureBack, movementType, movementID)
				if movementType == ccs.MovementEventType.complete then
					-- if self.m_playerHitEffect[bulletIndex] ~= nil then
						self.m_playerHitEffect[bulletIndex]:removeSelf();
						self.m_playerHitEffect[bulletIndex] = nil;
					-- end
				end
			end)
	end
end

return BulletMgr