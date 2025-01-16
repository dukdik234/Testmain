repeat task.wait() until game:IsLoaded() or game.Players.LocalPlayer

getgenv().Version = 1.1


getgenv().Setting = {
    Unit_Equip = {},
    Select_tabs = {},
    Auto_Play = false,
    Show_unitplacement = false,
    Place_any = false
}
local Ply = game.Players.LocalPlayer
local Rep = game:GetService("ReplicatedStorage")
local Runs = game:GetService("RunService")
local Guis = Ply:FindFirstChild("PlayerGui")
local Loads = require(Rep.src.Loader)
local Cilent_Datas = Loads.load_client_service(script, "ItemInventoryServiceClient")
local Allunits = require(Rep.src.Data.Units)

function Getunit_Selecttion()
    getgenv().Setting.Unit_Equip = {}
    for _,allunit in pairs(Allunits) do
        for unit_uuid, unit_data in pairs(Cilent_Datas["session"]["collection"]["collection_profile_data"]["owned_units"]) do
            for slot, equipped_uuid in pairs(Cilent_Datas["session"]["collection"]["collection_profile_data"]["equipped_units"]) do
                if unit_uuid == equipped_uuid then
                    local unitid = unit_data["unit_id"]
                    if allunit['id'] == unitid then
                        
                        local unittype = allunit['farm_amount'] ~= nil and "Farm" or "Attacker"
                        print("Unit :", unitid,"Slots : ",slot, "Uuid : ",equipped_uuid,"UnitType : ", unittype)
                        table.insert(getgenv().Setting.Unit_Equip, { Tabs = slot, uuid = equipped_uuid, Type = unittype ,Spawncap = allunit['spawn_cap'],Cost = allunit['cost'],Upgrade = allunit['upgrade']})
                        
                    end
                end
            end
        end
    end
end
task.spawn(function()  
    if workspace._MAP_CONFIG.IsLobby.Value == true then
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        Getunit_Selecttion()
    else
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        repeat task.wait() until workspace._DATA.VoteStart.VotingFinished.Value == true
        repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
        Getunit_Selecttion()
    end
end)
--[[
    for _,v in pairs(getgenv().Setting.Unit_Equip) do
        if type(v) == 'table' then
            for _,v2 in pairs(v) do
                print(_,v2)
            end
        end
    end
]]


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dukdik234/SaveUi/refs/heads/main/Save_Ui.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dukdik234/SaveUi/refs/heads/main/Interface.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Xsalary " .. " " .. tonumber(getgenv().Version),
    SubTitle = "By Oxegen",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl 
})
local Options = Fluent.Options

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


local Dropdown = Tabs.Main:AddDropdown("Unit_Tabs", {
    Title = "Select Units",
    Values = {'1','2','3','4','5','6'},
    Multi = true,
    Default = {'1','2','3','4'},
})
Dropdown:SetValue({
   ['1'] = true,
   ['2'] = true,
   ['3'] = true,
   ['4'] = true
})

Dropdown:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        table.insert(Values, Value)
    end
    getgenv().Setting.Select_tabs = Values
    Getunit_Selecttion()
end)

local Toggle = Tabs.Main:AddToggle("autoplay", {Title = "Strat Farm", Default = false })
Toggle:OnChanged(function()
    getgenv().Setting.Auto_Play = Options.autoplay.Value
end)
local Toggle2 = Tabs.Main:AddToggle("showplacement", {Title = "Show Unit Placement", Default = false })
Toggle2:OnChanged(function()
    getgenv().Setting.Show_unitplacement = Options.showplacement.Value
    task.spawn(function()
        if Options.showplacement.Value then
            print(1)
            for _, partTemplate in pairs(workspace:GetChildren()) do
                if partTemplate.Name == "PathPart" or partTemplate.Name == "FarmTem" then 
                    partTemplate.Transparency = 0
                end
            end
        else
            for _, partTemplate in pairs(workspace:GetChildren()) do
                if partTemplate.Name == "PathPart" or partTemplate.Name == "FarmTem" then 
                    partTemplate.Transparency = 1
                end
            end
        end
    end)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)


SaveManager:IgnoreThemeSettings()


