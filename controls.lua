table.insert(ctrls, {
  Name = "status",
  ControlType = "Indicator",
  IndicatorType = "Status",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "ip-address",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "password",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "connect",
  ControlType = "Button",
  ButtonType = "Toggle",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "obs-version",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "websocket-version",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "scenes",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "sources",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "audio-mixer",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "is-streaming",
  ControlType = "Indicator",
  IndicatorType = "LED",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "is-recording",
  ControlType = "Indicator",
  IndicatorType = "LED",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "recording-paused",
  ControlType = "Indicator",
  IndicatorType = "LED",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "replay-buffer-active",
  ControlType = "Indicator",
  IndicatorType = "LED",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "virtual-camera-active",
  ControlType = "Indicator",
  IndicatorType = "LED",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

table.insert(ctrls, {
  Name = "transition-type",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "transition-duration",
  ControlType = "Knob",
  ControlUnit = "Integer",
  Max = 5000,
  Min = 1,
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-volume",
  ControlType = "Knob",
  ControlUnit = "dB",
  Max = 0,
  Min = -100,
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-mute",
  ControlType = "Button",
  ButtonType = "Toggle",
  Icon = "Volume Strike",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-render",
  ControlType = "Button",
  ButtonType = "Toggle",
  Icon = "Eye",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-locked",
  ControlType = "Button",
  ButtonType = "Toggle",
  Icon = "Lock",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-forward",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Arrow Up",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "source-backward",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Arrow Down",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "recording-filename",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-timecode",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "recording-timecode",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "virtual-cam-timecode",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "start-streaming",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Play",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stop-streaming",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Stop",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "start-recording",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Record",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stop-recording",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Stop",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "pause-recording",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Pause",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "resume-recording",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Play Pause",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "start-replay-buffer",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Play",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stop-replay-buffer",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Stop",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "save-replay-buffer",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Download",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "start-virtual-cam",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Play",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stop-virtual-cam",
  ControlType = "Button",
  ButtonType = "Trigger",
  Icon = "Stop",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-bitrate",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-fps",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-strain",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-cpu",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-memory",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "stream-status-disk",
  ControlType = "Text",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})