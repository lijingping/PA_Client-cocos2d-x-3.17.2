local UserDataMgr =  class("UserDataMgr")

function UserDataMgr:Init()
	-- 玩家基本数据结构
	self.m_playerName = "";
	self.m_playerPower = 0;				--战斗力
	self.m_playerLevel = 1;
	self.m_playerLastLevel = 1;         --记录玩家上一个等级信息
	self.m_playerCurrentExp = 0;
	self.m_playerLevelUpExp = 0; 		--应该由客户端读表
	self.m_playerGoldCoin = 0;			--金币
	self.m_playerDiamond = 0; 			--钻石
	self.m_playerFamousId = 0;		 	--军衔等级
	self.m_playerFamous = 0;			--声望，用来计算军衔等级和当前升级进度
	self.m_playerUID = 0;
	self.m_playerContribution = 0;      --贡献值
	self.m_playerDecomposeCoin = 0;		--分解点数
	self.m_isRankAwardGet = nil;		--每日军饷是否领取

 	self.m_playerUnionCoin = 0;			--联盟币（暂时不用）
 	self.m_playerUnionLevel = 0;		--等级，没加入联盟为0
	self.m_applyLeagueAid = {};			--申请加入联盟的aid
	self.m_leagueBuildTotalLevel = 10;	--建筑总等级
	self.m_isLeagueChairman = true;
	self.m_isLeagueSubChairman = false;
	self.m_leagueBuildLevel = {1,0,0,0,1};
	self.m_leagueBadges = 1;
	self.m_isLeagueBuild = {false,false,false,false,false};
	self.m_leagueMoney = 10000;--联盟资金
	self.m_leagueData = {};
	self.m_leagueAid = 0;
	self.m_leagueContribute = 0;--联盟贡献度
	self.m_isJoinClose = true;

	-- 玩家状态
	self.m_isPVP = false;

	-- 加载数据表
	-- 军衔表
	self.m_rankExpTable = {};
	for k, v in pairs(table.clone(require("app.constants.rank_exp"))) do
		table.insert(self.m_rankExpTable, v);
	end
	table.sort(self.m_rankExpTable, function(a, b) return a.id < b.id; end);	

end

function UserDataMgr:setAllUseInfo(info)
	-- dump(info);
	self.m_playerName = info.nickname;
	self.m_playerPower = info.power;
	self.m_playerLevel = info.level;
	self.m_playerLastLevel = info.level;
	self.m_playerCurrentExp = info.exp;
	self.m_playerLevelUpExp = info.max_exp; 		
	self.m_playerGoldCoin = info.universal_coin;
	self.m_playerDiamond = info.diamond; 			
 	self.m_playerUnionCoin = info.alliance_coin;	
	self.m_playerFamousId = info.famous_id;
	
	self.m_playerFamous = info.famous_num;
	self:setPlayerRankInfo(self.m_playerFamous);

	self.m_playerUID = info.global_id;

	self.m_friendshipPoint = info.friendship_coin;

	--self:setLeftTimePlayerInvisible(info.hiding_second);
	self:setLeftTimeDoubleFloater(info.radar_second);
	self:setLeftTimeDoubleFriendship(info.friendship_buff_remain_second);

	-- 玩家许愿的物品id
	self.m_playerWishItemID = info.wish_item_id;
	ItemDataMgr:setWishSelectCell(info.wish_item_id);

	self.m_playerDecomposeCoin = info.decompose_coin;

	self.m_isRankAwardGet = (info.is_rank_award_get == 1);
end

function UserDataMgr:setPlyerUID(uid)
	self.m_playerUID = uid;
end

function UserDataMgr:getPalyerUID()
	return self.m_playerUID;
end

function UserDataMgr:setPlayerName(name)
	self.m_playerName = name;
end

function UserDataMgr:getPlayerName()
	return self.m_playerName;
end

function UserDataMgr:setPlayerPower(power)
	self.m_playerPower = power;
end