SaveManager:SetIgnoreIndexes({})


InterfaceManager:SetFolder("Xasalary")
SaveManager:SetFolder("Xasalary/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Xasalary",
    Content = "The script has been loaded.",
    Duration = 8
})


local services = require(game.ReplicatedStorage.src.Loader)
local placement_service = services.load_client_service(script, "PlacementServiceClient")

task.spawn(function()
    pcall(function()
        while task.wait() do
            if getgenv().Setting.Place_any then
                placement_service.can_place = true
            end
        end
    end)
end)

local function Create_Templatepart()
    local enemyPath = workspace._BASES.pve.LANES["1"]
    if not enemyPath then
        return
    end

   
    local spawnPart = enemyPath:FindFirstChild("spawn")
    local finalPart = enemyPath:FindFirstChild("final")
    if not spawnPart or not finalPart then
        return
    end


    local partsInPath = {spawnPart}
    for i = 1, #workspace._BASES.pve.LANES["1"]:GetChildren() do
        local part = enemyPath:FindFirstChild(tostring(i))
        if part then
            table.insert(partsInPath, part)
        end
    end
    table.insert(partsInPath, finalPart)

    if #partsInPath < 2 then
        return
    end

   
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "PathPart" then
            child:Destroy()
        end
    end


    local Psize = Vector3.new(2, 2, 2)
    local VERTICAL_OFFSET = .4
    local PATH_WIDTH = 2
    local MIN_SPACING = 3
    

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    local roadParts = {}
    for _, part in ipairs(workspace._road:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(roadParts, part)
        end
    end
    raycastParams.FilterDescendantsInstances = roadParts

    local groundRaycastParams = RaycastParams.new()
    groundRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    groundRaycastParams.FilterDescendantsInstances = {workspace._BASES}

    local function isOverlappingRoad(position)
      
        local rayOrigin = position + Vector3.new(0, 10, 0)
        local rayDirection = Vector3.new(0, -20, 0)
        
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        return raycastResult ~= nil
    end
    local function hasGroundBeneath(position)
        local rayOrigin = position
        local rayDirection = Vector3.new(0, -3, 0) 
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, groundRaycastParams)
        return raycastResult ~= nil
    end

    
    local function isTooClose(position, existingParts)
        for _, part in ipairs(existingParts) do
            local distance = (position - part.Position).Magnitude
            if distance < MIN_SPACING then
                return true
            end
        end
        return false
    end

    local allCreatedParts = {}
    local partsToValidate = {}
    for i = 1, #partsInPath - 1 do
        local currentPart = partsInPath[i]
        local nextPart = partsInPath[i + 1]

        local startPos = currentPart.Name == "spawn" 
            and currentPart.Position + Vector3.new(0, 0, -6) 
            or currentPart.Position
        local endPos = nextPart.Position
        local pathVector = (endPos - startPos)
        local distance = pathVector.Magnitude
        local direction = pathVector.Unit

        local rightVector = direction:Cross(Vector3.new(0, 1, 0)).Unit
        local leftVector = -rightVector

        local optimalSpacing = math.max(MIN_SPACING, distance / math.floor(distance / MIN_SPACING))
        local numParts = math.floor(distance / optimalSpacing)

        for j = 0, numParts - 1 do
            local t = j / numParts
            local pathPos = startPos + direction * (t * distance)
            pathPos = pathPos + Vector3.new(0, VERTICAL_OFFSET, 0)

            local leftPos = pathPos + leftVector * PATH_WIDTH
            if not isTooClose(leftPos, allCreatedParts) then
                local leftPathPart = Instance.new("Part")
                leftPathPart.Name = "PathPart"
                leftPathPart.Size = Psize
                leftPathPart.Anchored = true
                leftPathPart.CanCollide = false
                leftPathPart.Transparency = 1
                leftPathPart.Color = Color3.fromRGB(100, 200, 255)
                leftPathPart.Position = leftPos
                leftPathPart.CFrame = CFrame.lookAt(leftPos, endPos + Vector3.new(0, VERTICAL_OFFSET, 0))
                leftPathPart.Parent = workspace
                table.insert(allCreatedParts, leftPathPart)
                table.insert(partsToValidate, leftPathPart)
            end

            local rightPos = pathPos + rightVector * PATH_WIDTH
            if not isTooClose(rightPos, allCreatedParts) then
                local rightPathPart = Instance.new("Part")
                rightPathPart.Name = "PathPart"
                rightPathPart.Size = Psize
                rightPathPart.Anchored = true
                rightPathPart.CanCollide = false
                rightPathPart.Transparency = 1
                rightPathPart.Color = Color3.fromRGB(100, 200, 255)
                rightPathPart.Position = rightPos
                rightPathPart.CFrame = CFrame.lookAt(rightPos, endPos + Vector3.new(0, VERTICAL_OFFSET, 0)) -- ใช้ rightPos
                rightPathPart.Parent = workspace
                table.insert(allCreatedParts, rightPathPart)
                table.insert(partsToValidate, rightPathPart)
            end
        end
    end
    for _, part in ipairs(partsToValidate) do
        if not hasGroundBeneath(part.Position) then
            part:Destroy()
        end
    end
