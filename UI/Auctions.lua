local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.TestOrder(label, compareFunc)
  local auctions = Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.UI.Auctions.SelectedCharacter]
  if #auctions > 1 then
    local previous = auctions[1][label]
    for i = 2, #auctions do
      local current = auctions[i][label]
      if compareFunc(previous, current) == false then
        return false
      end
      previous = current
    end
  end
  return true
end

--------------------------------------------------------------------------------

Merchant.UI.Auctions.SortFuncs = {
  ItemNameAsc = function(a, b)
    return a.ItemName:upper() < b.ItemName:upper()
  end,
  ItemNameDesc = function(a, b)
    return a.ItemName:upper() > b.ItemName:upper()
  end,
  QuantityAsc = function(a, b)
    return a.Quantity < b.Quantity
  end,
  QuantityDesc = function(a, b)
    return a.Quantity > b.Quantity
  end,
  BuyoutAsc = function(a, b)
    return a.Buyout < b.Buyout
  end,
  BuyoutDesc = function(a, b)
    return a.Buyout > b.Buyout
  end,
  TotalAsc = function(a, b)
    return a.Total < b.Total
  end,
  TotalDesc = function(a, b)
    return a.Total > b.Total
  end
}

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.Sort(frame)
  local test = false
  if Merchant.UI.Auctions.SortBy == nil then
    Merchant.UI.Auctions.SortBy = frame.Label
    Merchant.UI.Auctions.SortOrder = "Asc"
    test = true
  elseif Merchant.UI.Auctions.SortBy == frame.Label then
    if Merchant.UI.Auctions.SortOrder == "Desc" then
      Merchant.UI.Auctions.SortOrder = "Asc"
    else
      Merchant.UI.Auctions.SortOrder = "Desc"
    end
  else
    Merchant.UI.Auctions.SortBy = frame.Label
    Merchant.UI.Auctions.SortOrder = "Asc"
    test = true
  end

  local doSort = true
  if test == true then
    local areAsc = Merchant.UI.Auctions.TestOrder(Merchant.UI.Auctions.SortBy,
      function(a, b) return a <= b end)
    local areDesc = Merchant.UI.Auctions.TestOrder(Merchant.UI.Auctions.SortBy,
      function(a, b) return a >= b end)

    if areAsc == true then
      Merchant.UI.Auctions.SortOrder = "Desc"
    end

    if areDesc == true then
      Merchant.UI.Auctions.SortOrder = "Asc"
    end

    if areAsc == true and areDesc == true then
      doSort = false
    end
  end

  if doSort == true then
    table.sort(Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.UI.Auctions.SelectedCharacter], Merchant.UI.Auctions.SortFuncs[Merchant.UI.Auctions.SortBy .. Merchant.UI.Auctions.SortOrder])
    Merchant.UI.Auctions.Update()
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.CharactersDropDownHandler(self, arg1, arg2, checked)
  Merchant.UI.Auctions.SelectedCharacter = arg1
  UIDropDownMenu_SetText(Merchant.UI.Auctions.CharactersDropDown, Merchant.Utils.GetPrettyCharacterName(arg1))
  Merchant.UI.Auctions.Update()
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.CreateCharactersDropdown()
  Merchant.UI.Auctions.CharactersDropDown = CreateFrame("Frame", "$parentDropDown", Merchant.UI.Auctions.Frame, "UIDropDownMenuTemplate")
  Merchant.UI.Auctions.CharactersDropDown:ClearAllPoints()
  Merchant.UI.Auctions.CharactersDropDown:SetPoint("TOPLEFT", -20, 0)
  UIDropDownMenu_SetWidth(Merchant.UI.Auctions.CharactersDropDown, 125)
  UIDropDownMenu_Initialize(Merchant.UI.Auctions.CharactersDropDown, function(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = Merchant.UI.Auctions.CharactersDropDownHandler
    for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) do
      if #Merchant_Vars.Accounts[Merchant.RealmName].Auctions[key] > 0 then
        info.arg1 = key
        info.text = Merchant.Utils.GetPrettyCharacterName(key) .. "                  "
        UIDropDownMenu_AddButton(info)
        default = key
      end
    end
  end)
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) do
    if key == Merchant.CharName and #Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.CharName] > 0 then
      Merchant.UI.Auctions.SelectedCharacter = key
    end
  end
  if Merchant.UI.Auctions.SelectedCharacter == nil then
    Merchant.UI.Auctions.SelectedCharacter = default
  end
  UIDropDownMenu_SetText(Merchant.UI.Auctions.CharactersDropDown, Merchant.Utils.GetPrettyCharacterName(Merchant.UI.Auctions.SelectedCharacter))
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.EmptyTable()
  for key, row in pairs(Merchant.UI.Auctions.Rows) do
    row.ItemTexture:SetTexture("")
    row.ItemNameText:SetText("")
    row.QuantityText:SetText("")
    row.BuyoutText:SetText("")
    row.TotalText:SetText("")
  end
  Merchant.UI.Auctions.RowCnt = 1
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.Update()
  local auctions = Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.UI.Auctions.SelectedCharacter]
  for _, auction in ipairs(auctions) do
    auction.ItemName = GetItemInfo(auction.ItemID)
    if auction.ItemName == nil then
      auction.ItemName = "N/A"
    end
  end
  FauxScrollFrame_Update(Merchant.UI.Auctions.ScrollFrame, #auctions, 9, 35);
  local offset = FauxScrollFrame_GetOffset(Merchant.UI.Auctions.ScrollFrame)
  Merchant.UI.Auctions.EmptyTable()
  local stop = math.min(#auctions, 9)
  for line = 1, stop do
    local row = Merchant.UI.Auctions.Rows[line]
    local auction = auctions[line + offset]
    row.ItemTexture:SetTexture(GetItemIcon(auction.ItemID))
    row.ItemNameText:SetText("|cFF" .. Merchant.Constants.UI.QUALITY_COLORS[auction.Rarity] .. auction.ItemName)
    Merchant.UI.ShortenNameWidget(row.ItemNameText)
    row.QuantityText:SetText("|cFFFFFFFF" .. tostring(auction.Quantity))
    row.BuyoutText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(auction.Buyout, true))
    row.TotalText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(auction.Quantity * auction.Buyout, true))
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.Draw()
  if Merchant.UI.Auctions.Filled == false and Merchant.UI.Auctions.IsAnyAuctions() == true then
    Merchant.UI.Auctions.Message:Hide()
    Merchant.UI.Auctions._Fill()
  end

  if Merchant.UI.Auctions.Filled == false then
    Merchant.UI.Auctions.Frame:Show()
    return
  end

  Merchant.UI.Auctions.Frame:Hide()
  Merchant.UI.Auctions.Frame:Show()
  Merchant.UI.Auctions.Update()
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.IsAnyAuctions()
  for key, value in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) do
    if #Merchant_Vars.Accounts[Merchant.RealmName].Auctions[key] > 0 then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions._Fill()
  Merchant.UI.Auctions.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", Merchant.UI.Auctions.Frame, "FauxScrollFrameTemplate")
  Merchant.UI.Auctions.ScrollFrame:SetPoint("TOPLEFT", 0, -42 - 20 - 10)
  Merchant.UI.Auctions.ScrollFrame:SetPoint("BOTTOMRIGHT", -10, 5)

  Merchant.UI.Auctions.ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 35, Merchant.UI.Auctions.Update);
  end)

  local frame = Merchant.UI.Auctions.Frame

  for i = 0, 8, 1 do
    local x = 0
    local y = -42 - 20 - 10 -10 - 35 * i
    local iconFrame = CreateFrame("Frame", nil, frame)
    iconFrame:SetSize(32, 32)
    iconFrame:SetPoint("TOPLEFT", x, y + 10)
    local itemTexture = iconFrame:CreateTexture(nil, "FULLSCREEN_DIALOG")
    itemTexture:SetAllPoints()
    x = x + 32 + 10
    local itemNameText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    itemNameText:SetPoint("TOPLEFT", x, y)
    x = -270
    local quantityText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    quantityText:SetPoint("TOPRIGHT", x, y)
    x = x + 125
    local buyoutText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    buyoutText:SetPoint("TOPRIGHT", x, y)
    x = x + 125
    local totalText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    totalText:SetPoint("TOPRIGHT", x, y)
    table.insert(Merchant.UI.Auctions.Rows, {
      IconFrame = iconFrame,
      ItemTexture = itemTexture,
      ItemNameText = itemNameText,
      QuantityText = quantityText,
      BuyoutText = buyoutText,
      TotalText = totalText
    })
  end


  local template = "OptionsFrameTabButtonTemplate"
  local x = 30
  local y = -42
  local nameButton = CreateFrame("Button", "$parentNameButton", frame, template)
  nameButton:SetPoint("TOPLEFT", x, y)
  local str = ""
  for i = 1, 28 do
    str = str .. " "
  end
  str = str .. "|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_NAME")
  for i = 1, 28 do
    str = str .. " "
  end
  nameButton:SetText(str)
  nameButton.Label = "ItemName"
  nameButton:SetScript("OnClick", Merchant.UI.Auctions.Sort)
  x = -235
  local quantityButton = CreateFrame("Button", "$parentQuantityButton", frame, template)
  quantityButton:SetPoint("TOPRIGHT", x, y)
  quantityButton:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_QUANTITY"))
  quantityButton.Label = "Quantity"
  quantityButton:SetScript("OnClick", Merchant.UI.Auctions.Sort)
  x = x + 97
  local buyoutButton = CreateFrame("Button", "$parentBuyoutButton", frame, template)
  buyoutButton:SetPoint("TOPRIGHT", x, y)
  buyoutButton:SetText("  |cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_BUYOUT") .. "  ")
  buyoutButton.Label = "Buyout"
  buyoutButton:SetScript("OnClick", Merchant.UI.Auctions.Sort)
  x = x + 123
  local totalButton = CreateFrame("Button", "$parentTotalButton", frame, template)
  totalButton:SetPoint("TOPRIGHT", x, y)
  totalButton:SetText("     |cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_TOTAL") .. "     ")
  totalButton.Label = "Total"
  totalButton:SetScript("OnClick", Merchant.UI.Auctions.Sort)


  Merchant.UI.Auctions.CreateCharactersDropdown()

  Merchant.UI.Auctions.Filled = true
end

--------------------------------------------------------------------------------

function Merchant.UI.Auctions.Fill(tabFrame)
  Merchant.UI.Auctions.Frame = tabFrame

  if Merchant.UI.Auctions.IsAnyAuctions() == false then
    Merchant.UI.Auctions.Message = Merchant.UI.Auctions.Frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    Merchant.UI.Auctions.Message:SetPoint("CENTER")
    Merchant.UI.Auctions.Message:SetText("|cFFFFFFFF" .. L("VISIT_AUCTIONS"))
    Merchant.UI.Auctions.Filled = false
    return
  end

  Merchant.UI.Auctions._Fill()
end
