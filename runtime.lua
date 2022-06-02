rapidjson = require("rapidjson")

iswebsock = false
websockbuffer = ""
poll_timer = Timer.New()
websock = TcpSocket.New()
websock.ReadTimeout = 10
websock.WriteTimeout = 0
websock.ReconnectTimeout = 2

------------------------------------------------------------------------------------------------------------------------------------------ Websock Functions \/

-- The following is based on lua-websockets by Gerhard Lipp. This has been hacked together to work within Q-Sys, and is a very rough proof of concept. Further work is required. - CB

--[[
Copyright (c) 2012 by Gerhard Lipp <gelipp@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]

bit = require"bit32"
rol = bit.rol
bxor = bit.bxor
bor = bit.bor
band = bit.band
bnot = bit.bnot
lshift = bit.lshift
rshift = bit.rshift
tconcat = table.concat
sunpack = string.unpack
base64_encode = enc
DEFAULT_PORTS = {ws = 80, wss = 443}
pack_bytes = string.char
write_int8 = pack_bytes

--------------------------------------------------------------
------------------- Read & Write Functions -------------------
--------------------------------------------------------------

local read_n_bytes = function(str, pos, n)
  pos = pos or 1
  return pos+n, string.byte(str, pos, pos + n - 1)
end

local read_int8 = function(str, pos)
  return read_n_bytes(str, pos, 1)
end

local read_int16 = function(str, pos)
  local new_pos,a,b = read_n_bytes(str, pos, 2)
  return new_pos, lshift(a, 8) + b
end

local read_int32 = function(str, pos)
  local new_pos,a,b,c,d = read_n_bytes(str, pos, 4)
  return new_pos,
  lshift(a, 24) +
  lshift(b, 16) +
  lshift(c, 8 ) +
  d
end

local write_int16 = function(v)
  return pack_bytes(rshift(v, 8), band(v, 0xFF))
end

local write_int32 = function(v)
  return pack_bytes(
    band(rshift(v, 24), 0xFF),
    band(rshift(v, 16), 0xFF),
    band(rshift(v,  8), 0xFF),
    band(v, 0xFF)
  )
end

-------------------------------------------------------------
-------------------- Encoding & Decoding --------------------
-------------------------------------------------------------

-- Following Websocket RFC: http://tools.ietf.org/html/rfc6455

local bits = function(...)
  local n = 0
  for _,bitn in pairs{...} do
    n = n + 2^bitn
  end
  return n
end

local bit_7 = bits(7)
local bit_0_3 = bits(0,1,2,3)
local bit_0_6 = bits(0,1,2,3,4,5,6)

-- TODO: improve performance
local xor_mask = function(encoded,mask,payload)
  local transformed,transformed_arr = {},{}
  -- xor chunk-wise to prevent stack overflow.
  -- sbyte and schar multiple in/out values
  -- which require stack
  for p=1,payload,2000 do
    local last = math.min(p+1999,payload)
    local original = {string.byte(encoded,p,last)}
    for i=1,#original do
      local j = (i-1) % 4 + 1
      transformed[i] = bxor(original[i],mask[j])
    end
    local xored = string.char(table.unpack(transformed,1,#original))
    table.insert(transformed_arr,xored)
  end
  return tconcat(transformed_arr)
end

local encode_header_small = function(header, payload)
  return string.char(header, payload)
end

local encode_header_medium = function(header, payload, len)
  return string.char(header, payload, band(rshift(len, 8), 0xFF), band(len, 0xFF))
end

local encode_header_big = function(header, payload, high, low)
  return string.char(header, payload)..write_int32(high)..write_int32(low)
end

local encode = function(data,opcode,masked,fin)
  local header = opcode or 1-- TEXT is default opcode
  if fin == nil or fin == true then
    header = bor(header,bit_7)
  end
  local payload = 0
  if masked then
    payload = bor(payload,bit_7)
  end
  local len = #data
  local chunks = {}
  if len < 126 then
    payload = bor(payload,len)
    table.insert(chunks,encode_header_small(header,payload))
  elseif len <= 0xffff then
    payload = bor(payload,126)
    table.insert(chunks,encode_header_medium(header,payload,len))
  elseif len < 2^53 then
    local high = math.floor(len/2^32)
    local low = len - high*2^32
    payload = bor(payload,127)
    table.insert(chunks,encode_header_big(header,payload,high,low))
  end
  if not masked then
    table.insert(chunks,data)
  else
    local m1 = math.random(0,0xff)
    local m2 = math.random(0,0xff)
    local m3 = math.random(0,0xff)
    local m4 = math.random(0,0xff)
    local mask = {m1,m2,m3,m4}
    table.insert(chunks,write_int8(m1,m2,m3,m4))
    table.insert(chunks,xor_mask(data,mask,#data))
  end
  return tconcat(chunks)
end

local decode = function(encoded)
  local encoded_bak = encoded
  if #encoded < 2 then
    return nil,2-#encoded
  end
  local pos,header,payload
  pos,header = read_int8(encoded,1)
  pos,payload = read_int8(encoded,pos)
  local high,low
  --if #encoded < pos then return nil, nil end  --cb
  encoded = string.sub(encoded,pos)
  local bytes = 2
  local fin = band(header,bit_7) > 0
  local opcode = band(header,bit_0_3)
  local mask = band(payload,bit_7) > 0
  payload = band(payload,bit_0_6)
  if payload > 125 then
    if payload == 126 then
      if #encoded < 2 then
        return nil,2-#encoded
      end
      pos,payload = read_int16(encoded,1)
    elseif payload == 127 then
      if #encoded < 8 then
        return nil,8-#encoded
      end
      pos,high = read_int32(encoded,1)
      pos,low = read_int32(encoded,pos)
      payload = high*2^32 + low
      if payload < 0xffff or payload > 2^53 then
        assert(false,"INVALID PAYLOAD "..payload)
      end
    else
      assert(false,"INVALID PAYLOAD "..payload)
    end
    
  --if #encoded < pos then return nil, nil end  --cb
    encoded = string.sub(encoded,pos)
    bytes = bytes + pos - 1
  end
  local decoded
  if mask then
    local bytes_short = payload + 4 - #encoded
    if bytes_short > 0 then
      return nil,bytes_short
    end
    local m1,m2,m3,m4
    
  --if #encoded < pos then return nil, nil end  --cb
    pos,m1 = read_int8(encoded,1)
    pos,m2 = read_int8(encoded,pos)
    pos,m3 = read_int8(encoded,pos)
    pos,m4 = read_int8(encoded,pos)
    encoded = string.sub(encoded,pos)
    local mask = {
      m1,m2,m3,m4
    }
    decoded = xor_mask(encoded,mask,payload)
    bytes = bytes + 4 + payload
    read(bytes)
  else
    local bytes_short = payload - #encoded
    if bytes_short > 0 then
      return nil,bytes_short
    end
    if #encoded > payload then
    
  --if #encoded < pos then return nil, nil end  --cb
      decoded = string.sub(encoded,1,payload)
    else
      decoded = encoded
    end
    bytes = bytes + payload
    read(bytes)
  end
  --if #encoded < pos then return nil, nil end  --cb
  return decoded,fin,opcode,encoded_bak:sub(bytes+1),mask
end

function read(chars)                                                          -- Buffer read function. Replaces sock:Read for websocket.
  local result = string.sub(websockbuffer, 1, chars)
  if chars == #websockbuffer then websockbuffer = "" return result end
  websockbuffer = string.sub(websockbuffer, -(#websockbuffer-chars))
  return result
end

-------------------------------------------------------------
-------------------- OBS Socket Handling --------------------
-------------------------------------------------------------

websock.Connected = function(sock)

  print("Sock.Info: Socket Connected")
  
  local request = string.format(
    "GET / HTTP/1.1\r\nHost: %s:%s\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: %s\r\nSec-WebSocket-Version: 13\r\n\r\n",
    server,
    string.format("%u", port),
    Crypto.Base64Encode(System.LockingId, true)
  )
  
  Debug(string.format("Sending Websocket Upgrade Request:\n\n%s", request))
  websock:Write(request)
end

websock.Reconnect = function(sock)
  Controls["status"].Value = 2
  Controls["status"].String = "Socket Reconnecting"
  iswebsock = false
  print("Sock.Info: Socket Reconnecting")
end

websock.Data = function()
  
  websockbuffer = websockbuffer..websock:Read(websock.BufferLength)
  --print(websockbuffer)
  local continue = true
  repeat
  continue = true
  if iswebsock then
    local indata2, correct = decode(websockbuffer)
      if correct and indata2 ~= nil then
        if string.len(indata2) > 0 then
          ParseResponse(indata2)
        end
        continue = false
      end
  else
    local loc = string.find(websockbuffer, string.char(129))
    if string.find(websockbuffer, "Connection: Upgrade") then
      iswebsock = true
      GotWebsocketUpgrade()
    end
    if loc then
      msg = read(loc-1)
    else
      msg = read(#websockbuffer)
    end
  end
  until continue
end

websock.Closed = function(sock)
  Controls["status"].Value = 2
  Controls["status"].String = "Socket Closed"
  iswebsock = false
  print("Sock.Info: Socket Closed by Remote")
end

websock.Error = function(sock, err)
  Controls["status"].Value = 2
  Controls["status"].String = "Socket has Error"
  iswebsock = false
  print(string.format("Sock.Info: Socket has Error [%s]", err))
end

websock.Timeout = function(sock, err)
  Controls["status"].Value = 2
  Controls["status"].String = "Socket Timed Out"
  iswebsock = false
  print(string.format("Sock.Info: Socket Timed Out [%s]", err))
end

-------------------------------------------------------------
-------------------- OBS API Functionality ------------------
-------------------------------------------------------------

function Initialize()
  
  ResetTimers()
  
  Controls["status"].Value = 5
  Controls["status"].String = ""
  
  Controls["is-streaming"].Boolean = false
  Controls["is-recording"].Boolean = false
  
  InitListBox("scenes")
  InitListBox("sources")
end

function Connect()
  
  server, port = Controls["ip-address"].String, 4444
  
  iswebsock = false
  
  if websock.IsConnected then websock:Disconnect() end
  
  if (not Controls["connect"].Boolean) then 
    ResetTimers()
    Controls["status"].Value = 3
    Controls["status"].String = "Manually Disconnected"
  return end
  
  Controls["status"].Value = 5
  Controls["status"].String = "Connecting..."
  
  websock:Connect(server, port);
  
end

function GotWebsocketUpgrade()

  if (not iswebsock) then return Debug("Error [Upgrade Rejected]") end
  
  ObsRequest({request_type = "GetAuthRequired"}, {message_id = "auth-required"})
  
end

function Authenticate(tbl)

  Initialize()
  
  local password = Controls["password"].String
  
  if (password == "") then 
    print("Set a Password!")
    Controls['status'].String = "Password Required"
  return end
  
  local challenge = tbl["challenge"]
  local salt = tbl["salt"]
  
  local secret_string = password .. salt
  local secret_hash = Crypto.Digest("sha256", secret_string)
  local secret = Crypto.Base64Encode(secret_hash)
  
  local auth_response_string = secret .. challenge
  local auth_response_hash = Crypto.Digest("sha256", auth_response_string)
  local auth_response = Crypto.Base64Encode(auth_response_hash)
  
  Debug("Attempting to Authenticate...")
  
  ObsRequest({request_type = "Authenticate"}, {auth = auth_response}, {message_id = "authenticate"})
end

function Begin()
  
  static_audio_sources = {}
  
  Controls["status"].Value = 0
  Controls["status"].String = string.format("Connected: %s", server)
  
  ObsRequest({request_type = "GetVersion"}, {name = "obs-studio-version"}, {message_id = ""})
  ObsRequest({request_type = "GetSourceTypesList"}, {message_id = "source-types-list"})
  ObsRequest({request_type = "GetTransitionList"}, {message_id = "get-transition-list"})
  ObsRequest({request_type = "GetTransitionDuration"}, {message_id = "get-transition-duration"})
  poll_timer:Start(1)
      
end

function SendWebsocket(data)
  if iswebsock and websock.IsConnected then
    websock:Write(encode(data, 1, 1))
  else
    Debug("Error [Websocket Upgrade Failed - Cannot Send Data]")
  end
end

function GetScene(string)
  for i, v in ipairs(Controls["scenes"]) do
    if string == v.String then
      return i
    end
  end
end

function ResetTimers()
  poll_timer:Stop()
end

function InitListBox(ctl_group)

  Controls[ctl_group].Choices = {}
  Controls[ctl_group].String = ""
  
end

function Poll()
  --print("Polling Status [Streaming?] [Studio Mode?] [Replay Buffer?]")
      
  ObsRequest({request_type = "GetStudioModeStatus"}, {message_id = "studio-mode-poll"})
  ObsRequest({request_type = "GetStreamingStatus"}, {message_id = "stream-status-poll"})
  ObsRequest({request_type = "GetReplayBufferStatus"}, {message_id = "replaybuffer-status-poll"})
end

function ObsRequest(...)

  tbl = {}
  
  local args = table.pack(...); args.n = nil
  
  for i, arg_table in ipairs(args) do
    for k, value in pairs(arg_table) do
      key = string.gsub(k, "_", "-")
      tbl[key] = value
    end
  end
  
  SendWebsocket(rapidjson.encode(tbl))
end

function SetLED(name, state, i)

  if (i) then
    Controls[name][i].Boolean = state
  else
    Controls[name].Boolean = state
  end
  
end

function DirectCut(scene)
  if (scene == "") then return end
  Debug(string.format("Cutting to Scene [%s]", scene))
  ObsRequest({request_type = "SetCurrentScene"}, {scene_name = scene}, {message_id = ""})
end

function SetSourceProps(this, ctl, vis)
  for i, v in pairs(props_presets) do
    if ctl.String == props_presets[i]["name"] then
    
      Debug(string.format("Setting Properties for Scene Item [%s]", Controls["sources"][this].String))
      
      ObsRequest(
        {request_type = "SetSceneItemProperties"}, 
        {scene_name = current_scene},
        {item = Controls["sources"].String},
        {visible = Controls["Source Render"].Boolean},
        {message_id = "set-props"}
      )
    end
  end
end

function Debug(input)
  if type(input) == "table" then
    --print(rapidjson.encode(input, {pretty = true}))
  else
    --print(input)
  end
end

function ParseResponse(data)

  tbl = rapidjson.decode(data)
  
  Debug(tbl)
  
  if ((tbl["status"] == "error") and (tbl["error"] == "Not Authenticated")) then
    Controls["status"].Value = 2
    Controls["status"].String = "Not Authenticated"
    return ObsRequest({request_type = "GetAuthRequired"}, {message_id = "auth-required"})
  end
  
  if (tbl["message-id"] == "auth-required") then
  
    if (tbl["authRequired"]) then
      Controls["status"].Value = 1
      Controls["status"].String = "Authentication Required"
      return Authenticate(tbl)
    else
      Begin()
    end
  
  elseif (tbl["message-id"] == "authenticate") then
  
    if (tbl["status"] == "ok") then
      Begin()
      Debug("Authentication Complete.")
    else
      Controls["status"].Value = 2
      Controls["status"].String = "Authentication Failed"
    end
  
  elseif tbl["obs-studio-version"] then
    
    Controls["obs-version"].String = tbl["obs-studio-version"]
    Controls["websocket-version"].String = tbl["obs-websocket-version"]
    
    local AvailableRequests = {}
    
    for request in tbl["available-requests"]:gmatch("(%w+),") do
      table.insert(AvailableRequests, request)
    end
    
    Debug(AvailableRequests)

    --Controls["Available Requests"].Choices = AvailableRequests
    
  elseif tbl["message-id"] == "stream-status-poll" then
    
    Debug(string.format("Streaming [%s], Recording [%s], Virtual Camera [%s]", tbl["streaming"], tbl["recording"], tbl["virtualcam"]))
    
    Controls["is-streaming"].Boolean = tbl["streaming"]
    Controls["stream-timecode"].String = tbl["stream-timecode"] and tbl["stream-timecode"]:match("[%w:]+") or ""
    
    if (not tbl["streaming"]) then
      Controls["stream-status-bitrate"].String = ""
      Controls["stream-status-fps"].String = ""
      Controls["stream-status-strain"].String = ""
      Controls["stream-status-cpu"].String = ""
      Controls["stream-status-memory"].String = ""
      Controls["stream-status-disk"].String = ""
    end
    
    Controls["is-recording"].Boolean = tbl["recording"]
    SetLED("recording-paused", tbl["recording-paused"])
    Controls["recording-timecode"].String = tbl["rec-timecode"] and tbl["rec-timecode"]:match("[%w:]+") or ""
    
    Controls["virtual-camera-active"].Boolean = tbl["virtualcam"]
    Controls["virtual-cam-timecode"].String = tbl["virtualcam-timecode"] and tbl["virtualcam-timecode"]:match("[%w:]+") or ""
    
  elseif tbl["message-id"] == "replaybuffer-status-poll" then
    
    Debug(string.format("Replay Buffer [%s]", tbl["isReplayBufferActive"]))
    
    Controls["replay-buffer-active"].Boolean = tbl["isReplayBufferActive"]
    Controls["save-replay-buffer"].IsDisabled = not tbl["isReplayBufferActive"]
    
  elseif tbl["update-type"] == "StreamStatus" then
    
    Controls["stream-status-bitrate"].String = string.format("%d Kbps", tbl["kbits-per-sec"])
    Controls["stream-status-fps"].String = math.floor(tbl["fps"])
    Controls["stream-status-strain"].String = string.format("%d%%", math.floor(tbl["strain"]))
    Controls["stream-status-cpu"].String = string.format("%d%%", math.floor(tbl["cpu-usage"]))
    Controls["stream-status-memory"].String = string.format("%d MB", math.floor(tbl["memory-usage"]))
    Controls["stream-status-disk"].String = string.format("%d MB", math.floor(tbl["free-disk-space"]))
      
    bitrate = tbl["kbits-per-sec"]
    dropped_frames = tbl["num-dropped-frames"]
    strain = tbl["strain"]
    fps = string.format("%.f", tbl["fps"])
    
  end
  
  for i, update_type in ipairs({"RecordingStarted", "RecordingStopping", "RecordingStopped"}) do
    if (tbl["update-type"] == update_type) then
    
      Controls["recording-filename"].String = tbl["recordingFilename"]
    
    end
  end
  
  -----------------------------------
  ----- Update Scenes & Sources -----
  -----------------------------------
  
  if tbl["message-id"] == "scene-list" then
    
    scene_list = {}
    current_scene = {}
    source_list = {}
    source_properties = {}
    
    current_scene = tbl["current-scene"]
    
    for i, scene in ipairs(tbl.scenes) do
      table.insert(scene_list, scene.name)
    end
    
    Controls["scenes"].Choices = scene_list
    Controls["scenes"].String = current_scene
    Controls["sources"].String = ""
    Controls["audio-mixer"].String = ""
    Controls["source-locked"].Boolean = false
    Controls["source-render"].Boolean = false
    Controls["source-mute"].Boolean = false
    Controls["source-volume"].Boolean = false
    Controls["source-locked"].IsDisabled = true
    Controls["source-render"].IsDisabled = true
    Controls["source-mute"].IsDisabled = true
    Controls["source-volume"].IsDisabled = true
    Controls["source-forward"].IsDisabled = true 
    Controls["source-backward"].IsDisabled = true
    
    ObsRequest({request_type = "GetSceneItemList"},{message_id = "scene-item-list"})
  
  elseif tbl["message-id"] == "reorder-scene-items" then

    ObsRequest({request_type = "GetSceneItemList"},{message_id = "scene-item-list"})

  elseif tbl["message-id"] == "get-scene-item-props" then 

    Controls["source-render"].Boolean = tbl.visible
    Controls["source-locked"].Boolean = tbl.locked
    Controls["source-mute"].Boolean = tbl.muted
    Controls["source-forward"].IsDisabled = false
    Controls["source-backward"].IsDisabled = false
    Controls["source-locked"].IsDisabled = false
    Controls["source-render"].IsDisabled = false

  elseif tbl["message-id"] == "get-scene-item-mute" then 
  

    if (tbl.muted == nil) then return end

    Controls["source-mute"].Boolean = tbl.muted
    Controls["source-mute"].IsDisabled = false

  elseif tbl["message-id"] == "get-scene-item-volume" then 

    if not tbl.volume then return end

    Controls["source-volume"].Value = tbl.volume
    Controls["source-volume"].IsDisabled = false

  elseif tbl["message-id"] == "source-types-list" then

    types = {}

    for i, tbl in ipairs(tbl.types) do
      types[tbl.typeId] = {}
      types[tbl.typeId].hasAudio = tbl.caps.hasAudio
    end

    ObsRequest({request_type = "GetSourcesList"},{message_id = "source-list"})    

  elseif tbl["message-id"] == "source-list" then

    --[[for i,tbl in ipairs(tbl.sources) do

      if tbl.typeId == "wasapi_input_capture" or tbl.typeId == "wasapi_output_capture" then 
        table.insert(static_audio_sources, tbl.name)
      end 

    end]]

    ObsRequest({request_type = "GetSceneList"}, {name = "scenes"}, {message_id = "scene-list"})

    --Controls["audio-mixer"].Choices = static_audio_sources

  elseif tbl["message-id"] == "get-current-scene" then
    
  elseif tbl["message-id"] == "scene-item-list" then

    source_list = {}
    source_properties = {}
    local audio_mixer = {}

    -- copy global audio sources into the audio mixer table
    for i, source in ipairs(static_audio_sources) do
      table.insert(audio_mixer, 1, source)
    end

    for i, source in ipairs(tbl.sceneItems) do
      table.insert(source_list, 1, source.sourceName)
      
      source_properties[source.sourceName] = {}
      source_properties[source.sourceName]["sourceKind"] = source.sourceKind
      source_properties[source.sourceName]["sourceType"] = source.sourceType

      -- insert scene items with audio into the audio mixer table
      if types[source.sourceKind].hasAudio then table.insert(audio_mixer, 1, source.sourceName) end
    end

    Controls["audio-mixer"].Choices = audio_mixer
    Controls["sources"].Choices = source_list
    
  elseif tbl["message-id"] == "get-transition-list" then

    if (not tbl.transitions) then return end

    local transitions = {}

    for i, tbl in ipairs(tbl["transitions"]) do 
      table.insert(transitions, tbl.name)
    end

    Controls["transition-type"].Choices = transitions
    Controls["transition-type"].String = tbl["current-transition"]

  elseif tbl["message-id"] == "get-transition-duration" then

    if (not tbl["transition-duration"]) then return end

    Controls["transition-duration"].Value = tbl["transition-duration"]

  end
  
  -------------------------
  ----- Update Events -----
  -------------------------
  
  for i, update in ipairs({
  "SwitchTransition",
  "TransitionListChanged",
  "TransitionDurationChanged"
}) do
    if update == tbl["update-type"] then
      Debug(string.format("Update Event Received [%s] - Fetching Transition Information...", update))
      ObsRequest({request_type = "GetTransitionList"}, {message_id = "get-transition-list"})
      ObsRequest({request_type = "GetTransitionDuration"}, {message_id = "get-transition-duration"})
    break end
  end

  for i, update in ipairs({
  "SwitchScenes",
  "ScenesChanged",
  "SceneCollectionChanged",
  "SceneCollectionListChanged"
}) do
    if update == tbl["update-type"] then
      Debug(string.format("Update Event Received [%s] - Fetching Scene List Again...", update))
      ObsRequest({request_type = "GetSceneList"}, {name = "scenes"}, {message_id = "scene-list"})
    break end
  end

for i, update in ipairs({
  "SceneItemAdded",
  "SceneItemRemoved",
  "SceneItemVisibilityChanged",
  "SceneItemLockChanged",
  "SceneItemTransformChanged",
  "SceneItemSelected",
  "SceneItemDeselected",
  "SourceCreated",
  "SourceDestroyed",
  "SourceVolumeChanged",
  "SourceMuteStateChanged",
  "SourceAudioSyncOffsetChanged",
  "SourceAudioDeactivated",
  "SourceAudioActivated",
  "SourceAudioMixersChanged",
  "SourceRenamed",
  "SourceFilterAdded",
  "SourceFilterRemoved",
  "SourceFilterVisibilityChanged",
  "SourceFiltersReordered",
  "SourceOrderChanged",
}) do
    if update == tbl["update-type"] then
      Debug(string.format("Source Update Event Received [%s] - Fetching Scene Items...", update))
      ObsRequest({request_type = "GetSceneItemList"},{message_id = "scene-item-list"})
    break end
  end
  ---------------------------------
  ----- Force Studio Mode Off -----
  ---------------------------------
  
  if tbl["message-id"] == "studio-mode-poll" then
    if tbl["studio-mode"] then
      Debug("Studio Mode Detected - Automatically Disabling Studio Mode.")
      Timer.CallAfter(function() ObsRequest({request_type = "DisableStudioMode"}, {message_id = ""}) end, 1)
    end
  end
  
end

-------------------------------------------------------
-------------------- EventHandlers --------------------
-------------------------------------------------------

poll_timer.EventHandler = Poll

Controls["ip-address"].EventHandler = Connect
Controls["password"].EventHandler = Connect
Controls["connect"].EventHandler = Connect

Controls["transition-type"].EventHandler = function(c)
  ObsRequest({request_type = "SetCurrentTransition"}, {transition_name = c.String}, {message_id = ""})
end

Controls["scenes"].EventHandler = function(c) DirectCut(c.String) end

Controls["sources"].EventHandler = function(c)

  if (c.String == "") then return end

  ObsRequest(
    {request_type = "GetSceneItemProperties"}, 
    {scene_name = current_scene},
    {item = Controls["sources"].String},
    {message_id = "get-scene-item-props"}
  )

end

Controls["audio-mixer"].EventHandler = function(c)
  
  if (c.String == "") then return end

  ObsRequest(
    {request_type = "GetMute"},
    {source = Controls["audio-mixer"].String},
    {message_id = "get-scene-item-mute"}
  )

  ObsRequest(
    {request_type = "GetVolume"},
    {source = Controls["audio-mixer"].String},
    {useDecibel = true},
    {message_id = "get-scene-item-volume"}
  )

end

for i, controlName in ipairs({"source-forward", "source-backward"}) do 
  Controls[controlName].EventHandler = function()
    if (Controls["sources"].String == "") then return end

    local order = {}
    local id = nil 

    for i, source in ipairs(Controls["sources"].Choices) do
      table.insert(order, {name = source})
      if source == Controls["sources"].String then id = i end
    end

    if not id then return end

    table.remove(order, id)

    if controlName == "source-forward" then 
      id = id - 1
    elseif controlName == "source-backward" then 
      id = id + 1
    end

    result, err = pcall(function()
      table.insert(order, id, {name = Controls["sources"].String})
    end)

    if err then return end

    ObsRequest({request_type = "ReorderSceneItems"}, {scene = Controls["scenes"].String}, {items = order}, {message_id = "reorder-scene-items"})
    end
end

Controls["source-locked"].EventHandler = function(c)

  if (c.String == "") then return end

  ObsRequest(
    {request_type = "SetSceneItemProperties"}, 
    {scene_name = current_scene},
    {item = Controls["sources"].String},
    {locked = c.Boolean},
    {message_id = "set-props"}
  )
end

Controls["source-render"].EventHandler = function(c)

  if (c.String == "") then return end

  ObsRequest(
    {request_type = "SetSceneItemProperties"}, 
    {scene_name = current_scene},
    {item = Controls["sources"].String},
    {visible = c.Boolean},
    {message_id = "set-props"}
  )
end

Controls["source-mute"].EventHandler = function(c)

  if (c.String == "") then return end

  ObsRequest(
    {request_type = "SetMute"},
    {source = Controls["audio-mixer"].String},
    {mute = c.Boolean},
    {message_id = ""}
  )
end

Controls["source-volume"].EventHandler = function(c)

  if (c.String == "") then return end

  ObsRequest(
    {request_type = "SetVolume"},
    {source = Controls["audio-mixer"].String},
    {useDecibel = true},
    {volume = c.Value},
    {message_id = ""}
  )
end

Controls["transition-duration"].EventHandler = function(c)

  ObsRequest(
    {request_type = "SetTransitionDuration"},
    {duration = math.floor(c.Value)},
    {message_id = ""}
  )

end 

Controls["start-streaming"].EventHandler = function() ObsRequest({request_type = "StartStreaming"}, {message_id = "streaming"}) end
Controls["stop-streaming"].EventHandler = function() ObsRequest({request_type = "StopStreaming"}, {message_id = "streaming"}) end

Controls["start-recording"].EventHandler = function() ObsRequest({request_type = "StartRecording"}, {message_id = "recording"}) end
Controls["stop-recording"].EventHandler = function() ObsRequest({request_type = "StopRecording"}, {message_id = "recording"}) end
Controls["pause-recording"].EventHandler = function() ObsRequest({request_type = "PauseRecording"}, {message_id = ""}) end
Controls["resume-recording"].EventHandler = function() ObsRequest({request_type = "ResumeRecording"}, {message_id = ""}) end

Controls["start-virtual-cam"].EventHandler = function() ObsRequest({request_type = "StartVirtualCam"}, {message_id = "virtualcam"}) end
Controls["stop-virtual-cam"].EventHandler = function() ObsRequest({request_type = "StopVirtualCam"}, {message_id = "virtualcam"}) end

Controls["start-replay-buffer"].EventHandler = function() ObsRequest({request_type =  "StartReplayBuffer"}, {message_id = "replaybuffer"}) end
Controls["stop-replay-buffer"].EventHandler = function() ObsRequest({request_type =  "StopReplayBuffer"}, {message_id = "replaybuffer"}) end
Controls["save-replay-buffer"].EventHandler = function() ObsRequest({request_type = "SaveReplayBuffer"}, {message_id = "savereplaybuffer"}) end

Initialize()
Connect()