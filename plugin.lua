-- Information block for the plugin
--[[ #include "src/info.lua" ]]

-- Define the color of the plugin object in the design
function GetColor(props)
  return { 33,33,33 }
end

-- The name that will initially display when dragged into a design
function GetPrettyName(props)
  return string.format("OBS Websocket\n[%s]", PluginInfo.Version)
end

-- Optional function used if plugin has multiple pages
PageNames = { "Dashboard", "Configuration" }  --List the pages within the plugin
function GetPages(props)
  local pages = {}
  --[[ #include "src/pages.lua" ]]
  return pages
end

-- Define User configurable Properties of the plugin
function GetProperties()
  local props = {}
  return props
end

-- Defines the Controls used within the plugin
function GetControls(props)
  local ctrls = {}
  --[[ #include "src/controls.lua" ]]
  return ctrls
end

--Layout of controls and graphics for the plugin UI to display
function GetControlLayout(props)
  local layout = {}
  local graphics = {}
  --[[ #include "src/layout.lua" ]]
  return layout, graphics
end

--Start event based logic
if Controls then
  --[[ #include "src/runtime.lua" ]]
end
