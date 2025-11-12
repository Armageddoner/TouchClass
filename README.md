# TouchClass
A replacement for ROBLOX's default BasePart:Touched() event. Intended to be more stable and versatile.

# Class Framework
* Technology: Roblox
* Rationale: To create a better, more consistent way for the application of hit-detection-based mechanisms.

# Dependencies
* [Trove](https://github.com/Sleitnick/RbxUtil/tree/main/modules/trove)

# Structure

* `Touch.new()` :: Creates a new persistent hitbox at a particular CFrame via `TouchInfo` type. Takes in several parameters.
    * `Info: TouchInfo` - The `Part` or world data regarding how the hitbox should be formed
    * `Parameters: OverlapParams` - How the hitbox should act under certain [circumstances](https://create.roblox.com/docs/reference/engine/datatypes/OverlapParams).
    * `Callback: (PartThatTouched: BasePart) -> ()` - The callback function you provide to handle cases where an `Instance` gets detected.

 * `Touch:Destroy()` :: Destroys the `Touch`.

## Type Structure

`TouchInfo`
> Information regarding how the provided hitbox should be
* Size: `Vector3`
* CFrame: `CFrame`
* Method: `TouchMethod` -> `"Box" | "Radius"`
* Radius: `number?`

Alternatively, you can pass through a `Part` and `Touch.new()` will automatically use the part's size and CFrame to handle hit detection.

# Implementation
* Download the file with its dependency and drop the `.rbxm` files into your ROBLOX Studio explorer.
