class = require 'middleclass'

Menu = class('Menu')

function Menu:initialize()
	self.MainButtons = {}
	self.OptionButtons = {}
	
	self.BtnPosition = Vector2:new( XCenter - XScreen / 4 , YCenter - YScreen / 8 )
	self.BtnSize = Vector2:new(  XScreen / 2 ,  YScreen / 10 )
	self.TitlePosition = Vector2:new( XCenter - XScreen / 3 , YCenter - YScreen / 2.5 )
	
	self.SelectedButton = 4
	self.TimeBetweenButtonChange = 0.2
	self.LastButtonChangeTime = os.clock()
	self.ButtonsOnScreen = 5
	
	self.ScaleReduction = 300
	self.ColorReduction = 0.4
	self.TitleColor = SoundEnergy / self.ColorReduction
	self.TitleScale = SoundEnergy / self.ScaleReduction

	self.Options = false

	self.VolumeWidth = self.BtnSize.x / 36
	self.VolumeGap = self.BtnSize.x / 88
	self.VolumeBaseHeight = self.BtnSize.y / 4
	self.VolumeHeightChange = ( self.BtnSize.y - 10 - self.VolumeBaseHeight ) / 5

	self.VignetteData = love.image.newImageData( XScreen , YScreen )
	self.VignetteData:mapPixel( function( x , y , r , g , b , a )  
								local dist = GetHypotenuse( x - XCenter , y - YCenter )
								local radius = GetHypotenuse( XCenter , YCenter ) + 200
								a = ( dist / radius ) * 200
								return 0 , 0 , 0 , a
							end )
	self.Vignette = love.graphics.newImage( self.VignetteData )

	StartButton = Button:new( "START" , self.BtnPosition.x , self.BtnPosition.y , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , StartButtonFunction )
	table.insert( self.MainButtons , StartButton )
	EndlessButton = Button:new( "Endless Mode" , self.BtnPosition.x , self.BtnPosition.y + self.BtnSize.y , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , EndlessButtonFunction )
	table.insert( self.MainButtons , EndlessButton )
	TutorialButton = Button:new( "Tutorial" , self.BtnPosition.x , self.BtnPosition.y + 2 * self.BtnSize.y , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , TutorialButtonFunction )
	table.insert( self.MainButtons , TutorialButton )
	OptionsButton = Button:new( "Options" , self.BtnPosition.x , self.BtnPosition.y + 3 * self.BtnSize.y  , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , OptionsButtonFunction )
	table.insert( self.MainButtons , OptionsButton )
	ExitButton = Button:new( "Exit" , self.BtnPosition.x , self.BtnPosition.y + 4 * self.BtnSize.y  , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , ExitButtonFunction )
	table.insert( self.MainButtons , ExitButton )

	VolumeButton = Button:new( "Volume" , self.BtnPosition.x , self.BtnPosition.y , self.BtnSize.x / 2 , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , VolumeButtonFunction )
	table.insert( self.OptionButtons , VolumeButton )
	BackButton = Button:new( "<" , 0 , 0 , self.BtnSize.x / 2 , self.BtnSize.y , Transparent , ButtonHighlightColor , White , BackButtonFunction )
	table.insert( self.OptionButtons , BackButton )
	FSAAButton = Button:new( "Anti Aliasing : " .. FSAA , self.BtnPosition.x , self.BtnPosition.y + self.BtnSize.y , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , FSAAButtonFunction )
	table.insert( self.OptionButtons , FSAAButton )
	ScreenTypeButton = Button:new( CurrentScreenType , self.BtnPosition.x , self.BtnPosition.y + self.BtnSize.y * 2 , self.BtnSize.x , self.BtnSize.y , ButtonColor , ButtonHighlightColor , Black , ScreenTypeFunction )
	table.insert( self.OptionButtons , ScreenTypeButton )
end

function Menu:update( dt )
	if self.Options == false then
		for _,btn in ipairs( self.MainButtons ) do
			btn:update( dt )
		end
	else
		for _,btn in ipairs( self.OptionButtons ) do
			btn:update( dt )
		end
	end

	if os.clock() >= self.LastButtonChangeTime + self.TimeBetweenButtonChange then
		if love.keyboard.isDown( 'w' ) then 
			self.SelectedButton = ( self.SelectedButton - 1 ) % self.ButtonsOnScreen
			self:GetButtonFromNum( self.SelectedButton ):Select( true ) 
			self.LastButtonChangeTime = os.clock()
		end

		if love.keyboard.isDown( 's' ) then 
			self.SelectedButton = ( self.SelectedButton + 1 ) % self.ButtonsOnScreen
			self:GetButtonFromNum( self.SelectedButton ):Select( true )
			self.LastButtonChangeTime = os.clock()
		end
	end

	self.TitleColor = SoundEnergy / self.ColorReduction
	self.TitleScale = SoundEnergy / self.ScaleReduction
end

