local core = require 'NSMBWii_Core'

--Edit this to have the location and filename of the file you want the script to create.
local instance = ReadValueString(0x80D20F04, 99)
local writeFileDirectory = 'Studio\\TAS Files\\'  --defines export directory. This folder MUST preexist before starting the script! If exporting full game, I reccommend to make this folder empty.
local writeFileName = instance  --exports to current instance name at script start (eg. '01-01' for 1-1 or 'CS_W5' for world 5 map). Not used for fullgame files.

local exportType = 1  -- 1 = write to single file; 2 = fullgame export (writes to multiple files in the directory)
local isInMainFile = true

local lastInstance = instance
local isNowLoading = true
local messageNum = 0
local instanceLoadDoc = '\n'
local round = 0
local inputCall = 1
local fileLineCount = 0

local scriptFirstFrame = GetFrameCount()
local thisLineStartF = scriptFirstFrame
local lastFrame = scriptFirstFrame

local writeQueue = {}

if ReadValueString(3, 1) == 'E' then  --Determines where to read input data from. TODO: add commented addresses for other players
  dataaddr = '0x8039F460'
elseif ReadValueString(3, 1) == 'J' then
  dataaddr = '0x8039F120'
end

local data = ReadValue16(dataaddr)
local lastData = data
local tilt = 512
local currTilt = 512
local inputLineNumber = 1


function onScriptStart()
  if exportType == 1 then
    if writeFileName == '' then
      writeFileName = 'BOOT'
    end
    local fileNameString = writeFileDirectory .. writeFileName
    local n = 0
    while io.open(string.format('%s.tas',fileNameString)) ~= nil do
      n = n + 1
      fileNameString = string.format('%s (%.0f)', writeFileDirectory .. writeFileName, n)
    end
    writeFileName = string.format('%s.tas',fileNameString)
    messageSend(string.format('Exporting inputs to: %s%s', writeFileDirectory, writeFileName), 0xD2691E)
    outputFile = io.open(writeFileName, "w+")
    outputFile:write(string.format('#RNG: 0x%X\n\n#Start', ReadValue32(core.rng.addr)))  --set up export file header
  elseif exportType == 2 then
    outputFile = io.open(writeFileDirectory .. '0 - Fullgame File.tas', "w+")
    outputFile:write(string.format('#Category:\n#Authors:\n\n#Game Version: %s%d\n#Write, 32, RNG, 0x%X\n\n#Start', ReadValueString(3, 1), ReadValue8(7), ReadValue32(core.rng.addr)))  --set up fullgame export file header
  end
end

function onScriptCancel()
  addInputLineToQueue()
  writeWholeQueueToFile()
end

function isPressed(button, inputs)
  return button & inputs == button
end

function getLoadInfo()
  if core.object.list().ObjectNum == 1 then  --cannot be predicted; abort
    return isNowLoading
  end
  if core.object.list().loadCheckObjs < 2 then  --is loading
    return true
  else  --is not loading
    return false
  end
end

function convertInputsToLine(buttonData)
  local newLine = ''
  local dpadInput = 0
  if isPressed(1, buttonData) then  --Press Left
    newLine = newLine .. ',L'
    dpadInput = 1
  elseif isPressed(2, buttonData) then  --Press Right
    newLine = newLine .. ',R'
    dpadInput = 1
  end
  if isPressed(8, buttonData) then  --Press Up
    newLine = newLine .. ',U'
  elseif isPressed(4, buttonData) then  --Press Down
    newLine = newLine .. ',D'
  end
  if isPressed(2048, buttonData) then  --Press Jump
    newLine = newLine .. ',J'
  elseif isPressed(256, buttonData) then  --Press 2 (nunchuck controls)
    newLine = newLine .. ',K'
  end
  if isPressed(32768, buttonData) then  --Press Home
    newLine = newLine .. ',H'
  end
  if isPressed(1024, buttonData) then  --Press B (run + 1 action)
    newLine = newLine .. ',G'
  elseif isPressed(8192, buttonData) == false and dpadInput == 1 then  --Don't hold run if holding left or right
    newLine = newLine .. ',N'
  end
  if isPressed(512, buttonData) then  --Press 1 (nunchuck controls)
    newLine = newLine .. ',O'
  end
  if isPressed(4096, buttonData) then  --Press Minus
    newLine = newLine .. ',M'
  end
  if isPressed(16, buttonData) then  --Press Plus
    newLine = newLine .. ',P'
  end
  
  return newLine
end

function endLineAndSend(frames, inputs)
  local output = string.format('%4.0f', frames) .. string.format('%s', inputs)
  outputFile:write('\n', output)
end

