------------------------
-------军衔等级图标-------
------------------------
local RankIcon = class("RankIcon", cc.Node)

local rankImgPath = "res/rankIcon/";

function RankIcon:getRankIcon(playerFamous)
	--print("军衔等级：",playerFamous)

	return cc.Sprite:create(rankImgPath .. "icon_rank_" .. UserDataMgr:getRankInfoByFamous(playerFamous).level .. ".png");
end

function RankIcon:getZoomRankIcon(playerFamous, scale)
	local sprite = cc.Sprite:create(rankImgPath .. "icon_rank_" .. UserDataMgr:getRankInfoByFamous(playerFamous).level .. ".png");
	sprite:setScale(scale);
	return sprite;
end

function RankIcon:getZoomRankIconLabel(playerFamous, scale)
	local labelSprite = cc.Sprite:create(rankImgPath .. "text_rank_" .. UserDataMgr:getRankInfoByFamous(playerFamous).level .. ".png");
	labelSprite:setScale(scale);
	return labelSprite;
end


return RankIcon