function UserDataMgr:getPlayerPower()
	return self.m_playerPower;
end

function UserDataMgr:setPlayerLevel(level)
	self.m_playerLevel = level;
end

function UserDataMgr:getPlayerLevel()
	return self.m_playerLevel
end

function UserDataMgr:setPlayerLastLevel(level)
	self.m_playerLastLevel = level;
end

function UserDataMgr:getPlayerLastLevel()
	return self.m_playerLastLevel;
end

function UserDataMgr:setPlayerExp(exp)
	self.m_playerCurrentExp = exp;
end

function UserDataMgr:getPlayerExp()
	return	 self.m_playerCurrentExp;
end

function UserDataMgr:setPlayerLvExp(maxExp)
	self.m_playerLevelUpExp = maxExp;
end

function UserDataMgr:getPlayerLvExp()
	return self.m_playerLevelUpExp;
end

--钻石
function UserDataMgr:setPlayerDiamond(diamond)
	self.m_playerDiamond = diamond;
end

function UserDataMgr:getPlayerDiamond()
	return self.m_playerDiamond;
end

--金币
function UserDataMgr:setPlayerGoldCoin(coin)
	self.m_playerGoldCoin = coin;
end

function UserDataMgr:getPlayerGoldCoin()
	return self.m_playerGoldCoin;
end

--联盟币
function UserDataMgr:setPlayerUnionCoin(coin)
	self.m_playerUnionCoin = coin;
end

function UserDataMgr:getPlayerUnionCoin()
	return self.m_playerUnionCoin
end

function UserDataMgr:setPlayerFamousId(FamousId)
	self.m_playerFamousId = FamousId;
end

function UserDataMgr:getPlayerFamousId()
	return self.m_playerFamousId;
end

function UserDataMgr:setPlayerFamous(FamousNum)
	self.m_playerFamous = FamousNum
end
 
function UserDataMgr:getPlayerFamous()
	return self.m_playerFamous;
end

function UserDataMgr:setFriendshipPoint(point)
	self.m_friendshipPoint = point;
end

function UserDataMgr:getFriendshipPoint()
	return self.m_friendshipPoint;
end

function UserDataMgr:setPlayerWishItemID(itemID)
	self.m_playerWishItemID = itemID;
end

function UserDataMgr:getPlayerWishItemID()
	return self.m_playerWishItemID;
end

-- 玩家联盟等级 
function UserDataMgr:setPlayerUnionLevel(level)
	self.m_playerUnionLevel = level;
end

function UserDataMgr:getPlayerUnionLevel()
	return self.m_playerUnionLevel;
end

-- 玩家贡献值
function UserDataMgr:setPlayerContribution(contribution)
	self.m_playerContribution = contribution;
end

function UserDataMgr:getPlayerContribution()
	return self.m_playerContribution;
end

function UserDataMgr:setPlayerDecomposeCoin(decomposeCoin)
	self.m_playerDecomposeCoin = decomposeCoin;
end

function UserDataMgr:getPlayerDecomposeCoin()
	return self.m_playerDecomposeCoin;
end

function UserDataMgr:setPlayerRankInfo(famous)
	for i = 1, #self.m_rankExpTable do
		if famous >= self.m_rankExpTable[i].exp and famous < self.m_rankExpTable[i+1].exp then
			self.m_curRankInfo = {};			
			self.m_curRankInfo.level = self.m_rankExpTable[i].level;
			self.m_curRankInfo.name = self.m_rankExpTable[i].name;		
			self.m_curRankInfo.iconID = self.m_rankExpTable[i].id_icon;	
			self.m_curRankInfo.curExp = famous - self.m_rankExpTable[i].exp;
			self.m_curRankInfo.levelUpExp = self.m_rankExpTable[i+1].exp - self.m_rankExpTable[i].exp;
			-- dump(self.m_curRankInfo);
			return;
		end
	end		
end

