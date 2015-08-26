class = require 'middleclass'

Tutorial = class( 'Tutorial' )

function Tutorial:initialize()
	TutorialMode = true
	OnMenu = false
	PlayerRadius = 15 * ScreenSizeRatio 
	PlayerMaxRadius = 40 * ScreenSizeRatio
	Dead = false
	RoundStart = false
	LastShotTime = os.clock()

	if PowerUps then
		DeactivatePowerUps()
	end
	InitTables()

	self.Stage = 1
	self.StageStartTime = os.clock()
	self.TextPosition = Vector2:new( 0 , YScreen / 20 )

	self.Stage1MinTime = 3
	self.WPress = false
	self.APress = false
	self.SPress = false
	self.DPress = false

	self.Stage2MinTime = 3
	self.ShootingUsed = false

	self.Stage3MinTime = 5
	self.Stage3LastShotTime = os.clock()
	self.Stage3TimeBetweenShots = 1.5

	self.Stage5MinTime = 10

	TutorialLevel = Level:new( 25 , 20 , 50 * ScreenSizeRatio )
	CurrentLevel = TutorialLevel
end

function Tutorial:update( dt )
	if self.Stage ~= 3 then
		PlayerMovement( dt )
		PlayerShooting()
	end

	if self.Stage == 1 then
		self:CheckMovementUse()
		if self.WPress and self.APress and self.SPress and self.DPress and os.clock() >= self.StageStartTime + self.Stage1MinTime then
			self.Stage = 2
			self.StageStartTime = os.clock()
		end
	elseif self.Stage == 2 then
		self:CheckShottingUse()
		if self.ShootingUsed and os.clock() >= self.StageStartTime + self.Stage2MinTime then
			self.Stage = 3
			self.StageStartTime = os.clock()

			self.Stage3Angle = math.pi - math.asin( ( XCenter - ( 100 + CurrentLevel.position.x ) ) / GetHypotenuse( 100 + CurrentLevel.position.x - XCenter , 100 + CurrentLevel.position.y - YCenter ) )
			self:FireShotAtPlayer()
		end
	elseif self.Stage == 3 then
		if os.clock() >= self.Stage3LastShotTime + self.Stage3TimeBetweenShots then
			self:FireShotAtPlayer()
			self.Stage3LastShotTime = os.clock()
		end

		if os.clock() >= self.StageStartTime + self.Stage3MinTime then
			self.Stage = 4 
			SpawnEnemy( "Spinner" , 1 )
		end
	elseif self.Stage == 4 and IsRoundDone() then
		self.Stage = 5
		self.StageStartTime = os.clock()
		SpawnPowerUp( "SpeedUp" )
		SpawnPowerUp( "BurstUp" )
	elseif self.Stage == 5 and os.clock() >= self.StageStartTime + self.Stage5MinTime then
		self.Stage = 6
	end
end

function Tutorial:draw()
	TutorialLevel:draw( XCenter , YCenter )
	DrawPlayer()
	DrawItems()

	love.graphics.setFont( SmallFont )
	love.graphics.setColor( White:GetRGBA() )
	if self.Stage == 1 then
		love.graphics.printf( "Use W , A , S , D to move around" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
	elseif self.Stage == 2 then
		love.graphics.printf( "Use the Left Mouse Button to shoot" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
	elseif self.Stage == 3 then
		love.graphics.printf( "When you are hit you increase in size" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
		love.graphics.printf( "If you reach the size of the outer circle you lose" , self.TextPosition.x , self.TextPosition.y + 50 , XScreen , "center" )
	elseif self.Stage == 4 then
		love.graphics.printf( "When an enemy is hit it increases in size" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
		love.graphics.printf( "Kill the enemy" , self.TextPosition.x , self.TextPosition.y + 50 , XScreen , "center" )
	elseif self.Stage == 5 then
		love.graphics.printf( "Power Ups give you temporary boosts" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
		love.graphics.printf( "Walk over the Power Ups to activate them" , self.TextPosition.x , self.TextPosition.y + 50 , XScreen , "center" )
	elseif self.Stage == 6 then
		love.graphics.printf( "Congratulations!" , self.TextPosition.x , self.TextPosition.y , XScreen , "center" )
		love.graphics.printf( "You've completed the tutorial" , self.TextPosition.x , self.TextPosition.y + 50 , XScreen , "center" )
		love.graphics.printf( "Press [escape] to return to the menu" , self.TextPosition.x , YCenter + YScreen / 4 , XScreen , "center" )
	end
end

function Tutorial:CheckMovementUse()
	if love.keyboard.isDown( 'w' ) then	self.WPress = true
	elseif love.keyboard.isDown( 'a' ) then self.APress = true
	elseif love.keyboard.isDown( 's' ) then self.SPress = true
	elseif love.keyboard.isDown( 'd' ) then self.DPress = true
	end
end

function Tutorial:CheckShottingUse()
	if love.mouse.isDown( "l" ) then self.ShootingUsed = true end
end

function Tutorial:FireShotAtPlayer()
	local bullet = Bullet:new( 100 , 100 , self.Stage3Angle , math.tan( self.Stage3Angle ) , 600 , 2 * ScreenSizeRatio , false )
	table.insert( Bullets , bullet )
end
