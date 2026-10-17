local LogicType = ic.enums.LogicType

local soundQueue = {}
local currentSound = nil
local soundTimer = 0

local function playSound(sound, length)
    ic.batch_write(hash("StructureKlaxon"), LogicType.On, sound > 0 and 1 or 0)
    ic.batch_write(hash("StructureKlaxon"), LogicType.Mode, sound)
    soundTimer = length
end

local function queueSound(sound, length)
    table.insert(soundQueue, {sound = sound, length = length})
end

local function playNextSound()
    if #soundQueue == 0 then
        currentSound = nil soundTimer = 0 playSound(0, 0) return
    end
    currentSound = table.remove(soundQueue, 1)
    playSound(currentSound.sound, currentSound.length)
end

local function updateSounds(deltaTime)
    if currentSound == nil then playNextSound() return end
    soundTimer = soundTimer - deltaTime
    if soundTimer <= 0 then playNextSound() end
end

local function clearSoundQueue()
    soundQueue = {}
    currentSound = nil
    soundTimer = 0
    playSound(0, 0)
end

local function stormWarning()
    queueSound(17, 0.5)
    queueSound(18, 2)
end

local function finalMinute()
    queueSound(17, 0.5)
    queueSound(18, 2)
    queueSound(10, 2.5)
end

local function finalCountdown()
    queueSound(33, 1)
    queueSound(32, 1)
    queueSound(31, 1)
    queueSound(30, 1)
    queueSound(29, 1)
end

function tick(deltaTime)
    updateSounds(deltaTime)
end