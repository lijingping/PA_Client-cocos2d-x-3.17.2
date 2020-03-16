local LotteryScene = class("LotteryScene", require("app.scenes.GameSceneBase"))

function LotteryScene:init()
	print("LotteryScene:init")
	self:initView("lotteryView.LotteryView");
end

return LotteryScene