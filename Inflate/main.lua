require 'vector2'
require 'level'
require 'tile'
require 'bullet'
require 'spinner'
require 'digger'
require 'speedup'
require 'burstup'
require 'color'
require 'button'
require 'menu'
require 'deathscreen'
require 'tutorial'

function love.load()
	love.keyboard.setKeyRepeat( true )

	fpsfile = io.open( "FPS.txt" , "w" )
	SetOptions()

	XScreen = love.graphics.getWidth()
	YScreen = love.graphics.getHeight()
	XCenter = XScreen / 2
	YCenter = YScreen / 2
	StandardScreenWidth = 1000
	StandardScreenHeight = 650
	ScreenSizeRatio = ( XScreen / StandardScreenWidth + YScreen / StandardScreenHeight ) / 2

	BackgroundColorReduction = 0.5
	BackgroundColor = Color:new( 70 , 90 , 130 , 255 )
	love.graphics.setBackgroundColor( BackgroundColor:GetRGBA() )

	BulletImg = love.graphics.newImage( "/images/Bullet.png" )
	SpeedUpImg = love.graphics.newImage( "/images/SpeedUp.png" )
	BurstUpImg = love.graphics.newImage( "/images/BurstPower.png" )

	SmallFont = love.graphics.newFont( "/fonts/neuropolitical.ttf" , 26 * ScreenSizeRatio )
	LargeFont = love.graphics.newFont( "/fonts/neuropolitical.ttf" , 64 * ScreenSizeRatio )

	MusicVolume = 5

	LastCheckedMusic = 0
	SampleCheckRate = 256
	BackgroundMusicData = love.sound.newSoundData( "/sounds/TechnoBackground.wav" )
	BackgroundMusic = love.audio.newSource( "/sounds/TechnoBackground.wav" , "stream" )
	BackgroundMusic:setLooping( true )
	BackgroundMusic:play()
	SoundEnergy = 0
	SoundEnergy = GetSoundEnergy()

	CalculateAverageMusicEnergy()

	ButtonColor = Color:new( 120 , 160 , 220 , 150 )
	ButtonHighlightColor = Color:new( 255 , 255 , 255 , 180 )
	White = Color:new( 255 , 255 , 255 , 255 )
	Black = Color:new( 0 , 0 , 0 , 255 )
	Transparent = Color:new( 0 , 0 , 0 , 0 )

	local LineCounter = 0
	LevelData = {}
	for line in io.lines( "leveldata.data" ) do
		LineCounter = LineCounter + 1
		LevelData[ LineCounter ] = {}
		NumCounter = 0
		for num in line:gmatch( "%w+" ) do
			NumCounter = NumCounter + 1
			LevelData[ LineCounter ][ NumCounter ] = num
		end
	end

	BackgroundMusic:setVolume( 0.2 * MusicVolume )

	math.randomseed( os.time() )

	InitTables()

	CollisionMargin = 3
	MovementSpeed = 450 * ScreenSizeRatio
	PlayerBulletSpeed = 400
	PlayerDamage = 4 * ScreenSizeRatio
	MinTimeBetweenShots = 0.2
	PlayerBufferRadius = 150
	RoundNumber = 1
	RoundStartLength = 2
	PowerUpSpawnChance = 700
	
	OnMenu = true
	TutorialMode = false
	EndlessMode = false

	BaseSpawnChance = 600
	EndlessStartTime = os.time()
	EndlessTime = 0
	NextSpawnTime = os.time()
	MinSpawnTime = 500 		--ms
	MaxSpawnTime = 5000
	TimerUpdateInterval = 0.05
	LastTimerUpdate = os.clock()

	CurrentMenu = Menu:new()
end

