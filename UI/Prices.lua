local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Prices.Update()

end

--------------------------------------------------------------------------------

function Merchant.UI.Prices.Draw()
  if Merchant.UI.Prices.Filled == false and Merchant.UI.Prices.IsAnyPrice() == true then
    Merchant.UI.Prices.Message:Hide()
    Merchant.UI.Prices._Fill()
  end

  if Merchant.UI.Prices.Filled == false then
    Merchant.UI.Prices.Frame:Show()
    return
  end

  Merchant.UI.Prices.Frame:Hide()
  Merchant.UI.Prices.Frame:Show()
--  Merchant.UI.Prices.Update()
end
--------------------------------------------------------------------------------

function Merchant.UI.Prices.IsAnyPrice()
  for key, value in pairs(Merchant_Vars.AHPrices[Merchant.RealmName]) do
    return true
  end
  return false
end

--------------------------------------------------------------------------------

function Merchant.UI.Prices._Fill()
  Merchant.UI.Prices.SearchText = Merchant.UI.Prices.Frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
  Merchant.UI.Prices.SearchText:SetPoint("TOPLEFT")
  Merchant.UI.Prices.SearchText:SetText("|cFFFFFFFFSearch by item name")

  Merchant.UI.Prices.Field = CreateFrame("EditBox", nil, Merchant.UI.Prices.Frame, "InputBoxTemplate")
  Merchant.UI.Prices.Field:SetPoint("TOPLEFT", Merchant.UI.Prices.SearchText, "TOPRIGHT", 10, 0)
--  Merchant.UI.Prices.Field:SetPoint("BOTTOMRIGHT", Merchant.UI.Prices.SearchText, "TOPRIGHT", 10 + 250, -15);
  Merchant.UI.Prices.Field:SetWidth(250)
--  Merchant.UI.Prices.Field:SetHeight(400);
--  Merchant.UI.Prices.Field:SetMovable(false);
  Merchant.UI.Prices.Field:SetAutoFocus(false)
  Merchant.UI.Prices.Field:SetMultiLine(1)
  Merchant.UI.Prices.Field:SetMaxLetters(40)
  Merchant.UI.Prices.Field:SetScript("OnEnterPressed", function(self)

--    self:ClearFocus(); -- clears focus from editbox, (unlocks key bindings, so pressing W makes your character go forward.
--    ChatFrame1EditBox:SetFocus(); -- if this is provided, previous line is not needed (opens chat frame)
  end)
--  Merchant.UI.Prices.Field:SetScript("OnChar", function(self, text)
--    Merchant.Debug(text)
--  end)

  Merchant.UI.Prices.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", Merchant.UI.Prices.Frame, "FauxScrollFrameTemplate")
  Merchant.UI.Prices.ScrollFrame:SetPoint("TOPLEFT", 0, -42 - 20 - 10)
  Merchant.UI.Prices.ScrollFrame:SetPoint("BOTTOMRIGHT", -10, 5)

  Merchant.UI.Prices.ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 35, Merchant.UI.Prices.Update);
  end)

  local frame = Merchant.UI.Prices.Frame

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
    itemNameText:SetText(tostring(i))
    x = -270
--    local quantityText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
--    quantityText:SetPoint("TOPRIGHT", x, y)
--    x = x + 125
    local valueText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    valueText:SetPoint("TOPRIGHT", x, y)
    valueText:SetText(tostring(i))
    x = x + 125
--    local totalText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
--    totalText:SetPoint("TOPRIGHT", x, y)
    table.insert(Merchant.UI.Prices.Rows, {
      IconFrame = iconFrame,
      ItemTexture = itemTexture,
      ItemNameText = itemNameText,
--      QuantityText = quantityText,
      ValueText = valueText,
--      TotalText = totalText
    })
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Prices.Fill(tabFrame)
  Merchant.UI.Prices.Frame = tabFrame

  if Merchant.UI.Prices.IsAnyPrice() == false then
    Merchant.UI.Prices.Message = Merchant.UI.Prices.Frame:CreateFontString(nil, "FULLSCREEN_DIALOG", "GameFontNormal")
    Merchant.UI.Prices.Message:SetPoint("CENTER")
    Merchant.UI.Prices.Message:SetText("|cFFFFFFFF" .. L("VISIT_AH"))
    Merchant.UI.Prices.Filled = false
    return
  end

  Merchant.UI.Prices._Fill()
end
