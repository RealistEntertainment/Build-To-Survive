local config = require(script.Parent.config)

local util = {}

function util.CreateViewportFrame()
    local Viewport = Instance.new("ViewportFrame")

    Viewport.Size = config.Size

    return Viewport
end


return util