local DemoBattlePreScene = class("DemoBattlePreScene", require("app.scenes.GameSceneBase"))

function DemoBattlePreScene:init()
	self:initView("loginView.CCBDemoBattlePreView");
end

return DemoBattlePreScene;