class = require 'middleclass'

SpeedUp = class('SpeedUp')

function SpeedUp:initialize( x , y , img , radius )
	self.position = Vector2:new( x - ( 40 * 0.9 * ScreenSizeRatio ) , y - ( 40 * 0.9 * ScreenSizeRatio ) )
	self.image = img
	self.radius = radius
	self.CollectedTime = os.clock()
	self.collected = false
	self.duration = 10
	self.Used = false
	self.NeedsReverting = true 
end

function SpeedUp:draw()
	if self.collected == false then
		love.graphics.setColor( 255 , 255 , 255 )
		love.graphics.draw( self.image , self.position.x + CurrentLevel.position.x , self.position.y + CurrentLevel.position.y , 0 , ScreenSizeRatio * 0.9 , ScreenSizeRatio * 0.9 , self.radius / 2 , self.radius / 2 )
	else
		love.graphics.setColor( White:GetRGBA() )
		love.graphics.rectangle( "fill" , 0 , 0 , XScreen * ( 1 - ( ( os.clock() - self.CollectedTime ) / self.duration ) ) , 5 )
	end
end

function SpeedUp:update( dt )
	if GetHypotenuse( XCenter - ( self.position.x + CurrentLevel.position.x ) , YCenter - ( self.position.y + CurrentLevel.position.y ) ) <= self.radius + PlayerRadius and self.collected == false then
		self.CollectedTime = os.clock()
		self.collected = true
		MovementSpeed = 600
	end

	if self.collected == true and os.clock() >= self.CollectedTime + self.duration and self.Used == false then
		self:RevertEffect()
	end
end

function SpeedUp:RevertEffect()
	MovementSpeed = 450
	self.Used = true
end