end
local function Create_FarmTemplate()
    local Path = workspace._terrain.ground
    if not Path then
        return
    end

    local maxDistance = 0
    local farthestPart = nil

    local allParts = {}

    for _, paths in pairs(Path:GetDescendants()) do
        if paths and not paths:IsA("Texture") and not paths:IsA("Model") then
            table.insert(allParts, paths)
        end
    end

    for i = 1, #allParts do
        local currentPart = allParts[i]

        for j = i + 1, #allParts do
            local nextPart = allParts[j]
            local distance = (currentPart.Position - nextPart.Position).Magnitude

            if distance > maxDistance then
                maxDistance = distance
                farthestPart = nextPart
            end
        end
    end

    if not farthestPart then
        return
    end

    local PLATE_SIZE = Vector3.new(2, 2, 2)
    local GRID_SIZE = 5
    local SPACING = 4
    local TEMPLATE_HEIGHT = 5
    local MAX_HEIGHT_DIFF = 1.5
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name == "FarmTem" then
            child:Destroy()
        end
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {workspace._terrain.terrain}

    local centerPos = farthestPart.Position
    local offset = math.floor(GRID_SIZE / 2)

    for x = -offset, offset do
        for z = -offset, offset do
            local posX = centerPos.X + (x * (PLATE_SIZE.X + SPACING))
            local posZ = centerPos.Z + (z * (PLATE_SIZE.Z + SPACING))
            local position = Vector3.new(posX, centerPos.Y + TEMPLATE_HEIGHT, posZ)

            local rayOrigin = position + Vector3.new(0, 10, 0) 
            local rayDirection = Vector3.new(0, -20, 0)
            local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

            if rayResult 
                then 

                local distanceToGround = position.Y - rayResult.Position.Y

 
                if distanceToGround > MAX_HEIGHT_DIFF then
                   
                    position = Vector3.new(position.X, rayResult.Position.Y, position.Z)
                end
            end

            local templatePart = Instance.new("Part")
            templatePart.Name = "FarmTem"
            templatePart.Size = PLATE_SIZE
            templatePart.Position = position
            templatePart.Anchored = true
            templatePart.CanCollide = false
            templatePart.Color = Color3.new(0.392157, 1.000000, 0.623529)
            templatePart.Transparency = 1
            templatePart.Parent = workspace
        end
    end
end