function StartRound( roundno )
	love.graphics.setFont( SmallFont )
	OnMenu = false
	RoundNumber = roundno
	PlayerRadius = 15 * ScreenSizeRatio 
	PlayerMaxRadius = 40 * ScreenSizeRatio
	Dead = false

	InitTables()

	LastShotTime = os.clock()

	FirstLevel = Level:new( 25 , 25 , 50 * ScreenSizeRatio )
	CurrentLevel = FirstLevel

	if PowerUps then
		DeactivatePowerUps()
	end

	if roundno >= 1 then
		SpawnRoundObjects( roundno )
		RoundStart = true
		RoundStartTime = os.clock()
	elseif roundno == 0 then
		EndlessMode = true
		EndlessStartTime = os.clock()
		RoundStart = false
		NextSpawnTime = os.clock() + math.random( MinSpawnTime , MaxSpawnTime ) / 1000
	end
end

function love.update( dt )
	WriteToFPSFile( dt )

	SoundEnergy = GetSoundEnergy()

	local BackgroundColorChange = SoundEnergy / BackgroundColorReduction
	local r = BackgroundColorChange / 255 / 255
	local g = BackgroundColorChange / 255
	local b = BackgroundColorChange % 205
	love.graphics.setBackgroundColor( 70 + r , 70 + g , 140 + b , 255 )		

	if RoundStart == false and OnMenu == false and Dead == false then
		if TutorialMode == false then
			PlayerMovement( dt )
			PlayerShooting()
		end

		for _,bullet in ipairs( Bullets ) do
			if bullet.inPlay == true then
				bullet:update( dt )
			end
		end

		for _,enemy in ipairs( Enemies ) do
			if enemy.alive == true then
				enemy:update( dt )
			end
		end

		for _,PowerUp in ipairs( PowerUps ) do
			PowerUp:update( dt )
		end

		if TutorialMode == false and math.random( PowerUpSpawnChance ) == 1 then
			local PowerUpType = math.random( 1 , 2 )
			if PowerUpType == 1 then
				SpawnPowerUp( "SpeedUp" )
			elseif PowerUpType == 2 then
				SpawnPowerUp( "BurstUp" )
			end
		end

		if EndlessMode == true and Dead == false then
			if os.time() >= NextSpawnTime then
				SpawnRandomEnemy()
				NextSpawnTime = os.time() + math.random( MinSpawnTime , MaxSpawnTime ) / 1000
			end

			MaxSpawnTime = ( 20000 / ( os.clock() - EndlessStartTime ) + 40 ) + 500

			if os.clock() >= LastTimerUpdate + TimerUpdateInterval then
				EndlessTime = os.clock() - EndlessStartTime
				LastTimerUpdate = os.clock()
			end
		end

		if IsRoundDone() and RoundNumber > 0 and TutorialMode == false then
			StartRound( RoundNumber + 1 )
		end
	elseif RoundStart == true then
		if os.clock() >= RoundStartTime + RoundStartLength then
			RoundStart = false
		end	
	elseif OnMenu == true then
		CurrentMenu:update( dt )
	elseif Dead == true then
		LostScreen:update()
	end
	
	if TutorialMode == true and Dead == false then
		CurrentTutorial:update( dt )
	end

	if SoundEnergy > ( AverageMusicEnergy * MusicVolume * 0.2 ) * 3 and OnMenu == false then
		CurrentLevel:ChangeTileColors()
	end
end