function onScriptUpdate()  --called every input call (at least 3 times per frame)
  --RenderText('Celeste TAS Format Exporting', 137, 14, 0x00FF00, 11)
  inputCall = inputCall + 1
  local currFrame = GetFrameCount()
  if currFrame ~= lastFrame then  --input call 1
    if currFrame ~= lastFrame+1 then
      messageSend("Error! Savestate loaded while exporting!\nOnly do this if you know what you're doing.", 0xFF0000)
      messageNum = messageNum+1
    end
    inputCall = 1
    lastFrame = currFrame
    messageNum = 0
    data = ReadValue16(dataaddr)  --get controller input. For some reason we must do this on the first input call
  elseif inputCall == 2 and isNowLoading == false then  --Do most logic now because some memory values don't update before the first input call
    isNowLoading = getLoadInfo()
    messageSend('Exporting Inputs...', 0x00FF00)
    --lineFrameCount = lineFrameCount + 1
    if tilt ~= currTilt then
      currTilt = tilt
      --messageSend('Tilt change detected!', 0x00FF00)
      addInputLineToQueue()
      addLineToQueue(string.format('Tilt, %d', tilt))
    end
    if ReadValue8(0x8154C6BF) == 1 then  --if spinput went through
      addSpinput()
    end
    if data ~= lastData then
      --messageSend('Input Change Detected!', 0x00FF00)
      addInputLineToQueue()
      lastData = data
    end
    
    tilt, _, _ = GetAccel(4)  --get tilt data. Record now so it is updated and sends the line next frame.
    instance = ReadValueString(0x80D20F04, 99)
    if isNowLoading then  --new load encountered
      messageSend('New load detected! Waiting for it to end...', 0x00FF00)
      local instanceLoadNum = 0
      if string.find(instanceLoadDoc, string.format('"%s"', instance), 1, true) == nil then  --new instance
        instanceLoadDoc = string.format('%s"%s",0\n', instanceLoadDoc, instance)
        --messageSend('New Instance!', 0x00FF00)
      end
      
      --find the instance load number (important because each load needs to have a unique ID and it should be logical for readability)
      local s,e,eLine
      s, e = string.find(instanceLoadDoc, string.format('"%s",', instance), 1, true)
      eLine = string.find(instanceLoadDoc, '\n', e)-1
      instanceLoadNum = tonumber(string.sub(instanceLoadDoc, e+1, eLine))
      instanceLoadDoc = string.format('%s"%s",%d%s', string.sub(instanceLoadDoc, 1, s-1), instance, instanceLoadNum+1, string.sub(instanceLoadDoc, eLine+1, -1))  --document new instance
      
      addInputLineToQueue()
      addLineToQueue(string.format('Insert Load, %sLoad%d\n', instance, instanceLoadNum))
      writeWholeQueueToFile()
    end
    
    displayFile()
  elseif inputCall == 2 and isNowLoading then  --don't process input data until a load ends
    isNowLoading = getLoadInfo()
    instance = ReadValueString(0x80D20F04, 99)
    if lastInstance ~= instance and exportType == 2 then
      lastInstance = instance
      if string.find(instance, '%d%d%-%d%d') ~= nil and instance ~= '01-40' then  --new instance is a level and not the title screen
        if isInMainFile then
        --create read file
          --finish this file
          isInMainFile = false
          writeWholeQueueToFile()
          
          --reset some defaults
          fileLineCount = 0
          scriptFirstFrame = GetFrameCount()
          thisLineStartF = scriptFirstFrame
          lastFrame = scriptFirstFrame
          tilt = 512
          currTilt = 512
          
          --set up new file
          local fileNameString = writeFileDirectory .. instance
          local n = 0
          while io.open(string.format('%s.tas',fileNameString)) ~= nil do  --don't overwrite preexisting files, in the case of multiple visits
            n = n + 1
            fileNameString = string.format('%s (%.0f)', writeFileDirectory .. instance, n)
          end
          
          outputFile:write(string.format('Read, %s.tas\n', string.sub(fileNameString, #writeFileDirectory+1)))  --this always happens in a load so don't add an extra line for no reason
          outputFile:close()

          local newFileName = string.format('%s.tas',fileNameString)
          messageSend(string.format('Exporting inputs to: %s%s', writeFileDirectory, newFileName), 0xD2691E)
          outputFile = io.open(newFileName, "w+")
          outputFile:write(string.format('#RNG: 0x%X\n\n#Start %s', ReadValue32(core.rng.addr), instance))  --set up export file header
        else
          messageSend("If you're seeing this, it means I did something wrong.", 0xFF0000)
        end
      elseif isInMainFile == false then  --level being read has ended (going into world map, intro stuff)
      --return to main file
        --finish this file
        isInMainFile = true
        writeWholeQueueToFile()
        
        --reset some defaults
        fileLineCount = 0
        scriptFirstFrame = GetFrameCount()
        thisLineStartF = scriptFirstFrame
        lastFrame = scriptFirstFrame
        tilt = 512
        currTilt = 512
        
        outputFile:close()
        outputFile = io.open(writeFileDirectory .. '0 - Fullgame File.tas', "a+")
      end
    end
    
    if isNowLoading == false then
      messageSend('Now Exporting Inputs.', 0x00FF00)
      fileLineCount = 0
      scriptFirstFrame = GetFrameCount()+2
      thisLineStartF = scriptFirstFrame
      lastFrame = GetFrameCount()
      
      data = ReadValue16(dataaddr)
      lastData = data
      tilt = 512
      currTilt = 512
      inputLineNumber = 1
    else
      messageSend('Waiting for load to end...', 0xD2691E)
    end
  end
end

function addInputLineToQueue()  --add the ongoing input line to the queue
  if GetFrameCount()-thisLineStartF < 1 then return end  --don't record bad input lines (old savestate loaded, tilt command in some situations)
  local lineText = string.format('%4.0f%s', GetFrameCount()-thisLineStartF, convertInputsToLine(lastData))
  table.insert(writeQueue, lineText)
  --messageSend(string.format('Line Recorded: "%s"', lineText), 0xD2691E)
  pushInputList()
  inputLineNumber = inputLineNumber + 1
  thisLineStartF = GetFrameCount()
end

function addLineToQueue(lineText)  --adds a line to the queue. Will appear before the currently recording input line
  table.insert(writeQueue, lineText)
  --messageSend(string.format('Line Recorded: "%s"', lineText), 0xD2691E)
end

function messageSend(messageText, color)
  local disPosY = messageNum*15+14
  messageNum = messageNum+1
  RenderText(messageText, 500, disPosY, color, 11)
end

function displayFile()
  RenderText('Currently Exporting Lines:', 10, 59, 0xD2691E, 11)
  local i = 1
  while i <= #writeQueue do
    RenderText(writeQueue[i], 10, i*15+59, 0xD2691E, 11)
    i = i + 1
  end
end

function pushInputList()  --remove lines that we don't need to keep track of anymore
  while inputLineNumber > 3 do  --must be able to manipulate past 3 input lines for spinput automation
    local removedLine = table.remove(writeQueue, 1)
    if tonumber(string.sub(removedLine,1,4)) ~= nil then  --ensure that we always have 5 input lines left (ignore commands)
      inputLineNumber = inputLineNumber - 1
    end
    writeLineToFile(removedLine)
    --messageSend(string.format('Removed Line: "%s"', removedLine), 0x00FF00)
  end
end

function writeLineToFile(lineText)
  fileLineCount = fileLineCount + 1
  outputFile:write('\n', lineText)
end

function writeWholeQueueToFile()
  local i = 1
  while i <= #writeQueue do
    writeLineToFile(writeQueue[i])
    i = i + 1
  end
  writeQueue = {}
end

function addSpinput()
  addInputLineToQueue()  --TODO: don't do this. Currently adds ongoing input line to the queue to make the loop work correctly
  local targetFrameCount = 3
  --local searchFrameCount = 0
  local searchFrameProgress = 0
  local inverseLineCount = 0
  local frames = 0
  
  while true do  --find the line that the spinput started on
    frames = tonumber(string.sub(writeQueue[#writeQueue-inverseLineCount], 1, 4))
    if frames ~= nil then  --if current line is an input line
      if searchFrameProgress+frames >= targetFrameCount then  --spinput happened during this line
        break
      else  --need to go back another line
        searchFrameProgress = searchFrameProgress + frames
      end
    end
    inverseLineCount = inverseLineCount+1
    if #writeQueue-inverseLineCount == 0 then  --failsafe
      messageSend('Error! End of documented inputs reached without spinput start frame found! Aborting!', 0xFF0000)
      return
    end
  end
  --messageSend(string.format('Spin happened during this line: "%s"', writeQueue[#writeQueue-inverseLineCount]), 0x00FF00)
  local lineToReplace = writeQueue[#writeQueue-inverseLineCount]
  local existingLineInputs = ''
  if string.find(lineToReplace, ',') ~= nil then
    _, _, existingLineInputs = string.find(lineToReplace, '%s*%d*(,.*)')
  end
  local spinFrames = targetFrameCount - searchFrameProgress
  local preSpinFrames = frames - spinFrames
  writeQueue[#writeQueue-inverseLineCount] = string.format('%4.0f%s,X', spinFrames, existingLineInputs)
  if preSpinFrames ~= 0 then  --don't add a 0f line if spin started the same frame as the line
    table.insert(writeQueue, #writeQueue-inverseLineCount, string.format('%4.0f%s', preSpinFrames, existingLineInputs))
    inputLineNumber = inputLineNumber + 1
  end
end