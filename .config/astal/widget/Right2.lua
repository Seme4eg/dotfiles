-- local astal = require("astal.gtk3")
local Widget = require("astal.gtk3.widget")
local Network = require("lgi").require("AstalNetwork")
local bind = require("astal").bind

local function Net()
  local network = Network.get_default()
  -- local wifi = Network.get_default().wifi

  -- local some = bind(network, "wifi"):as(function(obj)
  --   print("bandwidth: ", obj.bandwidth)
  --   print("device: ", obj.device)
  --   print("active_connection: ", obj.active_connection)
  --   print("active_access_point: ", obj.active_access_point)
  --   print("access_points: ", obj.access_points)
  --   print("enabled: ", obj.enabled)
  --   print("internet: ", obj.internet)
  --   print("bandwidth: ", obj.bandwidth)
  --   print("ssid: ", obj.ssid)
  --   print("strength: ", obj.strength)
  --   print("frequency: ", obj.frequency)
  --   print("state: ", obj.state)
  --   print("icon_name: ", obj.icon_name)
  --   print("is_hotspot: ", obj.is_hotspot)
  --   print("scanning: ", obj.scanning)
  --   return "yes"
  -- end)

  bind(network, "connectivity"):as(
    function(status) end
  )

  local isConnected = bind(network, "connectivity"):as(
    function(status)
      print("STATUS", status)
      return status == "LIMITED" or status == "FULL"
    end
  )

  return Widget.Revealer({
    class_name = "connected",
    reveal_child = isConnected,
    transition_duration = 350,
    Widget.Overlay({
      child = Widget.LevelBar({
        width_request = bind(network, "connectivity"):as(function(status)
          return status == "LIMITED" or status == "FULL" and 38 or 0
        end),
        valign = "CENTER",
        value = bind(network, "wifi"):as(function(v) return v.strength / 100 end)
      }),
      overlays = {
        Widget.Label({
        label = bind(network, "wifi"):as(function(w) return w.bandwidth end)
      })
        }
    })
  })
end

return function()
  return Widget.Box({
    class_name = "sys_info",
    spacing = 10,
    Net()
  })
end
