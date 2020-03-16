local ResourceMgr = require("app.utils.ResourceMgr");

local CAerolite = class("CAerolite", cc.Node)

function CAerolite:ctor(playDomainNum)
	self:setPosition(display.center);
	if playDomainNum > 2 then
		playDomainNum = 2;
	end

	local armatureName = "scene" .. playDomainNum .. "_part2";

	self.m_animation = ResourceMgr:getAnimArmatureByNameOnMain(armatureName);		
	math.randomseed(os.clock());
	local index = math.random(1, 3);

	self.m_animation:getAnimation():play("anim0" .. index);
	self:add(self.m_animation);

	self.m_animation:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
		--self:animationEvent(armatureBack, movementType, movementID);
		if movementType == ccs.MovementEventType.complete then
			local index = math.random(1, 3);

			self.m_animation:getAnimation():play("anim0" .. index);	
		end	
	end)
end


return CAerolite