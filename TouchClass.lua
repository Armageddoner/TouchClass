--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Touch = {}
Touch.__index = Touch

local Cleanup = require(ReplicatedStorage.SharedModules.Trove)

local RATE = 0.1 -- how often hitboxes should be parsed

type TouchMethod = "Box" | "Radius"
export type TouchInfo = {
	Size: Vector3,
	CFrame: CFrame,
	Method: TouchMethod,
	Radius: number?
} | Part

--[[
	An abstraction of <code>workspace:GetPartsInRadius()</code>
	Creates a new persistent hitbox at a particular CFrame via <code>TouchInfo</code>.
	
	Takes in <code>TouchInfo</code>, <code>OverlapParams</code>, and a callback function
]]
function Touch.new(Info: TouchInfo, Parameters: OverlapParams, Callback: (PartThatTouched: BasePart) -> ()?)
	if not Info then error("No TouchInfo provided!") end
	local self = {}
	if typeof(Info) == "Instance" and Info:IsA("Part") then
		self.Size = Info.Size
		self.CFrame = Info.CFrame
		self.Method = "Box"
	else
		self.Size = Info.Size
		self.CFrame = Info.CFrame
		self.Method = Info.Method
		self.Radius = Info.Radius
	end
	self.Callback = Callback
	self.Cleaner = Cleanup.new()
	local STEP = 0

	self.Cleaner:Connect(RunService.Heartbeat, function(DeltaTime)
		
		STEP += DeltaTime
		
		if STEP < RATE then
			return
		end
		
		STEP = 0
		
		local BoundParts = nil 
		if self.Method == "Box" then
			BoundParts = workspace:GetPartBoundsInBox(
				self.CFrame,
				self.Size,
				Parameters
			)
		elseif self.Method == "Radius" then
			BoundParts = workspace:GetPartBoundsInRadius(self.CFrame.Position, self.Radius, Parameters)
		end
		for _, Part: BasePart in BoundParts do
			if self.Callback and typeof(self.Callback) == "function" then
				self.Callback(Part)
			end
		end
	end)
	return setmetatable(self, Touch)
end

-- Destroys the <code>Touch</code>.
function Touch:Destroy()
	self.Cleaner:Clean()
end

return Touch