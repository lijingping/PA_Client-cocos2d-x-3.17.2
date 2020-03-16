local SpriteBlur = class("SpriteBlur", cc.Node)

function SpriteBlur:ctor()
	self:setContentSize(display.size);
	self:setAnchorPoint(0.5, 0.5);
	self:addTo(App:getRunningScene(), display.Z_BLURLAYER);
	self:setPosition(display.cx, display.cy);


    local fileName = "res\\BlurScene.png"

    local function afterCaptured(succeed, outputFile)
	    if succeed then
	      	local sprite = cc.Sprite:create(fileName);
        	local properties = cc.Properties:createNonRefCounted("Materials/2d_effects.material#sample");
        	local material = cc.Material:createWithProperties(properties);
        	sprite:setGLProgramState(material:getTechniqueByName("blur"):getPassByIndex(0):getGLProgramState());
      		self:addChild(sprite, 0, 101);
      		sprite:setPosition(display.center);
	    else
	     	print("Capture BlurScene Failed.");
	    end
    end

 	cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName);
 	if self:getChildByTag(101) then
    	self:removeChildByTag(101);
    end
    cc.utils:captureScreen(afterCaptured, fileName);
end

return SpriteBlur