local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Table.TestOrder(label, compareFunc)
  local stockpile = Merchant.UI.Stockpile.GetFilteredStockpile()
  if #stockpile > 1 then
    local previous = stockpile[1][label]
    for i = 2, #stockpile do
      local current = stockpile[i][label]
      if compareFunc(previous, current) == false then
        return false
      end
      previous = current
    end
  end
  return true
end

--------------------------------------------------------------------------------

Merchant.UI.Stockpile.Table.SortFuncs = {
  ItemNameAsc = function(a, b)
    return a.ItemName:upper() < b.ItemName:upper()
  end,
  ItemNameDesc = function(a, b)
    return a.ItemName:upper() > b.ItemName:upper()
  end,
  ItemCountAsc = function(a, b)
    return a.ItemCount < b.ItemCount
  end,
  ItemCountDesc = function(a, b)
    return a.ItemCount> b.ItemCount
  end,
  ValueAsc = function(a, b)
    return a.Value < b.Value
  end,
  ValueDesc = function(a, b)
    return a.Value> b.Value
  end,
  TotalAsc = function(a, b)
    return a.Total < b.Total
  end,
  TotalDesc = function(a, b)
    return a.Total > b.Total
  end
}

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Table.Sort(frame)
  local test = false
  if Merchant.UI.Stockpile.Table.SortBy == nil then
    Merchant.UI.Stockpile.Table.SortBy = frame.Label
    Merchant.UI.Stockpile.Table.SortOrder = "Asc"
  elseif Merchant.UI.Stockpile.Table.SortBy == frame.Label then
    if Merchant.UI.Stockpile.Table.SortOrder == "Desc" then
      Merchant.UI.Stockpile.Table.SortOrder = "Asc"
    else
      Merchant.UI.Stockpile.Table.SortOrder = "Desc"
    end
  else
    Merchant.UI.Stockpile.Table.SortBy = frame.Label
    Merchant.UI.Stockpile.Table.SortOrder = "Asc"
  end

  local doSort = true

  local areAsc = Merchant.UI.Stockpile.Table.TestOrder(Merchant.UI.Stockpile.Table.SortBy, function(a, b) return a <= b end)
  local areDesc = Merchant.UI.Stockpile.Table.TestOrder(Merchant.UI.Stockpile.Table.SortBy, function(a, b) return a >= b end)

  if areAsc == true then
    Merchant.UI.Stockpile.Table.SortOrder = "Desc"
  end

  if areDesc == true then
    Merchant.UI.Stockpile.Table.SortOrder = "Asc"
  end

  if areAsc == true and areDesc == true then
    doSort = false
  end

  if doSort == true then
    table.sort(Merchant_Vars.Accounts[Merchant.RealmName].Stockpile[Merchant.UI.Stockpile.SelectedCharacter], Merchant.UI.Stockpile.Table.SortFuncs[Merchant.UI.Stockpile.Table.SortBy .. Merchant.UI.Stockpile.Table.SortOrder])
    Merchant.UI.Stockpile.Table.Update()
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Table.EmptyTable()
  for key, row in pairs(Merchant.UI.Stockpile.Table.Rows) do
    row.ItemTexture:SetTexture("")
    row.ItemNameText:SetText("")
    row.QuantityText:SetText("")
    row.ValueText:SetText("")
    row.TotalText:SetText("")
  end
  Merchant.UI.Stockpile.Table.RowCnt = 1
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Table.Update()
  local stockpile = Merchant.UI.Stockpile.GetFilteredStockpile()
  FauxScrollFrame_Update(Merchant.UI.Stockpile.Table.ScrollFrame, #stockpile, 9, 35);
  local offset = FauxScrollFrame_GetOffset(Merchant.UI.Stockpile.Table.ScrollFrame)
  Merchant.UI.Stockpile.Table.EmptyTable()
  local stop = math.min(#stockpile, 9)
  for line = 1, stop do
    local row = Merchant.UI.Stockpile.Table.Rows[line]
    local stock = stockpile[line + offset]

    row.ItemTexture:SetTexture(GetItemIcon(stock.ItemID))

    row.ItemNameText:SetText("|cFF" .. Merchant.Constants.UI.QUALITY_COLORS[stock.Rarity] .. stock.ItemName)
    Merchant.UI.ShortenNameWidget(row.ItemNameText)
    row.QuantityText:SetText("|cFFFFFFFF" .. tostring(stock.ItemCount))

    if stock.Value ~= 0 then
      row.ValueText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(stock.Value, true))
      row.TotalText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(stock.Total, true))
    else
      row.ValueText:SetText("|cFFFFFFFF" .. "N/A")
      row.TotalText:SetText("|cFFFFFFFF" .. "N/A")
    end
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Table.Fill()
  Merchant.UI.Stockpile.Table.Frame = CreateFrame("Frame", "$parentTableFrame", Merchant.UI.Stockpile.Frame)
  Merchant.UI.Stockpile.Table.Frame:SetAllPoints()

  Merchant.UI.Stockpile.Table.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", Merchant.UI.Stockpile.Table.Frame, "FauxScrollFrameTemplate")
  Merchant.UI.Stockpile.Table.ScrollFrame:SetPoint("TOPLEFT", 0, -42 - 20 - 10)
  Merchant.UI.Stockpile.Table.ScrollFrame:SetPoint("BOTTOMRIGHT", -10, 5)

  Merchant.UI.Stockpile.Table.ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 35, Merchant.UI.Stockpile.Table.Update);
  end)


  local frame = Merchant.UI.Stockpile.Table.Frame

  for i = 0, 8, 1 do
    local x = 0
    local y = -42 - 20 - 10 - 10 - 35 * i
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
    local valueText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    valueText:SetPoint("TOPRIGHT", x, y)
    x = x + 125
    local totalText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    totalText:SetPoint("TOPRIGHT", x, y)
    table.insert(Merchant.UI.Stockpile.Table.Rows, {
      IconFrame = iconFrame,
      ItemTexture = itemTexture,
      ItemNameText = itemNameText,
      QuantityText = quantityText,
      ValueText = valueText,
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
  nameButton:SetScript("OnClick", Merchant.UI.Stockpile.Table.Sort)
  x = -235
  local quantityButton = CreateFrame("Button", "$parentQuantityButton", frame, template)
  quantityButton:SetPoint("TOPRIGHT", x, y)
  quantityButton:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_QUANTITY"))
  quantityButton.Label = "ItemCount"
  quantityButton:SetScript("OnClick", Merchant.UI.Stockpile.Table.Sort)
  x = x + 97
  local buyoutButton = CreateFrame("Button", "$parentBuyoutButton", frame, template)
  buyoutButton:SetPoint("TOPRIGHT", x, y)
  buyoutButton:SetText("  |cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_VALUE") .. "  ")
  buyoutButton.Label = "Value"
  buyoutButton:SetScript("OnClick", Merchant.UI.Stockpile.Table.Sort)
  x = x + 123
  local totalButton = CreateFrame("Button", "$parentTotalButton", frame, template)
  totalButton:SetPoint("TOPRIGHT", x, y)
  totalButton:SetText("     |cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("TITLE_TOTAL") .. "     ")
  totalButton.Label = "Total"
  totalButton:SetScript("OnClick", Merchant.UI.Stockpile.Table.Sort)
end
