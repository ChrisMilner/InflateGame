function love.conf(t)
	t.title = "Inflate"
	t.author = "Chris Milner"

	t.indentity = "Inflate"
	t.console = true
	t.version = "0.9.0"

	t.window.width = 0 
	t.window.height = 0 
	t.window.fullscreen = false
	t.window.fullscreentype = "normal"
	t.window.borderless = true
	t.window.fsaa = 0

	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.thread = true
	t.modules.physics = true
	t.modules.math = true
end