function UserDataMgr:getPlayerMoneyByItemID(itemID)
	print("itemID：", itemID, "~~~~", type(itemID));
	if itemID == 10001 then
		return self:getPlayerGoldCoin();
	elseif itemID == 10002 then
		return self:getPlayerDiamond();
	elseif itemID == 10003 then
		return self:getPlayerUnionCoin();
	elseif itemID == 10007 then
		return self:getFriendshipPoint();
	elseif itemID == 10008 then
		return self:getPlayerDecomposeCoin();
	else
		return 0;
	end
end

-- 军衔信息
-- 声望是1222时，计算结果如下：
-- level       = 2
-- name        = "中士"
-- iconID      = "rank02"
-- curExp = 1222 - 400 = 822
-- levelUpExp = 1600 - 400 = 1200 --该值是不可超过，一旦达到将跳到下一级

function UserDataMgr:getPlayerRankInfo()
	return self.m_curRankInfo;
end

--获得军衔经验
function UserDataMgr:getNextRankNeedExp()
	return self.m_curRankInfo.levelUpExp;
end

--根据声望得到当前声望信息，等级，名称等
function UserDataMgr:getRankInfoByFamous(playerFamous)
	for i = 1, #self.m_rankExpTable do
		if playerFamous >= self.m_rankExpTable[i].exp and playerFamous < self.m_rankExpTable[i+1].exp then
			local rankInfo = {};			
			rankInfo.level = self.m_rankExpTable[i].level;
			rankInfo.name = self.m_rankExpTable[i].name;
			rankInfo.iconID = self.m_rankExpTable[i].id_icon;
			rankInfo.curExp = playerFamous - self.m_rankExpTable[i].exp;
			rankInfo.levelUpExp = self.m_rankExpTable[i+1].exp - self.m_rankExpTable[i].exp;			

			return rankInfo;
		end
	end		
end

--获得军衔图标ID
function UserDataMgr:getRankIconIDByFamous(playerFamous)
	return self:getRankInfoByFamous(playerFamous).iconID;
end

--获得军衔名称
function UserDataMgr:getRankNameByFamous(playerFamous)
	return self:getRankInfoByFamous(playerFamous).name;
end

-- -- 星域系数(计算属性)
-- function UserDataMgr:getDomainRatio()
-- 	local domainRatio = 1; -- 星域系数初始
-- 	local domain = 0; --星域
-- 	if self.m_playerLevel > 0 then   -- 第一星域
-- 		domain = 1;
-- 		domainRatio = 1;
-- 		if self.m_playerLevel > 20 then    -- 第二星域
-- 			domain = 2;
-- 			domainRatio = 1.25;
-- 			if self.m_playerLevel > 40 then    -- 第三星域
-- 				domain = 3;
-- 				domainRatio = 1.5 ;
-- 				if self.m_playerLevel > 60 then   --第四星域
-- 					domain = 4;
-- 					domainRatio = 1.75;
-- 					if self.m_playerLevel > 80 then    --第五星域
-- 						domain = 5;
-- 						domainRatio = 2;
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return domainRatio;
-- end

function UserDataMgr:setPVPState(isPVP)
	self.m_isPVP = isPVP;
end

function UserDataMgr:isPVP()
	return self.m_isPVP;
end

function UserDataMgr:setStateExploring(isState)
	self.m_isExploring = isState;
end

function UserDataMgr:isExploring()
	if self.m_isExploring then
		return self.m_isExploring;
	end
	return false;
end

--隐身状态
-- function UserDataMgr:setLeftTimePlayerInvisible(leftTime)
-- 	self.m_serverLeftTimePlayerInvisible = leftTime;
-- 	self.m_clientTimePlayerInvisible = os.time();
-- end

-- function UserDataMgr:getLeftTimePlayerInvisible()
-- 	local pastTime = os.time() - self.m_clientTimePlayerInvisible;
-- 	if self.m_serverLeftTimePlayerInvisible > pastTime then
-- 		return self.m_serverLeftTimePlayerInvisible - pastTime;
-- 	else
-- 		return 0;
-- 	end
-- end

