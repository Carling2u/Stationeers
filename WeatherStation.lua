local WEATHER_STATION   = hash("StructureWeatherStation")
local WARNING_LIGHT     = hash("StructureFlashingLight")
local DISPLAY           = hash("StructureConsoleLED1x2Side")
local DISPLAY_NAME      = hash("[WEATHERWARN] LED Display")
local TRANSMITTER       = hash("StructureLogicTransmitter")
local SLEEP_TIME        = 10 -- Time to sleep per tick during no storm

-- Do not edit past this point.
local LogicType = ic.enums.LogicType
local BatchMethod = ic.enums.LogicBatchMethod
local soundQueue = {}
local currentSound = nil
local lastMode = nil
local soundTimer = 0
local lastTime = -1

local function playSound(sound, length)
    ic.batch_write(TRANSMITTER, LogicType.SoundAlert, sound)
    soundTimer = length
end

local function queueSound(sound, length)
    table.insert(soundQueue, {sound = sound, length = length})
end

local function playNextSound()
    if #soundQueue == 0 then currentSound = nil soundTimer = 0 playSound(0, 0) return end
    currentSound = table.remove(soundQueue, 1)
    playSound(currentSound.sound, currentSound.length)
end

local function updateSounds(deltaTime)
    if currentSound == nil then playNextSound() return end
    soundTimer = soundTimer - deltaTime
    if soundTimer <= 0 then playNextSound() end
end

local function clearSoundQueue()
    soundQueue = {} currentSound = nil soundTimer = 0 playSound(0, 0)
end

local function stormWarning()
    queueSound(17, 0.5) queueSound(18, 2) end

local function finalMinute()
    queueSound(17, 0.5) queueSound(18, 2) queueSound(10, 3) end

local function finalCountdown()
    queueSound(33, 1) queueSound(32, 1) queueSound(31, 1)
    queueSound(30, 1) queueSound(29, 1) end

local function stormIncomming()
    local time = math.floor(ic.batch_read(WEATHER_STATION, 
        LogicType.NextWeatherEventTime, BatchMethod.Maximum))

    ic.batch_write_name(DISPLAY,DISPLAY_NAME,LogicType.Setting,time)

    if time ~= lastTime then
        if time == 60 then
            finalMinute()
        elseif time % 60 == 0 and time > 0 then
            stormWarning()
        elseif time == 5 then
            finalCountdown()
        end
        lastTime = time
    end
end

function tick(deltaTime)
    local mode = ic.batch_read(WEATHER_STATION, LogicType.Mode, BatchMethod.Maximum)

    if mode ~= lastMode then -- Update flashing light on mode change
        ic.batch_write(WARNING_LIGHT, LogicType.On, mode > 0 and 1 or 0)
    end

    if mode == 0 then
        sleep(SLEEP_TIME)
    elseif mode == 1 then
        updateSounds(deltaTime)
        stormIncomming()
    elseif mode == 2 and mode ~= lastMode then
        ic.batch_write_name(DISPLAY,DISPLAY_NAME,LogicType.Setting,0)
        clearSoundQueue()
        lastTime = -1
    end

    lastMode = mode
end