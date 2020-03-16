Tips = require("app.views.common.Tips")
-----------------
-- 商店场景
-----------------
local ShopScene = class("ShopScene", require("app.scenes.GameSceneBase"))

function ShopScene:init()
	self:initView("shopView.ShopView")
end

-- 请求购买物品
function ShopScene:requestToBuy(data)
	Network:request("game.shopHandler.buyItem", {table_id = data.product_id, count = data.count}, function (rc, receivedData)
		dump(receivedData);
			if receivedData.code ~= 1 then
				Tips:create(GameData:get("code_map", receivedData.code)["desc"])
				return
			end
			-- local itemData = ItemDataMgr:getItemBaseInfo(receivedData.items[1].item_id)
			Tips:create(string.format("成功购买%s个 %s !", data.count, data.name)) -- receivedData.items[1].count, itemData.name, itemData.level_desc
	end)
end

return ShopScene