function love.draw()
	if OnMenu == true then
		CurrentMenu:draw()
	elseif TutorialMode == true then
		CurrentTutorial:draw()
	else
		FirstLevel:draw( XCenter , YCenter )
		DrawItems()
		DrawPlayer()

		if EndlessMode == true then
			love.graphics.setColor( 255 , 255 , 255 , 255 )
			love.graphics.setFont( SmallFont )
			love.graphics.printf( RoundNum( EndlessTime , 2 ) , 0 , 0 , XScreen , "center" )
		end

		if RoundStart == true and EndlessMode == false then
			love.graphics.setColor( 255 , 255 , 255 , 255 )
			love.graphics.setFont( SmallFont )
			love.graphics.printf( "Round " .. RoundNumber , 0 , YCenter - 100 , XScreen , "center" )

			local x = 0
			local y = 2 * FirstLevel.SquareSize
			local sx = 3 * FirstLevel.SquareSize
			local sy = 3 * FirstLevel.SquareSize
			local buffer = 20
			local iconradius = 15 * ScreenSizeRatio
			local gap = 40

			love.graphics.setColor( 0 , 0 , 0 , 150 )
			love.graphics.rectangle( "fill" , x , y , sx , sy )
		
			love.graphics.setColor( 50 , 255 , 50 , 200 )
			love.graphics.circle( "fill" , x + buffer + iconradius , y + buffer + iconradius , iconradius , 5 )
			love.graphics.setColor( 255 , 255 , 255 , 255 )
			love.graphics.print( LevelData[ RoundNumber ][ 1 ] , x + buffer + iconradius + ( 2 * iconradius ) + gap , y + buffer )

			love.graphics.setColor( 0 , 255 , 255 , 200 )
			love.graphics.circle( "fill" , x + buffer + iconradius , y + buffer + iconradius + ( 2 * iconradius ) + gap , iconradius , 3 )
			love.graphics.setColor( 255 , 255 , 255 , 255 )
			love.graphics.print( LevelData[ RoundNumber ][ 2 ] , x + buffer + iconradius + ( 2 * iconradius ) + gap , y + buffer + ( 2 * iconradius ) + gap )
		end 
	end

	if Dead == true then
		LostScreen:draw()
	end
end

function PlayerMovement( dt )
	if love.keyboard.isDown('w') and YCenter - PlayerRadius - ( MovementSpeed * dt ) > CurrentLevel.position.y  then
		CurrentLevel.position.y = CurrentLevel.position.y + ( MovementSpeed * dt )
	elseif love.keyboard.isDown('s') and YCenter + PlayerRadius + ( MovementSpeed * dt ) < CurrentLevel.position.y + CurrentLevel.ActualSize.y then
		CurrentLevel.position.y = CurrentLevel.position.y - ( MovementSpeed * dt )
	end

	if love.keyboard.isDown('a') and XCenter - PlayerRadius - ( MovementSpeed * dt ) > CurrentLevel.position.x then
		CurrentLevel.position.x = CurrentLevel.position.x + ( MovementSpeed * dt )
	elseif love.keyboard.isDown('d') and XCenter + PlayerRadius + ( MovementSpeed * dt ) < CurrentLevel.position.x + CurrentLevel.ActualSize.x then
		CurrentLevel.position.x = CurrentLevel.position.x - ( MovementSpeed * dt )
	end
end

function PlayerShooting()
	if love.mouse.isDown( 'l' ) and os.clock() - LastShotTime > MinTimeBetweenShots then
		local x , y = love.mouse.getPosition()
		local angle = GetAngleBetweenPoints( XCenter , YCenter , x , y )
		local ratio = XDifference / YDifference
		local bullet = Bullet:new( XCenter - CurrentLevel.position.x , YCenter - CurrentLevel.position.y , angle , ratio , 800 , PlayerDamage , true )
		table.insert( Bullets , bullet )
		LastShotTime = os.clock()
	end
end

function DrawPlayer()
	love.graphics.setColor( 255 , 20 , 20 , 255 )
	love.graphics.circle( "fill" , XCenter , YCenter , PlayerRadius , 20 )
	love.graphics.setColor( 255 , 20 , 20 , 100 )
	love.graphics.circle( "line" , XCenter , YCenter , PlayerMaxRadius , 30 )
end

function DrawItems()
	for _,bullet in ipairs( Bullets ) do
		if bullet.inPlay == true then
			bullet:draw()
		end
	end

	for _,enemy in ipairs( Enemies ) do
		if enemy.alive == true then
			enemy:draw()
		end
	end

	for _,PowerUp in ipairs( PowerUps ) do
		PowerUp:draw()
	end
