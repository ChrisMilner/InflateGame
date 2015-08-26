class = require 'middleclass'

Bullet = class("Bullet")

function Bullet:initialize( x , y , ang , ratio , speed , dam , friendly )
	self.position = Vector2:new( x , y )
	self.size = Vector2:new( 15 * ( 1 + dam / 10 ) , 15 * ( 1 + dam / 10 ) )
	self.offset = Vector2:new( self.size.x / 2 , self.size.y / 2 )
	self.BulletSpeed = speed * ScreenSizeRatio
	self.angle = ang
	self.ratio = ratio
	self.damage = dam
	self.friendly = friendly
	self.inPlay = true

	self.XChange = 0 
	self.YChange = 0
	self.MotionBlurReduction = 1200
end

function Bullet:draw()
	love.graphics.setColor( 255 , 255 - ( ( self.damage / ScreenSizeRatio ) * 25 ) , 255 - ( ( self.damage / ScreenSizeRatio ) * 40 ) , 255 )
	love.graphics.push()
	love.graphics.translate( self.position.x + CurrentLevel.position.x , self.position.y + CurrentLevel.position.y )
	love.graphics.draw( BulletImg , 0 , 0 , self.angle , self.size.x / 15 , self.size.y / 15 + self.BulletSpeed / self.MotionBlurReduction , self.offset.x , self.offset.y )
	love.graphics.pop()
end

function Bullet:update( dt )
	if self.angle == math.pi / 2 then
		self.YChange = 0
		self.XChange = self.BulletSpeed
	elseif self.angle == 3 * math.pi /2 then
		self.YChange = 0
		self.XChange = - self.BulletSpeed
	else
		self.YChange = self.BulletSpeed / math.sqrt( 1 + ( self.ratio * self.ratio ) )
		self.XChange = self.YChange  * self.ratio

		if self.angle > math.pi / 2 and self.angle < math.pi * ( 3 / 2 ) then
			self.XChange = - self.XChange
			self.YChange = - self.YChange
		end
	end

	if not self:CheckCollisionWithWall( self.position.x + ( self.XChange * dt )  , self.position.y + ( self.YChange * dt ) ) then
		if not self:CheckCollisionWithPlayer( self.position.x + CurrentLevel.position.x , self.position.y + CurrentLevel.position.y ) then
			self.position.x = self.position.x + ( self.XChange * dt ) 
			self.position.y = self.position.y - ( self.YChange * dt )
		else
			self.inPlay = false
			PlayerRadius = PlayerRadius + self.damage
			if PlayerRadius >= PlayerMaxRadius then
				Dead = true
				LostScreen = DeathScreen:new()
			end
		end
	else
		self.inPlay = false
	end
end

function Bullet:CheckCollisionWithWall( x , y )
	if x - CollisionMargin < 0 or x + CollisionMargin > CurrentLevel.ActualSize.x or y - CollisionMargin < 0 or y + CollisionMargin > CurrentLevel.ActualSize.y then
		return true
	end
	return false
end

function Bullet:CheckCollisionWithPlayer( x , y )
	if x > XCenter - PlayerRadius and x < XCenter + PlayerRadius and y > YCenter - PlayerRadius and y < YCenter + PlayerRadius and not self.friendly then
		return true
	end
	return false
end
