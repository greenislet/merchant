function Merchant.Print(key, ...)
  str = Merchant.Locales.GetString(key)

  print(format("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. "Merchant: " .. str, ...))
end

--------------------------------------------------------------------------------

function Merchant.Debug(str, ...)
  if Merchant_Vars.Config.DebugMode == false then
  	return
  end
  print(format("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. "Merchant: " .. str, ...))
end

--------------------------------------------------------------------------------

function Merchant.InitCache()
  Merchant.CharName = UnitName("player")
  _, Merchant.CharClass = UnitClass("player")
  Merchant.RealmName = GetNormalizedRealmName()
end

--------------------------------------------------------------------------------

function Merchant.InitSlashCommands()
  SLASH_MERCHANT1 = "/merchant"

  SlashCmdList["MERCHANT"] = function(msg, editbox)
    if msg == "" then
      Merchant.UI.MainFrame:Show()
    end
    if msg == "debug" then
      if Merchant_Vars.Config.DebugMode == false then
        Merchant_Vars.Config.DebugMode = true
        Merchant.Print("DEBUG_MODE_ENABLED")
      else
        Merchant_Vars.Config.DebugMode = false
        Merchant.Print("DEBUG_MODE_DISABLED")
      end
    end
  end
end

--------------------------------------------------------------------------------

function Merchant.InitPersistentVars()
  if type(Merchant_Vars) ~= "table" then
    Merchant_Vars = {}
  end
  if type(Merchant_Vars.AHPrices) ~= "table" then
    Merchant_Vars.AHPrices = {}
  end
  if type(Merchant_Vars.AHPrices[Merchant.RealmName]) ~= "table" then
    Merchant_Vars.AHPrices[Merchant.RealmName] = {}
  end
  if type(Merchant_Vars.LastScanTime) ~= "number" then
    Merchant_Vars.LastScanTime = 0
  end
  if type(Merchant_Vars.Accounts) ~= "table" then
    Merchant_Vars.Accounts = {}
  end
  if type(Merchant_Vars.Accounts[Merchant.RealmName]) ~= "table" then
    Merchant_Vars.Accounts[Merchant.RealmName] = {}
  end
  if type(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) ~= "table" then
    Merchant_Vars.Accounts[Merchant.RealmName].Auctions = {}
  end
  if type(Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.CharName]) ~= "table" then
    Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.CharName] = {}
  end
  if type(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile) ~= "table" then
    Merchant_Vars.Accounts[Merchant.RealmName].Stockpile = {}
  end
  if type(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.CharName]) ~= "table" then
    Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.CharName] = {}
  end
  if type(Merchant_Vars.Characters) ~= "table" then
    Merchant_Vars.Characters = {}
  end
  if type(Merchant_Vars.Characters[Merchant.RealmName]) ~= "table" then
    Merchant_Vars.Characters[Merchant.RealmName] = {}
  end
  Merchant_Vars.Characters[Merchant.RealmName][Merchant.CharName] = {}
  Merchant_Vars.Characters[Merchant.RealmName][Merchant.CharName].Class = Merchant.CharClass
  if type(Merchant_Vars.Minimap) ~= "table" then
    Merchant_Vars.Minimap = {}
  end
  if type(Merchant_Vars.UI) ~= "table" then
    Merchant_Vars.UI = {}
  end
  if type(Merchant_Vars.UI.SelectedTabIdx) ~= "number" then
    Merchant_Vars.UI.SelectedTabIdx = 1
  end
  if type(Merchant_Vars.Config) ~= "table" then
    Merchant_Vars.Config = {}
  end
  if type(Merchant_Vars.Config.TransparentPanel) ~= "boolean" then
    Merchant_Vars.Config.TransparentPanel = false
  end
  if type(Merchant_Vars.Config.DebugMode) ~= "boolean" then
    Merchant_Vars.Config.DebugMode = false
  end
  if type(Merchant_Vars.Config.Autoscan) ~= "boolean" then
    Merchant_Vars.Config.Autoscan = true
  end
end

--------------------------------------------------------------------------------

function Merchant.PrintNextScan()
  nbSec = 15 * 60 - (time() - Merchant_Vars.LastScanTime)
  if nbSec / 60 ~= 0 then
    Merchant.Print("NEXT_SCAN", nbSec / 60, nbSec % 60)
  else
    Merchant.Print("NEXT_SCAN_SECONDS", nbSec)
  end