end

function RecalculateScreenProportions()
	XScreen = love.graphics.getWidth()
	YScreen = love.graphics.getHeight()
	XCenter = XScreen / 2
	YCenter = YScreen / 2
	ScreenSizeRatio = ( XScreen / StandardScreenWidth + YScreen / StandardScreenHeight ) / 2

	PlayerDamage = 4 * ScreenSizeRatio
	PlayerRadius = 15 * ScreenSizeRatio 
	PlayerMaxRadius = 40 * ScreenSizeRatio
	MovementSpeed = 500 * ScreenSizeRatio

	SmallFont = love.graphics.newFont( "/fonts/neuropolitical.ttf" , 28 * ScreenSizeRatio )
	LargeFont = love.graphics.newFont( "/fonts/neuropolitical.ttf" , 64 * ScreenSizeRatio )

	CurrentMenu = Menu:new()
	CurrentMenu.Options = true
end

function love.mousepressed( x , y , button )
	if OnMenu == true and button == "l" then
		CurrentMenu:CheckButtonClicks( x , y )
	end
end

function GetAngleBetweenPoints( PX1 , PY1 , PX2 , PY2 )
	XDifference = PX2 - PX1
	YDifference = PY1 - PY2
	local angle = math.atan( XDifference / YDifference )

	if YDifference < 0 then
		angle = math.pi + angle
	elseif XDifference < 0 and YDifference > 0 then
		angle = ( 2 * math.pi ) + angle
	end
	return angle
end

function love.keypressed( key , isrepeat )
	if key == 'escape' then
		if OnMenu == true and CurrentMenu.Options == false then
			ExitGame()
		elseif OnMenu == true and CurrentMenu.Options == true then
			CurrentMenu.Options = false
			WriteOptions()
		elseif OnMenu == false and TutorialMode == false then
			OnMenu = true
			EndlessMode = false
			Dead = false
			RoundStart = false
			DeactivatePowerUps()
			InitTables()
		elseif TutorialMode == true then
			OnMenu = true
			Dead = false
			TutorialMode = false
			DeactivatePowerUps()
			InitTables()
		end
	end

	if key == ' ' and Dead == true then
		Dead = false
		StartRound( 1 )
	end

	if key == 'return' and OnMenu == true then
		CurrentMenu:UseSelectedButton()
	end

	if key == 'f4' then
		local screenshot = love.graphics.newScreenshot()
		screenshot:encode( os.time() .. '.png' )
	end
end

function ExitGame()
	fpsfile:close()
	love.event.quit()
end

function InitTables()
	Bullets = {}
	Enemies = {}
	PowerUps = {}
end

function DeactivatePowerUps()
	for _,PowerUp in ipairs( PowerUps ) do
		if PowerUp.NeedsReverting == true then
			PowerUp:RevertEffect()
		end
	end
end

function PlayerHitsEnemy()
	if PlayerRadius > 15 then
		PlayerRadius = PlayerRadius - 1
	end
end

function IsTooCloseToPlayer( x , y )
	if GetHypotenuse( x - XCenter , y - YCenter ) <= PlayerBufferRadius then
		return true
	end
	return false
end

function GetHypotenuse( o , a )
	return math.sqrt( math.pow( o , 2 ) + math.pow( a , 2 ) )
end

function GetRandomSpawnLocation( buffer )
	local x = XCenter
	local y = YCenter
	while IsTooCloseToPlayer( x , y ) do
		x = math.random( CurrentLevel.ActualSize.x - buffer ) + buffer / 2
		y = math.random( CurrentLevel.ActualSize.y - buffer ) + buffer / 2
	end
	return x , y
end

function SpawnEnemy( type , quantity )
	for counter = 1 , quantity do
		local x , y = GetRandomSpawnLocation( 50 )
		local enemy = _G[type]:new( x , y )
		table.insert( Enemies , enemy )
	end
end

