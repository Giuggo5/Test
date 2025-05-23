--[[
    Ultimate Private Server Checker
    - Checks TeleportService, JobId, VIP status, player count, and more
    - Works on most executors (Synapse, Krnl, etc.)
]]

local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local function isPrivateServer()
    local checks = {
        TeleportServiceCheck = false,
        JobIdCheck = false,
        VIPOwnerCheck = false,
        LowPlayerCountCheck = false,
    }
    local results = {}

    -- === Method 1: TeleportService (Most Reliable) ===
    local success, serverId = pcall(function()
        return TeleportService:GetServerId()
    end)
    if success and serverId and serverId ~= "" then
        checks.TeleportServiceCheck = true
    end

    -- === Method 2: Private Server Owner ID ===
    local success, ownerId = pcall(function()
        return TeleportService:GetPrivateServerOwnerId()
    end)
    if success and ownerId and ownerId ~= 0 then
        checks.VIPOwnerCheck = true
    end

    -- === Method 3: JobId Pattern Check ===
    local jobId = game.JobId or ""
    if jobId:find("private") or #jobId > 20 then -- Private servers often have longer JobIds
        checks.JobIdCheck = true
    end

    -- === Method 4: Player Count Check (Less Reliable) ===
    if #Players:GetPlayers() < 8 then -- Adjust threshold based on game
        checks.LowPlayerCountCheck = true
    end

    -- === Method 5: VIP Server GamePass Check (If Applicable) ===
    -- Only works if the game has VIP servers
    local isVIPPossible = false
    local success, hasVIP = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(ownerId or 0, game.GamePassId or 0)
    end)
    if success and hasVIP then
        checks.VIPOwnerCheck = true
        isVIPPossible = true
    end

    -- === Determine Final Result ===
    local isPrivate = (
        checks.TeleportServiceCheck or
        checks.VIPOwnerCheck or
        (checks.JobIdCheck and checks.LowPlayerCountCheck) -- Only if both conditions suggest private
    )

    -- === Build Results Table ===
    results.IsPrivateServer = isPrivate
    results.Checks = checks
    results.Details = {
        ServerId = serverId,
        PrivateServerOwnerId = ownerId,
        JobId = jobId,
        PlayerCount = #Players:GetPlayers(),
        IsVIPPossible = isVIPPossible,
    }

    return results
end

-- === Run the Check & Display Results ===
local results = isPrivateServer()

print("=== Private Server Detection Results ===")
print(`Is Private Server: {results.IsPrivateServer}`)
print("\n--- Check Results ---")
for checkName, checkResult in pairs(results.Checks) do
    print(`{checkName}: {checkResult}`)
end
print("\n--- Details ---")
for detailName, detailValue in pairs(results.Details) do
    print(`{detailName}: {detailValue}`)
end

-- === Optional: Notify Player ===
if results.IsPrivateServer then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Server Check",
        Text = "This is a PRIVATE server!",
        Duration = 10,
    })
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Server Check",
        Text = "This is a PUBLIC server.",
        Duration = 10,
    })
end