--漂浮物获得加成
function UserDataMgr:setLeftTimeDoubleFloater(leftTime)
	self.m_serverLeftTimeDoubleFloater = leftTime;
	self.m_clientTimeDoubleFloater = os.time();
end

function UserDataMgr:getLeftTimeDoubleFloater()
	local pastTime = os.time() - self.m_clientTimeDoubleFloater;
	if self.m_serverLeftTimeDoubleFloater > pastTime then
		return self.m_serverLeftTimeDoubleFloater - pastTime;
	else
		return 0;
	end
end

--友情值获得加成
function UserDataMgr:setLeftTimeDoubleFriendship(leftTime)
	self.m_serverLeftTimeDoubleFriendship = leftTime;
	self.m_clientTimeDoubleFriendship = os.time();
end

function UserDataMgr:getLeftTimeDoubleFriendship()
	local pastTime = os.time() - self.m_clientTimeDoubleFriendship;
	if self.m_serverLeftTimeDoubleFriendship > pastTime then
		return self.m_serverLeftTimeDoubleFriendship - pastTime;
	else
		return 0;
	end
end

--状态数量，当前只有三种状态
function UserDataMgr:getPlayerStateCount()
	local stateCount = 0;

	-- if UserDataMgr:getLeftTimePlayerInvisible() > 0 then
	-- 	stateCount = stateCount + 1;
	-- end
	if UserDataMgr:getLeftTimeDoubleFloater() > 0 then
		stateCount = stateCount + 1;
	end
	if UserDataMgr:getLeftTimeDoubleFriendship() > 0 then
		stateCount = stateCount + 1;
	end
	return stateCount;
end

function UserDataMgr:setRankAwardGet(isRankAwardGet)
	self.m_isRankAwardGet = isRankAwardGet;
end

function UserDataMgr:isRankAwardGet()
	return self.m_isRankAwardGet;
end


function UserDataMgr:setApplyLeagueAid(applyLeagueAid)
	if UserDataMgr:isApplyLeagueAid() == false then
		table.insert(self.m_applyLeagueAid, applyLeagueAid);
	end
end

function UserDataMgr:isApplyLeagueAid(applyLeagueAid)
	for k,v in pairs(self.m_applyLeagueAid) do
		if v == applyLeagueAid then
			return true;
		end
	end
	return false;
end

function UserDataMgr:setLeagueBuildTotalLevel(leagueBuildTotalLevel)
	self.m_leagueBuildTotalLevel = leagueBuildTotalLevel;
end

function UserDataMgr:isLeagueBuildTotalLevel()
	return self.m_leagueBuildTotalLevel;
end

function UserDataMgr:setLeagueChairman(isLeagueChairman)
	self.m_isLeagueChairman = isLeagueChairman;
end
function UserDataMgr:isLeagueChairman()
	return self.m_isLeagueChairman;
end
function UserDataMgr:setLeagueSubChairman(isLeagueSubChairman)
	self.m_isLeagueSubChairman = isLeagueSubChairman;
end
function UserDataMgr:isLeagueSubChairman()
	return self.m_isLeagueSubChairman;
end

function UserDataMgr:getLeagueBuildLevel()
	return self.m_leagueBuildLevel;
end

function UserDataMgr:getLeagueBadges()
	return self.m_leagueBadges;
end

function UserDataMgr:setLeagueBuild(index, isLeagueBuild)
	self.m_isLeagueBuild[index] = isLeagueBuild;
end
function UserDataMgr:isLeagueLeagueBuild(index)
	if index == nil then
		return self.m_isLeagueBuild;
	end
	return self.m_isLeagueBuild[index];
end

function UserDataMgr:setLeagueMoney(money)
	self.m_leagueMoney = money;
end
function UserDataMgr:getLeagueMoney()
	return self.m_leagueMoney;
end

return UserDataMgr