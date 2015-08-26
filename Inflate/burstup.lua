class = require 'middleclass'

BurstUp = class('BurstUp')

function BurstUp:initialize( x , y , img , radius )
	self.position = Vector2:new( x , y )
	self.image = img
	self.radius = radius
	self.collected = false
	self.CollectedTime = os.clock()
	self.duration = 5

	self.angle = 0
	self.TimeBetweenShots = 0.05
	self.LastShotTime = os.clock()
	self.damage = 8
	self.ShotSpeed = 600
end

function BurstUp:draw()
	if self.collected == false then
		love.graphics.setColor( 255 , 255 , 255 )
		love.graphics.draw( self.image , self.position.x + CurrentLevel.position.x , self.position.y + CurrentLevel.position.y , 0 , ScreenSizeRatio * 0.9 , ScreenSizeRatio * 0.9 , self.radius / 2 , self.radius / 2 )
	else
		love.graphics.setColor( 255 , 255 , 100 )
		love.graphics.rectangle( "fill" , 0 , 5 , XScreen * ( 1 - ( ( os.clock() - self.CollectedTime ) / self.duration ) ) , 5 )
	end
end

function BurstUp:update( dt )
	if GetHypotenuse( XCenter - ( self.position.x + CurrentLevel.position.x ) , YCenter - ( self.position.y + CurrentLevel.position.y ) ) <= self.radius + PlayerRadius and self.collected == false then
		self.CollectedTime = os.clock()
		self.LastShotTime = os.clock()
		self.collected = true
	end

	if self.collected == true and os.clock() <= self.CollectedTime + self.duration then
		if os.clock() >= self.LastShotTime + self.TimeBetweenShots then
			local bullet = Bullet:new( XCenter - CurrentLevel.position.x , YCenter - CurrentLevel.position.y , self.angle , math.tan( self.angle ) , self.ShotSpeed , self.damage , true )
			table.insert( Bullets , bullet )

			self.angle = ( self.angle + math.pi / 4 ) % ( 2 * math.pi )
			self.LastShotTime = os.clock()
		end
	end
end
