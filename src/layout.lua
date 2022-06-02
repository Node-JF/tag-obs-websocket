local CurrentPage = PageNames[props["page_index"].Value]
if CurrentPage == "Dashboard" then

  table.insert(graphics,{
    Type = "GroupBox",
    CornerRadius = 15,
    Fill = {58,58,58},
    StrokeWidth = 0,
    Position = {0,0},
    Size = {1000, 430}
  })

  Logo = "--[[ #encode "src/logo.png" ]]"
  table.insert(graphics,
    {Type = "Image",
    Image = Logo,
    Position = {8,8},
    Size = {100,100}
  })

  table.insert(graphics,{
    Type = "Label",
    Text = "OBS Studio",
    Position = {118,8},
    Size = {200,100},
    Font = "Roboto",
    FontSize = 30,
    FontStyle = "Light",
    Color = {255,255,255},
    HTextAlign = "Left",
  })

  for i, name in ipairs({
    "OBS Version",
    "Websocket Version",
  }) do

  table.insert(graphics,{
    Type = "Label",
    Text = name,
    Position = {318,8+(16*(i-1))},
    Size = {110,16},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    HTextAlign = "Left",
  })

  layout[string.gsub(string.lower(name), " ", "-")] = {
    PrettyName = string.format("Plugin Information~%s", name),
    Style = "Text",
    TextBoxStyle = "Normal",
    Font = "Roboto",
    FontStyle = "Light",
    IsReadOnly = true,
    Margin = 1,
    Color = {194,194,194},
    Position = {318+110,8+(16*(i-1))},
    Size = {64,16}
  }
end

  local sections = {
    {8, 130},
    {202, 130},
    {396, 130},
    {590, 130},
    {784, 130}
  }

  table.insert(graphics,{
    Type = "Text",
    Text = "Scenes",
    Position = sections[1],
    Size = {190,20},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    Fill = {70,70,70}
  })

  layout["scenes"] = {
    PrettyName = "Scenes",
    Style = "ListBox",
    Position = {sections[1][1],130+24},
    Size = {190,155}
  }

  table.insert(graphics,{
    Type = "Text",
    Text = "Sources",
    Position = sections[2],
    Size = {190,20},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    Fill = {70,70,70}
  })

  layout["sources"] = {
    PrettyName = "Sources",
    Style = "ListBox",
    Position = {sections[2][1],130+24},
    Size = {190,155}
  }

  table.insert(graphics,{
    Type = "Text",
    Text = "Audio Mixer",
    Position = sections[3],
    Size = {190,20},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    Fill = {70,70,70}
  })

  layout["audio-mixer"] = {
    PrettyName = "Audio Mixer",
    Style = "ListBox",
    Position = {sections[3][1],130+24},
    Size = {190,155}
  }

  table.insert(graphics,{
    Type = "Text",
    Text = "Scene Transitions",
    Position = sections[4],
    Size = {190,20},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    Fill = {70,70,70}
  })

  table.insert(graphics,{
    Type = "Label",
    Text = "Type",
    Position = {sections[4][1],130+24},
    Size = {60,16},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    HTextAlign = "Left",
  })

  layout["transition-type"] = {
    PrettyName = "Transition~Type",
    Style = "ComboBox",
    CornerRadius = 2,
    Position = {sections[4][1]+60,130+24},
    Margin = 1,
    Size = {130,16}
  }

  table.insert(graphics,{
    Type = "Label",
    Text = "Duration",
    Position = {sections[4][1],130+24+16},
    Size = {60,16},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    HTextAlign = "Left",
  })

  layout["transition-duration"] = {
    PrettyName = "Transition~Duration",
    Style = "Text",
    CornerRadius = 2,
    TextBoxStyle = "Normal",
    Margin = 1,
    Position = {sections[4][1]+60,130+24+16},
    Size = {100,16}
  }

  table.insert(graphics,{
    Type = "Label",
    Text = "ms",
    Position = {sections[4][1]+60+100,130+24+16},
    Size = {30,16},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    HTextAlign = "Left",
  })

  table.insert(graphics,{
    Type = "Text",
    Text = "Controls",
    Position = sections[5],
    Size = {190,20},
    Font = "Roboto",
    FontStyle = "Light",
    Color = {204,204,204},
    Fill = {70,70,70}
  })

  for i, name in ipairs({
      "Start Streaming",
      "Stop Streaming",
      "Start Recording",
      "Stop Recording",
      "Pause Recording",
      "Resume Recording",
      "Start Replay Buffer",
      "Stop Replay Buffer",
      "Save Replay Buffer",
      "Start Virtual Cam",
      "Stop Virtual Cam"
    }) do

    table.insert(graphics,{
      Type = "Label",
      Text = name,
      Position = {sections[5][1],sections[5][2]+6+(i*16)},
      Size = {154,16},
      Font = "Roboto",
      FontStyle = "Light",
      Color = {204,204,204},
      HTextAlign = "Left",
    })

    layout[string.gsub(string.lower(name), " ", "-")] = {
      PrettyName = string.format("Controls~Main~%s", name),
      ButtonStyle = "Trigger",
      CornerRadius = 2,
      Font = "Roboto",
      FontStyle = "Light",
      Position = {sections[5][1]+154,sections[5][2]+6+(i*16)},
      Size = {36,16}
    }
  end

  for i, name in ipairs({
      "Source Forward",
      "Source Backward",
      "Source Render",
      "Source Locked"
    }) do
    layout[string.gsub(string.lower(name), " ", "-")] = {
      PrettyName = string.format("Controls~Source~%s", name),
      ButtonStyle = (i<=2 and "Trigger" or "Toggle"),
      CornerRadius = 2,
      Font = "Roboto",
      FontStyle = "Light",
      Position = {sections[2][1]+((i-1)*28),sections[2][2]+24+155},
      Size = {28,28},
      Color = {31,31,31},
      UnlinkOffColor = true,
      OffColor = {58,58,58},
      StrokeWidth = 0
    }
  end

  table.insert(graphics,{
    Type = "Text",
    Text = 'Tip: Recordings cannot be paused if the recording quality is set to "Same as stream".',
    Position = {8,sections[2][2]+24+165+28},
    Size = {578,21},
    Font = "Roboto",
    FontStyle = "Medium",
    Color = {192,117,33},
    HTextAlign = "Left",
  })

  table.insert(graphics,{
    Type = "Text",
    Text = 'Tip: "Enable Replay Buffer" must be enabled in Settings -> Output -> Recording.',
    Position = {8,sections[2][2]+24+165+28+21},
    Size = {578,21},
    Font = "Roboto",
    FontStyle = "Medium",
    Color = {192,117,33},
    HTextAlign = "Left",
  })

  table.insert(graphics,{
    Type = "Text",
    Text = 'Tip: For discrete Scene/Source/Audio Mixer controls, create a copy of the ListBox control and change the presentation to Button -> String, with the "Button String" value as the item name.',
    Position = {8,sections[2][2]+24+165+28+21+21},
    Size = {578,30},
    Font = "Roboto",
    FontStyle = "Medium",
    Color = {192,117,33},
    HTextAlign = "Left",
  })

  layout["source-volume"] = {
    PrettyName = "Controls~Audio Mixer~Volume",
    Style = "Fader",
    Color = {254,248,164},
    Position = {sections[3][1],sections[3][2]+24+155},
    Size = {162,28}
  }

  layout["source-mute"] = {
    PrettyName = "Controls~Audio Mixer~Mute",
    Style = "Button",
    Position = {sections[3][1]+162,sections[3][2]+24+155},
    Size = {28,28},
    Color = {205,50,50},
    UnlinkOffColor = true,
    OffColor = {58,58,58},
    StrokeWidth = 0
  }

  for i, name in ipairs({
      "Is Streaming",
      "Virtual Camera Active",
      "Is Recording",
      "Recording Paused",
      "Replay Buffer Active",
    }) do

      table.insert(graphics,{
        Type = "Label",
        Text = name,
        Position = {sections[4][1],8+((i-1)*16)},
        Size = {110,16},
        Font = "Roboto",
        FontStyle = "Light",
        Color = {204,204,204},
        HTextAlign = "Left",
      })

      layout[string.gsub(string.lower(name), " ", "-")] = {
        PrettyName = string.format("LED~%s", name),
        Style = "Led",
        Position = {sections[4][1]+110,8+((i-1)*16)},
        Size = {16,16},
        Color = {128,255,0},
        UnlinkOffColor = true,
        OffColor = {124,0,0}
      }
  end

  for i, name in ipairs({
    "Stream Timecode",
    "Virtual Cam Timecode",
    "Recording Timecode",
  }) do

    layout[string.gsub(string.lower(name), " ", "-")] = {
      PrettyName = string.format("Timecode~%s", name),
      Style = "Text",
      IsReadOnly = true,
      Color = {194,194,194},
      Margin = 1,
      Position = {sections[4][1]+126,8+((i-1)*16)},
      Size = {64,16}
    }
