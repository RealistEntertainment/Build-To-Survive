local TestExtention = {}

function TestExtention.ShouldConstruct(Component)
    return Component.Instance:IsDescendantOf(workspace)
end

return TestExtention