local function FindBestPosition()
    local UnitsFolder = workspace._UNITS
    local Ways = workspace._BASES.pve.LANES["1"]
    local closestPart = nil
    local closestEnemy = nil
    local bestDistance = math.huge

    local hasEnemies = false
    local function IsPositionOccupied(position, radius)
        radius = radius or 2 
        
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            if unit:IsA("Model") and unit:FindFirstChild("HumanoidRootPart") and unit:FindFirstChild("_stats") and  
                unit:FindFirstChild("_hitbox") then

                local distance = (unit.HumanoidRootPart.Position - position).Magnitude
                if distance < radius then
                    return true 
                end
            end
        end
        
        return false 
    end
    for _, enemy in pairs(UnitsFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("_stats") and enemy:FindFirstChild("HumanoidRootPart") then
            local enemyStats = enemy._stats
            if not enemyStats.player.Value or enemyStats.player.Value == "" then
                hasEnemies = true
                local nextBend = enemyStats:FindFirstChild("next_bend")
                if nextBend then
                    local bendPart = Ways:FindFirstChild(tostring(nextBend.Value))
                    if bendPart then
                        local enemyToBendDist = (enemy.HumanoidRootPart.Position - bendPart.Position).Magnitude
                        if not closestEnemy or enemyToBendDist > bestDistance then
                            closestEnemy = enemy
                            closestPart = bendPart
                            bestDistance = enemyToBendDist
                        end
                    end
                end
            end
        end
    end

    if not hasEnemies then
        local defaultPosition = Ways:FindFirstChild("1")
        if defaultPosition then
            closestPart = defaultPosition
        end
    else
        if closestEnemy then
            for _, partTemplate in pairs(workspace:GetChildren()) do
                if partTemplate.Name == "PathPart" and 
                    not IsPositionOccupied(partTemplate.Position)  then
                    local partToEnemyDist = (closestEnemy.HumanoidRootPart.Position - partTemplate.Position).Magnitude
                    if partToEnemyDist < bestDistance then
                        bestDistance = partToEnemyDist
                        closestPart = partTemplate
                    end
                end
            end
        end
    end

    
    return closestPart
end
local function FindBestfamrpos()
    local Farmtarget = nil
    local farmTemplates = {}
    local UnitsFolder = workspace._UNITS
    
    local function IsPositionOccupied(position, radius)
        radius = radius or 2 
        
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            if unit:IsA("Model") and unit:FindFirstChild("HumanoidRootPart") and unit:FindFirstChild("_stats") and  
                unit:FindFirstChild("_hitbox") then

                local distance = (unit.HumanoidRootPart.Position - position).Magnitude
                if distance < radius then
                    return true 
                end
            end
        end
        
        return false 
    end
    for _, farmtemplate in pairs(workspace:GetChildren()) do
        if farmtemplate.Name == "FarmTem" then
            if not IsPositionOccupied(farmtemplate.Position) then
                table.insert(farmTemplates, farmtemplate)
            end
        end
    end

    if #farmTemplates > 0 then
        Farmtarget = farmTemplates[math.random(1, #farmTemplates)]
      
    end
    return Farmtarget
end
local UnitStack = {}
local function Check_Eror(Mas)
    local connection
    connection = Guis.MessageGui.messages.ChildAdded:Connect(function(child)
        pcall(function()
            if child.Name == "Error" and child:FindFirstChild("Tex") and tostring(child.Tex.Text) == Mas then
                child:Destroy()
                task.wait(0.5)
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)
end
local function Upgrade(unit_id, upgrade_value, My_cost, unit_type)
    local UnitsFolder = workspace._UNITS
    local farm_priority  = 1.2
    local units_to_upgrade = {}
    
   
    local function calculateUpgradePriority(unit, currentLevel, upgradeCost)
        local score = 0
        

        if unit_type == "Farm" then
            score = 1000 - currentLevel * 100  
            if tonumber(My_cost) >= upgradeCost * farm_priority then
                score = score + 2000
            end
        else
    
            score = 500 - currentLevel * 50
        end
        

        score = score - (upgradeCost / 1000)
        
        return score
    end
    

    for _, unit in ipairs(UnitsFolder:GetChildren()) do
        if unit:FindFirstChild("_stats") and unit:FindFirstChild("_hitbox") then
            local unitStats = unit._stats
            if unitStats:FindFirstChild("player") and 
               tostring(unitStats.player.Value) == Ply.Name and 
               tostring(unitStats.uuid.Value) == unit_id then
                

                local currentLevel = 0
                if unitStats:FindFirstChild("upgrade") and tonumber(unitStats.upgrade.Value) then
                    if tonumber(unitStats.upgrade.Value) == 0 then
                        currentLevel = 1
                    else 
                        currentLevel = tonumber(unitStats.upgrade.Value)
                    end
                end
                
                if currentLevel < tonumber(#upgrade_value) then
                    local upgradeCost = tonumber(upgrade_value[currentLevel]['cost'])
                    
                   
                    local priority = calculateUpgradePriority(unit, currentLevel, upgradeCost)
                    

                    if unit_type == "Farm" then
                       
                        if tonumber(My_cost) >= upgradeCost * farm_priority then
                            table.insert(units_to_upgrade, {
                                unit = unit,
                                priority = priority,
                                cost = upgradeCost
                            })
                        end
                    else
                       
                        if tonumber(My_cost) >= upgradeCost then
                            table.insert(units_to_upgrade, {
                                unit = unit,
                                priority = priority,
                                cost = upgradeCost
                            })
                        end
                    end
                end
            end
        end
    end
    

    table.sort(units_to_upgrade, function(a, b)
        return a.priority > b.priority
    end)
    

    for _, upgrade_data in ipairs(units_to_upgrade) do
        if tonumber(My_cost) >= upgrade_data.cost then
            game:GetService("ReplicatedStorage"):WaitForChild("endpoints")
                .client_to_server
                .upgrade_unit_ingame:InvokeServer(upgrade_data.unit)
            
        end
    end
    
    return upgradeCount
end
local function Smart_Place(Type, uuid, maxcount, cost, upgrade)
    local UnitsFolder = workspace._UNITS
    local Wave = workspace._wave_num.Value
    local Money = tonumber(Guis.spawn_units.Lives.Frame.Resource.Money.text.Text)
    local Ways = workspace._BASES.pve.LANES["1"]
    local Is_next = "1" 
    local Dangerous = false
    local MIN_SAFE_DISTANCE = 15
    

    local function isDangerousWave()
        if workspace._is_last_wave.Value or workspace._is_last_wave.Value == true then return true end
        if Wave >= 10 and Is_next == "final" then return true end
        return (Wave == 2 or Wave == 3) and (tonumber(Is_next) >= 8 or Is_next == "final")
    end


    local function getDistanceToFinal(unit)
        local finalPart = Ways:FindFirstChild("final")
        if finalPart and unit:FindFirstChild("HumanoidRootPart") then
            return (unit.HumanoidRootPart.Position - finalPart.Position).magnitude
        end
        return math.huge
    end


    local function findUnitToSell()
        local unitToSell
        local worstScore = -math.huge
        
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            if unit:FindFirstChild("_stats") and unit:FindFirstChild("_hitbox") then
                local stats = unit._stats
                if stats:FindFirstChild("player") and 
                   tostring(stats.player.Value) == Ply.Name and
                   tostring(stats.uuid.Value) == uuid then
                    
                   
                    local distanceToFinal = getDistanceToFinal(unit)
                    local upgradeLvl = stats:FindFirstChild("upgrade") and stats.upgrade.Value or 0
                    local dmg = stats:FindFirstChild("base_damage") and stats.base_damage.Value or 0
                    

                    local score = distanceToFinal * 0.5 
                               
                    
                    if score > worstScore then
                        worstScore = score
                        unitToSell = unit
                    end
                end
            end
        end
        return unitToSell
    end

    local function updateGameState()
        UnitStack = {}
        local closestEnemy
        local bestDistance = math.huge

        for _, unit in pairs(UnitsFolder:GetChildren()) do
            if unit:FindFirstChild("_stats") then
                local stats = unit._stats
                
               
                if stats:FindFirstChild("player") and 
                   tostring(stats.player.Value) == Ply.Name and stats:FindFirstChild("uuid") then
                    local unitId = tostring(stats.uuid.Value)
                    UnitStack[unitId] = (UnitStack[unitId] or 0) + 1
                elseif stats:FindFirstChild("player") and 
                       (not stats.player.Value or stats.player.Value == "") then
                    local nextBend = stats:FindFirstChild("next_bend")
                    if nextBend and unit:FindFirstChild("HumanoidRootPart") then
                        local bendPart = Ways:FindFirstChild(tostring(nextBend.Value))
                        if bendPart then
                            local dist = (unit.HumanoidRootPart.Position - bendPart.Position).Magnitude
                            if not closestEnemy or dist < bestDistance then
                                closestEnemy = unit
                                bestDistance = dist
                                Is_next = tostring(nextBend.Value)
                            end
                        end
                    end
                end
            end
        end
        
        Dangerous = isDangerousWave()
        
        return closestEnemy
    end

    local function PlaceUnit(position)
        if position then
            --task.spawn(Check_Eror,"Cannot place unit here!")
            local args = {
                [1] = tostring(uuid),
                [2] = CFrame.new(position.Position)
            }
            game:GetService("ReplicatedStorage")
            :WaitForChild("endpoints")
            .client_to_server
            .spawn_unit
            :InvokeServer(unpack(args))
        end
    end
    local function shouldPlaceUnit()
       
        if Money < cost then return false end
        
      
        if UnitStack[uuid] and UnitStack[uuid] >= maxcount then return false end
        

        if Type == "Farm" then
            return Wave >= 2 and not Dangerous
        end
        
        
        if Type == "Attacker" then
           
            return true
        end
        
        return false
    end


    local closestEnemy = updateGameState()
    
  
    task.spawn(function()
        
        pcall(function()
            Upgrade(uuid, upgrade, Money, Type)
        end)
        
    end)
    

    if shouldPlaceUnit() then
        task.spawn(function()
            local position = Type == "Farm" and FindBestfamrpos() or FindBestPosition()
            if position then
                PlaceUnit(position)
            end
        end)

    end
    
    if Dangerous and Type == "Attacker" and UnitStack[uuid] and UnitStack[uuid] >= maxcount then
        task.spawn(function()
            local unitToSell = findUnitToSell()
            if unitToSell then
                game:GetService("ReplicatedStorage"):WaitForChild("endpoints")
                .client_to_server
                .sell_unit_ingame:InvokeServer(unitToSell)
            end
        end)
    end
    if workspace._is_last_wave.Value or workspace._is_last_wave.Value == true then
        local worstScore = -math.huge
        
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            if unit:FindFirstChild("_stats") and unit:FindFirstChild("_hitbox") then
                local stats = unit._stats
                if stats:FindFirstChild("player") and stats:FindFirstChild("uuid") and
                   tostring(stats.player.Value) == Ply.Name and
                   Type == "Farm" and
                   tostring(stats.uuid.Value) == uuid then
                    
                        game:GetService("ReplicatedStorage"):WaitForChild("endpoints")
                        .client_to_server
                        .sell_unit_ingame:InvokeServer(unit)
                end
            end
        end
    end 
end
task.spawn(function()
    --pcall(function()
        while task.wait() do
            if getgenv().Setting.Auto_Play and workspace._waves_started.Value == true then
                if not workspace._MAP_CONFIG.IsLobby.Value then
                    if not workspace:FindFirstChild("PathPart") then
                        Create_Templatepart()
                    end
                    if not workspace:FindFirstChild("FarmTem") then
                        Create_FarmTemplate()
                    end
                end
                task.spawn(function()
                    if 
                    not getgenv().Setting.Place_any then
                        getgenv().Setting.Place_any = true
                    end 
                    Guis.MessageGui.messages.Visible = false
                end)
                for _, Select in pairs(getgenv().Setting.Select_tabs) do
                    if Select and getgenv().Setting.Unit_Equip then
                        for _, Unit in pairs(getgenv().Setting.Unit_Equip) do
                            if tonumber(Unit["Tabs"]) == tonumber(Select) then
                                Smart_Place(Unit["Type"],  Unit["uuid"],Unit["Spawncap"],Unit["Cost"],Unit["Upgrade"])
                            end
                        end
                    end
                end
            end
        end
    --end)
end)

--[[
local args = {
    [1] = workspace:WaitForChild("_UNITS"):WaitForChild("dio")
}

game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("upgrade_unit_ingame"):InvokeServer(unpack(args))
]]
--[[
    local args = {
    [1] = "{269f004e-5d45-4b74-9c71-abce441e4a27}",
    [2] = CFrame.new(-2951.002685546875, 91.80620574951172, -712.8732299804688, 1, 0, -0, -0, 1, -0, 0, 0, 1)
}

game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("spawn_unit"):InvokeServer(unpack(args))

]]
