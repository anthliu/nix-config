local snapshot = "/run/gputemps/temps.json"

local function formatTemp(value)
  if type(value) ~= "number" or value <= 0 then
    return "--°"
  end
  return string.format("%d°", math.floor(value + 0.5))
end

local function severity(core, junction, vram)
  if core >= 85 or junction >= 95 or vram >= 95 then
    return "error"
  end
  if core >= 70 or junction >= 80 or vram >= 80 then
    return "tertiary"
  end
  return "on_surface"
end

local function showUnavailable()
  barWidget.setText("--° --° --°")
  barWidget.setColor("on_surface")
  barWidget.setGlyphColor("on_surface")
  barWidget.setTooltip("GPU temperatures unavailable")
end

local function showSnapshot(contents, readError)
  if readError or not contents then
    showUnavailable()
    return
  end

  local data = noctalia.json.decode(contents)
  local gpu = data and data.gpus and data.gpus[1]
  if type(gpu) ~= "table" then
    showUnavailable()
    return
  end

  local core = tonumber(gpu.core) or -1
  local junction = tonumber(gpu.junction) or -1
  local vram = tonumber(gpu.vram) or -1
  barWidget.setText(formatTemp(core) .. " " .. formatTemp(junction) .. " " .. formatTemp(vram))
  local color = severity(core, junction, vram)
  barWidget.setColor(color)
  barWidget.setGlyphColor(color)
  barWidget.setTooltip({
    { key = "Core", value = formatTemp(core) },
    { key = "Junction", value = formatTemp(junction) },
    { key = "VRAM", value = formatTemp(vram) },
  })
end

function update()
  noctalia.setUpdateInterval(3000)
  barWidget.setGlyph("temperature")
  if not noctalia.readFileAsync(snapshot, showSnapshot) then
    showUnavailable()
  end
end
