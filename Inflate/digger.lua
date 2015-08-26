class = require 'middleclass'

Digger = class('Digger')

WAIT = 1
BURST = 2
MOVE = 3

function Digger:initialize( x , y )
	self.position = Vector2:new( x , y )
	self.radius = 10 * ScreenSizeRatio
	self.MaxRadius = 18 * ScreenSizeRatio
	self.angle = - math.pi / 2
	self.alive = true
	self.damage = 3 * ScreenSizeRatio
	self.mode = WAIT

	self.BurstCount = 0
	self.BurstCountMax = 4
	self.LastShotTime = os.clock()
	self.TimeBetweenShots = 0.1
	self.ShotSpread = 150
	self.ShotSpeed = 700

	self.MoveTo = Vector2:new( 0 , 0 )
	self.move = Vector2:new( 0 , 0 )
	self.MoveSpeed = 200
	self.MoveRatio = 0
	self.MoveAngle = 0
	self.MoveTime = 0
	self.MoveStartTime = os.clock()

	self.StartWaitTime = os.clock()
	self.WaitTime = 3
end

function Digger:draw()
	local SecondColor = nil
	if self.mode == MOVE then
		love.graphics.setColor( 20 , 120 , 100 , 255 )
		SecondColor = Color:new( 20 , 120 , 100 , 100 )
	else
		love.graphics.setColor( 0 , 255 , 255 , 255 )
		SecondColor = Color:new( 0 , 255 , 255 , 100 )
	end
	love.graphics.push()
	love.graphics.translate( self.position.x + FirstLevel.position.x , self.position.y + FirstLevel.position.y )
	love.graphics.rotate( self.angle )
	love.graphics.circle( "fill" , 0 , 0 , self.radius , 3 )
	love.graphics.setColor( SecondColor:GetRGBA() )
	love.graphics.circle( "line" , 0 , 0 , self.MaxRadius , 3 )
	love.graphics.pop()
end

function Digger:update( dt )
	if self.mode == BURST or self.mode == WAIT then
		self.angle = math.asin( ( XCenter - ( self.position.x + FirstLevel.position.x ) ) / GetHypotenuse( self.position.x + FirstLevel.position.x - XCenter , self.position.y + FirstLevel.position.y - YCenter ) ) - ( math.pi / 2 )
		if (self.position.y + FirstLevel.position.y) - YCenter <= 0 then
			self.angle = - self.angle
		end
	end

	if self.mode == BURST and ( os.clock() - self.LastShotTime ) >= self.TimeBetweenShots then
		local FireAngle = self.angle + ( math.random(self.ShotSpread) - self.ShotSpread / 2 ) / 1000 + math.pi / 2
		local bullet = Bullet:new( self.position.x , self.position.y , FireAngle , math.tan( FireAngle ) , self.ShotSpeed , self.damage , false )
		table.insert( Bullets , bullet )
		self.BurstCount = self.BurstCount + 1
		if self.BurstCount >= self.BurstCountMax then
			self.mode = WAIT
			self.StartWaitTime = os.clock()
			self.WaitTime = 2
		end
		self.LastShotTime = os.clock()
	elseif self.mode == WAIT and os.clock() >= self.StartWaitTime + self.WaitTime then
		self.mode = MOVE

		self.MoveTo.x = XCenter
		self.MoveTo.y = YCenter
		while IsTooCloseToPlayer( self.MoveTo.x , self.MoveTo.y ) do
			self.MoveTo.x = math.random( FirstLevel.ActualSize.x )
			self.MoveTo.y = math.random( FirstLevel.ActualSize.y )
		end

		self.angle = math.asin( ( self.MoveTo.x - self.position.x ) / GetHypotenuse( self.position.x - self.MoveTo.x , self.position.y - self.MoveTo.y ) ) - ( math.pi / 2 )
		if self.MoveTo.y > self.position.y then
			self.angle = - self.angle
		end

		self.MoveAngle = self.angle + math.pi / 2
		self.MoveRatio = math.tan( self.MoveAngle )

		if self.MoveAngle == math.pi / 2 then
			self.move.y = 0
			self.move.x = self.MoveSpeed
		elseif self.MoveAngle == 3 * math.pi /2 then
			self.move.y = 0
			self.move.x = - self.MoveSpeed
		else
			self.move.y = self.MoveSpeed / math.sqrt( 1 + ( self.MoveRatio * self.MoveRatio ) )
			self.move.x = self.move.y  * self.MoveRatio
		
			if self.MoveAngle > math.pi / 2 and self.MoveAngle < math.pi * ( 3 / 2 ) then
				self.move.x = - self.move.x
				self.move.y = - self.move.y
			end
		end
		
		self.MoveTime = math.sqrt( math.pow( self.MoveTo.x - self.position.x , 2 ) + math.pow( self.MoveTo.y - self.position.y , 2 ) ) / self.MoveSpeed
		self.MoveStartTime = os.clock()
	elseif self.mode == MOVE then
		self.position.x = self.position.x + self.move.x * dt
		self.position.y = self.position.y - self.move.y * dt 

		if os.clock() >= self.MoveStartTime + self.MoveTime then
			self.mode = BURST
			self.BurstCount = 0
		end
	end

	for _,bullet in ipairs( Bullets ) do
		if bullet.inPlay == true and bullet.friendly == true and ( self.mode == BURST or self.mode == WAIT ) then
			if self:CheckForBulletCollision( bullet.position.x , bullet.position.y , bullet.size.x ) then
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

function Digger:CheckForBulletCollision( x , y , brad )
	if math.sqrt( math.pow( x - self.position.x , 2 ) + math.pow( y - self.position.y , 2 ) ) <= self.radius + brad then
		return true
	end
	return false
end