end

--------------------------------------------------------------------------------

function Merchant.ScanBag(badId)
  local slotCount = GetContainerNumSlots(badId)

  if slotCount == 0 then
    return
  end

  for slot = 1,slotCount do
    local itemLink = GetContainerItemLink(badId, slot)

    if itemLink then

      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
      local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(badId, slot)

      if bindType == 0 and isCraftingReagent then
        local stockpile = Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.CharName]

        local comodity = nil

        for i = 1, #stockpile do
          if stockpile[i].ItemID == itemID then
            comodity = stockpile[i]
            break
          end
        end

        if comodity == nil then
          table.insert(stockpile, {
            ItemID = itemID,
            Icon = icon,
            Rarity = itemRarity,
            ItemCount = itemCount,
            ItemClassID = itemClassID,
            ItemSubClassID = itemSubClassID,
            Value = 0,
            Total = 0
          })
        else
          comodity.ItemCount = comodity.ItemCount + itemCount
        end
      end
    end
  end
end

--------------------------------------------------------------------------------

Merchant.Handlers = {
  ["AUCTION_HOUSE_SHOW"] = function(frame)
    Merchant.Debug("AH opened")
    FrameUtil.RegisterFrameForEvents(frame, { "OWNED_AUCTIONS_UPDATED" })

    if Merchant_Vars.Config.Autoscan == true and time() - Merchant_Vars.LastScanTime > 15 * 60 then
      C_AuctionHouse.ReplicateItems()
      Merchant.Print("UPDATED_AH")
      Merchant_Vars.LastScanTime = time()
      FrameUtil.RegisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
    elseif Merchant_Vars.Config.Autoscan == true then
      Merchant.PrintNextScan()
    end

    if Merchant.Tooltips.AHHooked == false then
      Merchant.Tooltips.HookAH()
      Merchant.Tooltips.AHHooked = true
    end
    FrameUtil.UnregisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_CLOSED" })
  end,

--------------------------------------------------------------------------------

  ["REPLICATE_ITEM_LIST_UPDATE"] = function(frame)
    Merchant.AH.Scan()
    Merchant.Print("DONE_SCANNING")
    FrameUtil.UnregisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
  end,

--------------------------------------------------------------------------------

  ["OWNED_AUCTIONS_UPDATED"] = function(Frame)
      Merchant.AH.FetchPlayerAuctions(frame)
  end,

--------------------------------------------------------------------------------

  ["ADDON_LOADED"] = function(frame)
    Merchant.InitCache()
    Merchant.InitPersistentVars()
    Merchant.UI.Create()
    Merchant.InitSlashCommands()
    FrameUtil.UnregisterFrameForEvents(frame, {"ADDON_LOADED"})
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
    FrameUtil.RegisterFrameForEvents(frame, { "BANKFRAME_OPENED" })
    Merchant.Debug("Merchant AddOn is loaded")
  end,

--------------------------------------------------------------------------------

  ["BANKFRAME_OPENED"] = function(frame)
    Merchant.Debug("Bank opened")

    local bagsStart = BACKPACK_CONTAINER               -- 0
    local bagsEnd   = NUM_BAG_SLOTS                    -- 4
    local bankBagsStart   = bagsEnd + 1                 -- 5
    local bankBagsEnd     = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS -- 11

    Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.CharName] = {}

    for bag = bagsStart, bagsEnd do
      Merchant.ScanBag(bag)
    end

    Merchant.ScanBag(BANK_CONTAINER)

    for bag = bankBagsStart, bankBagsEnd do
      Merchant.ScanBag(bag)
    end

    Merchant.ScanBag(REAGENTBANK_CONTAINER)
  end,

--------------------------------------------------------------------------------

  ["AUCTION_HOUSE_CLOSED"] = function(frame)
    Merchant.Debug("AH closed")
    FrameUtil.UnregisterFrameForEvents(frame, { "AUCTION_HOUSE_CLOSED" })
    FrameUtil.UnregisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
  end,
}

--------------------------------------------------------------------------------

function Merchant.OnEvent(frame, event)
  Merchant.Handlers[event](frame)
end
