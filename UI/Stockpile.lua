local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.CharactersDropDownHandler(self, arg1, arg2, checked)
  if Merchant.UI.Stockpile.SelectedCharacter == arg1 then
    return
  end
  Merchant.UI.Stockpile.SelectedCharacter = arg1
  local pretty = Merchant.Utils.GetPrettyCharacterName(Merchant.UI.Stockpile.SelectedCharacter)
  UIDropDownMenu_SetText(Merchant.UI.Stockpile.CharactersDropDown, pretty)
  Merchant.UI.Stockpile.InitializeFiltersDropdown()
  Merchant.UI.Stockpile.Draw()
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.CreateCharactersDropdown(fixedContent)
  Merchant.UI.Stockpile.CharactersDropDown = CreateFrame("Frame", "$parentCharsDropDown", fixedContent, "UIDropDownMenuTemplate")
  Merchant.UI.Stockpile.CharactersDropDown:ClearAllPoints()
  Merchant.UI.Stockpile.CharactersDropDown:SetPoint("TOPLEFT", -20, 0)
  UIDropDownMenu_SetWidth(Merchant.UI.Stockpile.CharactersDropDown, 125)
  UIDropDownMenu_Initialize(Merchant.UI.Stockpile.CharactersDropDown, function(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = Merchant.UI.Stockpile.CharactersDropDownHandler
    for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile) do
      if #Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[key] > 0 then
        info.arg1 = key
        info.text = Merchant.Utils.GetPrettyCharacterName(key) .. "                  "
        UIDropDownMenu_AddButton(info)
        default = key
      end
    end
  end)
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile) do
    if key == Merchant.CharName and #Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.CharName] > 0 then
      Merchant.UI.Stockpile.SelectedCharacter = key
    end
  end
  if Merchant.UI.Stockpile.SelectedCharacter == nil then
    Merchant.UI.Stockpile.SelectedCharacter = default
  end
  UIDropDownMenu_SetText(Merchant.UI.Stockpile.CharactersDropDown, Merchant.Utils.GetPrettyCharacterName(Merchant.UI.Stockpile.SelectedCharacter))
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.DisplayDropDownHandler(self, arg1, arg2, checked)
  if Merchant.UI.Stockpile.SelectedDisplay == arg1 then
    return
  end
  Merchant.UI.Stockpile.SelectedDisplay = arg1
  local pretty = nil
  if Merchant.UI.Stockpile.SelectedDisplay == "grid" then
    pretty = "Grid View"
  else
    pretty = "Table View"
  end
  UIDropDownMenu_SetText(Merchant.UI.Stockpile.DisplayDropDown, pretty)
  Merchant.UI.Stockpile.Draw()
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.CreateDisplayDropdown(fixedContent)
  Merchant.UI.Stockpile.DisplayDropDown = CreateFrame("Frame", "$parentDisplayDropDown", fixedContent, "UIDropDownMenuTemplate")
  Merchant.UI.Stockpile.DisplayDropDown:ClearAllPoints()
  Merchant.UI.Stockpile.DisplayDropDown:SetPoint("TOPRIGHT", 0, 0)
  UIDropDownMenu_SetWidth(Merchant.UI.Stockpile.DisplayDropDown, 125)
  UIDropDownMenu_Initialize(Merchant.UI.Stockpile.DisplayDropDown, function(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = Merchant.UI.Stockpile.DisplayDropDownHandler
    info.arg1 = "grid"
    info.text = "Grid View"
    UIDropDownMenu_AddButton(info)
    info.arg1 = "table"
    info.text = "Table View"
    UIDropDownMenu_AddButton(info)
  end)
  Merchant.UI.Stockpile.SelectedDisplay = "table"
  UIDropDownMenu_SetText(Merchant.UI.Stockpile.DisplayDropDown, "Table View")
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.FiltersDropDownHandler(self, arg1, arg2, checked)
  if Merchant.UI.Stockpile.SelectedFilter == arg1 then
    return
  end
  Merchant.UI.Stockpile.SelectedFilter = arg1
  local pretty = ""
  if Merchant.UI.Stockpile.SelectedFilter == "all" then
    pretty = L("ALL")
  else
    pretty = L(Merchant.Constants.UI.TRADESKILL_KEYS[Merchant.UI.Stockpile.SelectedFilter])
  end
  UIDropDownMenu_SetText(Merchant.UI.Stockpile.FiltersDropDown, pretty)
  Merchant.UI.Stockpile.Draw()
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.InitializeFiltersDropdown(frame, level, menuList)
  local info = UIDropDownMenu_CreateInfo()
  info.notCheckable = true
  info.func = Merchant.UI.Stockpile.FiltersDropDownHandler
  info.arg1 = "all"
  info.text = L("ALL")
  UIDropDownMenu_AddButton(info)
  local check = {}
  local same = false
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.UI.Stockpile.SelectedCharacter]) do
    if check[value.ItemSubClassID] == nil then
      info.arg1 = value.ItemSubClassID
      info.text = L(Merchant.Constants.UI.TRADESKILL_KEYS[value.ItemSubClassID])
      if Merchant.UI.Stockpile.SelectedFilter == info.arg1 then
        same = true
      end
      UIDropDownMenu_AddButton(info)
      check[value.ItemSubClassID] = true
    end
  end
  if same == false then
    Merchant.UI.Stockpile.SelectedFilter = "all"
    UIDropDownMenu_SetText(Merchant.UI.Stockpile.FiltersDropDown, L("ALL"))
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.CreateFiltersDropdown(fixedContent)
  Merchant.UI.Stockpile.FiltersDropDown = CreateFrame("Frame", "$parentDropDown", fixedContent, "UIDropDownMenuTemplate")
  Merchant.UI.Stockpile.FiltersDropDown:ClearAllPoints()
  Merchant.UI.Stockpile.FiltersDropDown:SetPoint("TOPLEFT", 220, 0)
  UIDropDownMenu_SetWidth(Merchant.UI.Stockpile.FiltersDropDown, 125)
  UIDropDownMenu_Initialize(Merchant.UI.Stockpile.FiltersDropDown, Merchant.UI.Stockpile.InitializeFiltersDropdown)
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.GetFilteredStockpile()
  local stockpile = Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.UI.Stockpile.SelectedCharacter]
  for _, stock in ipairs(stockpile) do
    stock.ItemName = GetItemInfo(stock.ItemID)
    if stock.ItemName == nil then
      stock.ItemName = "N/A"
    end
  end
  if Merchant.UI.Stockpile.SelectedFilter == "all" then
    return stockpile
  end
  local filteredStockpile = {}
  for key, value in ipairs(stockpile) do
    if value.ItemSubClassID == Merchant.UI.Stockpile.SelectedFilter then
      table.insert(filteredStockpile, value)
    end
  end
  return filteredStockpile
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.UpdateValues()
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile) do
    for ikey, stock in ipairs(value) do
      local marketValue = Merchant_Vars.AHPrices[Merchant.RealmName][tostring(stock.ItemID)]
      if marketValue ~= nil then
        stock.Value = marketValue
        stock.Total = marketValue * stock.ItemCount
      end
    end
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Draw()
  if Merchant.UI.Stockpile.Filled == false and Merchant.UI.Stockpile.IsAnyStock() == true then
    Merchant.UI.Stockpile.Message:Hide()
    Merchant.UI.Stockpile._Fill()
  end

  if Merchant.UI.Stockpile.Filled == false then
    Merchant.UI.Stockpile.Frame:Show()
    return
  end

  Merchant.UI.Stockpile.UpdateValues()

  if Merchant.UI.Stockpile.SelectedDisplay == "grid" then
    Merchant.UI.Stockpile.Table.Frame:Hide()
    Merchant.UI.Stockpile.Grid.Frame:Show()
    Merchant.UI.Stockpile.Grid.Update()
  else
    Merchant.UI.Stockpile.Grid.Frame:Hide()
    Merchant.UI.Stockpile.Table.Frame:Show()
    Merchant.UI.Stockpile.Table.Update()
  end

  Merchant.UI.Stockpile.Frame:Hide()
  Merchant.UI.Stockpile.Frame:Show()
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.IsAnyStock()
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile) do
    if #Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[key] > 0 then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile._Fill()
  Merchant.UI.Stockpile.Grid.Fill()
  Merchant.UI.Stockpile.Table.Fill()

  Merchant.UI.Stockpile.CreateCharactersDropdown(Merchant.UI.Stockpile.Frame)
  Merchant.UI.Stockpile.CreateDisplayDropdown(Merchant.UI.Stockpile.Frame)
  Merchant.UI.Stockpile.CreateFiltersDropdown(Merchant.UI.Stockpile.Frame)

  Merchant.UI.Stockpile.SelectedDisplay = "table"

  Merchant.UI.Stockpile.Filled = true
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Fill(tabFrame)
  Merchant.UI.Stockpile.Frame = tabFrame

  if Merchant.UI.Stockpile.IsAnyStock() == false then
    Merchant.UI.Stockpile.Message = Merchant.UI.Stockpile.Frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    Merchant.UI.Stockpile.Message:SetPoint("CENTER")
    Merchant.UI.Stockpile.Message:SetText("|cFFFFFFFF" .. L("VISIT_BANK"))
    Merchant.UI.Stockpile.Filled = false
    return
  end

  Merchant.UI.Stockpile._Fill()
end