function Menu:draw()
	if self.Options == false then
		love.graphics.setColor( 255 - self.TitleColor , 255 - self.TitleColor , 255 , 255 )
		love.graphics.setFont( LargeFont )
		love.graphics.push()
		love.graphics.translate( XCenter , self.TitlePosition.y )
		love.graphics.scale( 1 + self.TitleScale )
		love.graphics.printf( "INFLATE" , - XCenter , 0 , XScreen , "center" )
		love.graphics.pop()
		
		for _,btn in ipairs( self.MainButtons ) do
			btn:draw()
		end
	else
		love.graphics.setColor( 255 - self.TitleColor , 255 - self.TitleColor , 255 , 255 )
		love.graphics.setFont( LargeFont )
		love.graphics.push()
		love.graphics.translate( XCenter , self.TitlePosition.y )
		love.graphics.scale( 1 + self.TitleScale )
		love.graphics.printf( "OPTIONS" , -XCenter , 0 , XScreen , "center" )
		love.graphics.pop()

		for _,btn in ipairs( self.OptionButtons ) do
			btn:draw()
		end

		for count = 1 , 5 do
			if count <= MusicVolume then
				love.graphics.setColor( 255 , 255 , 255 , 255 )
			else
				love.graphics.setColor( 100 , 100 , 100 , 255 )
			end
			love.graphics.rectangle( "fill" , self.BtnPosition.x + ( 5 * self.BtnSize.x ) / 8 + ( count * ( self.VolumeWidth + self.VolumeGap ) ) , self.BtnPosition.y + 5 + ( 6 - count - 1 ) * self.VolumeHeightChange , self.VolumeWidth , self.VolumeBaseHeight + count * self.VolumeHeightChange)
		end
	end
	love.graphics.setColor( 0 , 0 , 0 , 150 )
	love.graphics.draw( self.Vignette )
end

function Menu:CheckButtonClicks( x , y )
	if self.Options == false then
		for _,btn in ipairs( self.MainButtons ) do
			btn:CheckButtonClick( x , y )
		end
	else
		for _,btn in ipairs( self.OptionButtons ) do
			btn:CheckButtonClick( x , y )
		end
	end
end

function Menu:GetButtonFromNum( num )
	if self.Options == false then
		if num == 0 then return StartButton
		elseif num == 1 then return EndlessButton
		elseif num == 2 then return TutorialButton
		elseif num == 3 then return OptionsButton
		elseif num == 4 then return ExitButton 
		end
	else
		if num == 0 then return VolumeButton
		elseif num == 1 then return FSAAButton
		elseif num == 2 then return ScreenTypeButton
		elseif num == 3 then return BackButton
		end
	end
end

function Menu:GetScreenTypeNum()
	if CurrentScreenType == "Fullscreen" then return 0
	elseif CurrentScreenType == "Fullscreen Borderless" then return 1
	elseif CurrentScreenType == "Windowed" or CurrentScreenType == "Custom" then return 2
	end
end

function Menu:GetScreenTypeFromNum( num )
	if num == 0 then return "Fullscreen"
	elseif num == 1 then return "Fullscreen Borderless"
	elseif num == 2 then return "Windowed"
	end
end

function Menu:DeselectAllButtons()
	if self.Options == false then
		for _,btn in ipairs( self.MainButtons ) do
			btn:Deselect()
		end
	else
		for _,btn in ipairs( self.OptionButtons ) do
			btn:Deselect()
		end
	end
end

function Menu:UseSelectedButton()
	if self.Options == false then
		for _,btn in ipairs( self.MainButtons ) do
			if btn:IsSelected() then
				btn.effect()
			end
		end
	else
		for _,btn in ipairs( self.OptionButtons ) do
			if btn:IsSelected() then
				btn.effect()
			end
		end
	end
end

StartButtonFunction = function() StartRound( 1 ) end

EndlessButtonFunction = function() StartRound( 0 ) end

TutorialButtonFunction = function() CurrentTutorial = Tutorial:new() end

OptionsButtonFunction = function() 
							CurrentMenu.Options = true 
							CurrentMenu.SelectedButton = 3
							CurrentMenu.ButtonsOnScreen = 4
						end

ExitButtonFunction = function() ExitGame() end

VolumeButtonFunction = function() 
						MusicVolume = ( MusicVolume + 1 ) % 6 
						BackgroundMusic:setVolume( 0.2 * MusicVolume )
					 end

BackButtonFunction = function() 
						CurrentMenu.Options = false 
						CurrentMenu.ButtonsOnScreen = 5
						CurrentMenu.SelectedButton = 4
						WriteOptions()						
					end

FSAAButtonFunction = function()
						FSAA = ( ( ( FSAA / 4 ) + 1 ) % 3 ) * 4 
						love.window.setMode( XScreen , YScreen , { fsaa=FSAA , fullscreen=Fullscreen } )
						FSAAButton.text = "Anti Aliasing : " .. FSAA
					end

ScreenTypeFunction = function()
						CurrentScreenType = CurrentMenu:GetScreenTypeFromNum( ( CurrentMenu:GetScreenTypeNum() + 1 ) % 3 )
						ScreenTypeButton.text = CurrentScreenType

						local x , y = 0 , 0
						if CurrentScreenType == "Fullscreen" then
							Fullscreen = true 
							Borderless = false
						elseif CurrentScreenType == "Fullscreen Borderless" then
							Fullscreen = false
							Borderless = true
						elseif CurrentScreenType == "Windowed" then
							x = 800
							y = 600
							Fullscreen = false
							Borderless = false
						end

						SetScreenSettings( x , y )

						RecalculateScreenProportions()
					end
