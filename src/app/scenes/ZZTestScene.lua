local ZZTestScene = class("ZZTestScene", require("app.scenes.GameSceneBase"))

function ZZTestScene:init()
	print("  ZZTestScene : init() ");
	self.m_testScrow = self:initView("loginView.testScrow");
end

function ZZTestScene:setArmsCount(playerCount,enemyCount)
	self.m_testScrow:setArmsCount(playerCount,enemyCount);
end

return ZZTestScene;