end

  for i, name in ipairs({
    "Stream Status Bitrate",
    "Stream Status FPS",
    "Stream Status Strain",
    "Stream Status CPU",
    "Stream Status Memory",
    "Stream Status Disk",
  }) do

    table.insert(graphics,{
      Type = "Label",
      Text = string.gsub(name, 'Stream Status ', ""),
      Position = {sections[5][1],8+((i-1)*16)},
      Size = {100,16},
      Font = "Roboto",
      FontStyle = "Light",
      Color = {204,204,204},
      HTextAlign = "Left",
    })

    layout[string.gsub(string.lower(name), " ", "-")] = {
      PrettyName = string.format("Stream Statistics~%s", name),
      Style = "Text",
      IsReadOnly = true,
      Color = {194,194,194},
      Margin = 1,
      Position = {sections[5][1]+100,8+((i-1)*16)},
      Size = {90,16}
    }
end

elseif CurrentPage == "Configuration" then
  local y = {}
  for i, label in ipairs({
    "Status",
    "IP Address",
    "Password",
    "Connect"
  }) do
    table.insert(y, (i-1)*18)
    table.insert(graphics,{
      Type = "Text",
      Text = label,
      Position = {0, y[i]},
      Size = {128,16},
      HTextAlign = "Left"
    })
  end
  layout["status"] = {
    PrettyName = "Configuration~Status",
    -- Style = "Button",
    Position = {128,y[1]},
    Size = {160,16},
  }
  layout["ip-address"] = {
    PrettyName = "Configuration~IP Address",
    Style = "Text",
    Position = {128,y[2]},
    Size = {96,16},
  }
  layout["password"] = {
    PrettyName = "Configuration~Password",
    Style = "Text",
    Position = {128,y[3]},
    Size = {96,16},
  }
  layout["connect"] = {
    PrettyName = "Configuration~Connect",
    Style = "Button",
    Position = {128,y[4]},
    Size = {36,16},
  }

end