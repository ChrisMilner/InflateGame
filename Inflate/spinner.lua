class = require 'middleclass'

Spinner = class("Spinner")

function Spinner:initialize( x , y )
	self.position = Vector2:new( x , y )
	self.radius = 15 * ScreenSizeRatio
	self.MaxRadius = 30 * ScreenSizeRatio
	self.angle = 0 
	self.ratio = math.tan( self.angle )
	self.LastShotTime = os.clock()
	self.alive = true
	self.TimeBetweenShots = 0.5
	self.damage = 2 * ScreenSizeRatio
end

function Spinner:draw()
	love.graphics.setColor( 50 , 255 , 50 , 255 )
	love.graphics.push()
	love.graphics.translate(self.position.x + CurrentLevel.position.x , self.position.y + CurrentLevel.position.y )
	love.graphics.rotate( self.angle )
	love.graphics.circle( "fill" , 0 , 0 , self.radius , 5 )
	love.graphics.setColor( 50 , 255 , 50 , 100 )
	love.graphics.circle( "line" , 0 , 0 , self.MaxRadius , 5)
	love.graphics.pop()
end

function Spinner:update( dt )
	self.angle = self.angle + 0.01
	if os.clock() - self.LastShotTime > self.TimeBetweenShots then
		for BulletCount = 0,7 do
			local bullet = Bullet:new( self.position.x , self.position.y , (self.angle + ( BulletCount * ( math.pi / 4 ) )) % ( 2 * math.pi )  , math.tan( self. angle + ( BulletCount * ( math.pi / 4 ) ) ) , 400 , self.damage , false )
			table.insert( Bullets , bullet )
		end
		self.LastShotTime = os.clock()
	end

	for _,bullet in ipairs( Bullets ) do
		if bullet.inPlay == true and bullet.friendly == true then
			if self:CheckForBulletCollision( bullet.position.x , bullet.position.y ) then
				self.radius = self.radius + bullet.damage
				PlayerHitsEnemy()
				bullet.inPlay = false
				if self.radius >= self.MaxRadius then
					self.alive = false
				end
			end
		end
	end
end

function Spinner:CheckForBulletCollision( x , y )
	if math.sqrt( math.pow( x - self.position.x , 2 ) + math.pow( y - self.position.y , 2 ) ) < self.radius then
		return true
	end
	return false
end