function SpawnPowerUp( powertype )
	local x , y = GetRandomSpawnLocation( 50 )
	local img = powertype .. "Img"
	local PowerUp = _G[powertype]:new( x , y , _G[powertype .. "Img"] , 40)
	
	table.insert( PowerUps , PowerUp )
end

function SpawnRoundObjects( levelno )
	SpawnEnemy( "Spinner" , LevelData[ levelno ][ 1 ] )
	SpawnEnemy( "Digger" , LevelData[ levelno ][ 2 ] )
end

function SpawnRandomEnemy()
	local rand = math.random( 1 , 2 )
	if rand == 1 then
		SpawnEnemy( "Spinner" , 1 )
	elseif rand == 2 then
		SpawnEnemy( "Digger" , 1 )
	end
end

function IsRoundDone()
	for _,enemy in ipairs( Enemies ) do
		if enemy.alive == true then
			return false
		end
	end
	return true
end

function GetSoundEnergy()
	local CurrentSampleNum = BackgroundMusic:tell( "samples" ) 
	local InstantEnergy = 0

	if CurrentSampleNum - SampleCheckRate > LastCheckedMusic then 
		for sampleNo = CurrentSampleNum , CurrentSampleNum + SampleCheckRate do 
			InstantEnergy = InstantEnergy + BackgroundMusicData:getSample( sampleNo ) ^ 2
		end

		LastCheckedMusic = CurrentSampleNum 
		return InstantEnergy * MusicVolume * 0.2
	elseif LastCheckedMusic > CurrentSampleNum then
		LastCheckedMusic = 0
	end
	return SoundEnergy
end

function CalculateAverageMusicEnergy()
	AverageMusicEnergy = 0
	for SampleCount = 1 , BackgroundMusicData:getSampleCount() do
		AverageMusicEnergy = AverageMusicEnergy + BackgroundMusicData:getSample( SampleCount ) ^ 2
	end
	AverageMusicEnergy = AverageMusicEnergy * SampleCheckRate / BackgroundMusicData:getSampleCount()
end

function RoundNum( num , dp )
	local mult = 10 ^ dp
	return math.floor( num * mult + 0.5 ) / mult
end

function WriteToFPSFile( dt )
	fpsfile:write( 1 / dt .. "\n" )
end

function SetOptions()
	optionsfile = io.open( "conf.options" , "r" )
	MusicVolume = optionsfile:read( "*n" )
	FSAA = optionsfile:read( "*n" )
	optionsfile:read( "*l" )
	Fullscreen = StringToBoolean( optionsfile:read( "*l" ) )
	Borderless = StringToBoolean( optionsfile:read( "*l" ) )
	local x = optionsfile:read( "*n" )
	local y = optionsfile:read( "*n" )
	optionsfile:close()

	if Fullscreen == true then
		CurrentScreenType = "Fullscreen"
	elseif Fullscreen == false and Borderless == true then
		CurrentScreenType = "Fullscreen Borderless"
	elseif Fullscreen == false and Borderless == false then
		CurrentScreenType = "Windowed"
	else
		CurrentScreenType = "Custom"
	end

	SetScreenSettings( x , y )
end

function WriteOptions()
	optionsfile = io.open( "conf.options" , "w" )
	optionsfile:write( MusicVolume .. "\n" )
	optionsfile:write( FSAA .. "\n" )
	optionsfile:write( tostring( Fullscreen ) )
	optionsfile:write( "\n" )
	optionsfile:write( tostring( Borderless ) )
	optionsfile:write( "\n" )
	optionsfile:write( XScreen .. "\n" )
	optionsfile:write( YScreen )
	optionsfile:close()
end

function SetScreenSettings( x , y )
	love.window.setMode( x , y , { fullscreen=Fullscreen , borderless=Borderless , fsaa=FSAA } )
end

function StringToBoolean( string )
	if string == "true" or string == "True" then return true
	elseif string == "false" or string == "False" then return false
	else return string
	end
end
