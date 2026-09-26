local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod

local LEVER = hash("StructureLogicSwitch")
local DOORS = hash("StructureGlassDoor")

local INNER = 0
local OUTER = 1

-- Initial door configuration
ic.batch_write(DOORS, LT.Mode, 1)
ic.batch_write(DOORS, LT.Lock, 0)

while true do

    -- Check override lever
    local lever = ic.batch_read(LEVER, LT.Setting, LBM.Maximum)

    if lever ~= 1 then

        -- Read current door states
        local innerOpen    = ic.read(INNER, LT.Open)
        local outerOpen    = ic.read(OUTER, LT.Open)

        -- Read desired/settings states
        local innerSetting = ic.read(INNER, LT.Setting)
        local outerSetting = ic.read(OUTER, LT.Setting)

        -- Has either door's state changed from its setting?
        local innerChanged = innerOpen ~= innerSetting
        local outerChanged = outerOpen ~= outerSetting

        if innerChanged or outerChanged then

            -- If inner door is open, cycle OUT.
            -- Otherwise cycle IN.
            if innerOpen ~= 0 then

                -- OUTER cycle
                ic.batch_write(DOORS, LT.Lock, 1)

                ic.write(INNER, LT.Open, 0)
                sleep(0.5)

                while ic.read(INNER, LT.Idle) == 0 do
                    sleep(0.5)
                end

                ic.write(OUTER, LT.Open, 1)
                sleep(0.5)

                while ic.read(OUTER, LT.Idle) == 0 do
                    sleep(0.5)
                end

                ic.batch_write(DOORS, LT.Lock, 0)

            else

                -- INNER cycle
                ic.batch_write(DOORS, LT.Lock, 1)

                ic.write(OUTER, LT.Open, 0)
                sleep(0.5)

                while ic.read(OUTER, LT.Idle) == 0 do
                    sleep(0.5)
                end

                ic.write(INNER, LT.Open, 1)
                sleep(0.5)

                while ic.read(INNER, LT.Idle) == 0 do
                    sleep(0.5)
                end

                ic.batch_write(DOORS, LT.Lock, 0)
            end
        end
    end

    -- Override
    if lever == 1 then

        ic.batch_write(DOORS, LT.Mode, 0)
        ic.batch_write(DOORS, LT.Open, 1)

        -- Wait for lever to be switched off
        while ic.batch_read(LEVER, LT.Setting, LBM.Maximum) ~= 0 do
            sleep(0.5)
        end

        ic.batch_write(DOORS, LT.Mode, 1)

        ic.write(INNER, LT.Open, 0)
        ic.write(INNER, LT.Setting, 0)

        ic.write(OUTER, LT.Open, 1)
        ic.write(OUTER, LT.Setting, 1)
    end

    sleep(0.5)
end