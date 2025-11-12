local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Touch = {}
Touch.__index = Touch

local Cleanup = require("./Trove") -- change to whereever you placed the cleanup

local RATE = 0.1 -- how often hitboxes should be parsed

type TouchMethod = "Box" | "Radius"
export type TouchInfo = {
	Size: Vector3,
	CFrame: CFrame,
	Method: TouchMethod,
	Radius: number?
} | BasePart

--[[
	An abstraction of <code>workspace:GetPartsInRadius()</code>
	Creates a new persistent hitbox at a particular CFrame via <code>TouchInfo</code>.
	
	Takes in <code>TouchInfo</code>, <code>OverlapParams</code>, and a callback function
]]
function Touch.new(Info: TouchInfo, Parameters: OverlapParams, Callback: (PartThatTouched: BasePart) -> ()?)
	if not Info then error("No TouchInfo provided!") end
	local self = setmetatable({}, Touch)
	self.Cleaner = Cleanup.new()
	self.Callback = Callback
	
	local Persistent = false
	
	if typeof(Info) == "Instance" and Info:IsA("BasePart") then
		self.Size = Info.Size
		self.CFrame = Info.CFrame
		self.Method = "Box"
		self.Cleaner:Connect(Info.Destroying, function()
			self:Destroy()
		end)
		Persistent = true
	else
		self.Size = Info.Size
		self.CFrame = Info.CFrame
		self.Method = Info.Method
		self.Radius = Info.Radius
	end
	local STEP = 0

	self.Cleaner:Connect(RunService.Heartbeat, function(DeltaTime)
		
		STEP += DeltaTime
		
		if STEP < RATE then
			return
		end
		
		STEP = 0
		
		if Persistent and Info then
			self.Size = Info.Size * 1.05 -- 5% larger to detect things at directly at an edge of the part.
			self.CFrame = Info.CFrame
		end
		
		local BoundParts: {BasePart} = nil 
		
		if self.Method == "Box" then
			BoundParts = workspace:GetPartBoundsInBox(
				self.CFrame,
				self.Size,
				Parameters
			)
		elseif self.Method == "Radius" then
			BoundParts = workspace:GetPartBoundsInRadius(self.CFrame.Position, self.Radius, Parameters)
		end
		
		if self.Callback and typeof(self.Callback) == "function" then
			for _, Part: BasePart in BoundParts do
				self.Callback(Part)
			end
		end
		
	end)
	return self
end

-- Destroys the <code>Touch</code>.
function Touch:Destroy()
	self.Cleaner:Clean()
	self.Radius = nil
	self.CFrame = nil
	self.Method = nil
	self.Size = nil
	self.Callback = nil
	self.Cleaner = nil
end

return Touch
