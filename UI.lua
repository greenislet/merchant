local _, addonTable = ...
local zc = addonTable.zc

local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.CreateMinimapIcon()
  if LibStub("LibDataBroker-1.1", true) then
    dataBroker = LibStub("LibDataBroker-1.1"):NewDataObject("Merchant",
      {type = "launcher", label = "Merchant",
      icon = "Interface/Icons/Inv_misc_bag_10"}
    )

    function dataBroker.OnClick(self, button)
      if IsShiftKeyDown() then
        return
      end
      if button == "LeftButton" then
        if Merchant.UI.PanelShown == true then
          Merchant.UI.MainFrame:Hide()
        else
          Merchant.UI.MainFrame:Show()
        end
      end
    end

    function dataBroker.OnTooltipShow(GameTooltip)
      GameTooltip:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR
        .. "Merchant")
			GameTooltip:AddLine("|cFFFFFFFFversion " .. Merchant.Constants.VERSION)
      GameTooltip:AddLine("")
      GameTooltip:AddDoubleLine("|cFF" .. Merchant.Constants.UI.SECOND_COLOR
                                .. L("LEFT_CLICK"),
                                "|cFF" .. Merchant.Constants.UI.SECOND_COLOR
                                .. L("LEFT_CLICK_EXPLANATION"))
    end
  end

  if LibStub("LibDBIcon-1.0", true) then
    LibStub("LibDBIcon-1.0"):Register("Merchant", dataBroker,
                                      Merchant_Vars.Minimap)
  end

  LibStub("LibDBIcon-1.0"):Show("Merchant")
end

--------------------------------------------------------------------------------

function Merchant.UI.EmptyAuctionsTable()
  for key, row in pairs(Merchant.UI.AuctionRows) do
    row.ItemTexture:SetTexture("")
    row.ItemNameText:SetText("")
    row.QuantityText:SetText("")
    row.BuyoutText:SetText("")
    row.TotalText:SetText("")
  end
  Merchant.UI.AuctionRowCnt = 1
end

--------------------------------------------------------------------------------

function Merchant.UI.AddAuctionRow(itemId, itemDisplayName, buyout, count)
  if #Merchant.UI.AuctionRows < Merchant.UI.AuctionRowCnt then
    local frame = Merchant.UI.AuctionsScrollFrameContent
    local x = 0
    local y = -10 - 35 * (Merchant.UI.AuctionRowCnt - 1)
    iconFrame = CreateFrame("Frame", nil, frame)
    iconFrame:SetSize(32, 32)
    iconFrame:SetPoint("TOPLEFT", x, y + 10)
    itemTexture = iconFrame:CreateTexture(nil, "FULLSCREEN_DIALOG")
    itemTexture:SetAllPoints()
    x = x + 32 + 10
    itemNameText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG",
                                          "GameFontNormal")
    itemNameText:SetPoint("TOPLEFT", x, y)
    x = -270
    quantityText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG",
                                          "GameFontNormal")
    quantityText:SetPoint("TOPRIGHT", x, y)
    x = x + 125
    buyoutText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG",
                                        "GameFontNormal")
    buyoutText:SetPoint("TOPRIGHT", x, y)
    x = x + 125
    totalText = frame:CreateFontString(nil, "FULLSCREEN_DIALOG",
                                       "GameFontNormal")
    totalText:SetPoint("TOPRIGHT", x, y)
    table.insert(Merchant.UI.AuctionRows, {
      IconFrame = iconFrame,
      ItemTexture = itemTexture,
      ItemNameText = itemNameText,
      QuantityText = quantityText,
      BuyoutText = buyoutText,
      TotalText = totalText
    })
  end

  row = Merchant.UI.AuctionRows[Merchant.UI.AuctionRowCnt]
  row.ItemTexture:SetTexture(GetItemIcon(itemId))
  row.ItemNameText:SetText(itemDisplayName)
  local pixelLimit = 237
  local charLimit = 30
  local itemName = row.ItemNameText:GetText()
  local offset = 0

  local function SplitText(str, chrLimit, off, doOff)
    local leftPartoff = 0
    local rightPartoff = 0
    if doOff == true then
      if off % 2 == 0 then
         rightPartoff = 1
      else
         leftPartoff = 1
      end
    end
    local leftPart = str:sub(1, 10 + chrLimit / 2 + off + leftPartoff)
    local rightPart = str:sub(str:len() - 2 - chrLimit / 2 - off - rightPartoff, str:len())
    return leftPart, rightPart
  end

  local function ReduceText(widget, str, chrLimit, off, doOff)
    local leftPart, rightPart = SplitText(str, chrLimit, off, doOff)
    widget:SetText(leftPart .. "..." .. rightPart)
  end

  if row.ItemNameText:GetWidth() > pixelLimit then
    ReduceText(row.ItemNameText, itemName, charLimit, offset, false)
    if row.ItemNameText:GetWidth() < pixelLimit then
      local previous = row.ItemNameText:GetText()
      while true == true do
        ReduceText(row.ItemNameText, itemName, charLimit, offset, true)
        if row.ItemNameText:GetWidth() > pixelLimit then
          break
        end
        offset = offset + 1
        previous = row.ItemNameText:GetText()
      end
      row.ItemNameText:SetText(previous)
      local leftPart, rightPart = SplitText(itemName, charLimit, offset, false)
      local points = "..."
      while true == true do
        points = points .. "."
        row.ItemNameText:SetText(leftPart .. points .. rightPart)
        if row.ItemNameText:GetWidth() > pixelLimit then
          break
        end
        previous = row.ItemNameText:GetText()
      end
      row.ItemNameText:SetText(previous)
    end
  end


  row.QuantityText:SetText("|cFFFFFFFF" .. tostring(count))
  row.BuyoutText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(buyout, true))
  row.TotalText:SetText("|cFFFFFFFF" .. zc.priceToMoneyString(count * buyout,
                                                              true))

  Merchant.UI.AuctionRowCnt = Merchant.UI.AuctionRowCnt + 1
  Merchant.UI.AuctionsScrollFrameContent:SetHeight(Merchant.UI.AuctionRowCnt
                                                   * 34)
end

--------------------------------------------------------------------------------

function Merchant.UI.DrawAuctionsTable(charName)
  Merchant.UI.EmptyAuctionsTable()
  local auctions = Merchant_Vars.Accounts[Merchant.RealmName].Auctions[charName]
  if auctions == nil then
    Merchant.Debug("error: no auctions for " .. charName .. " character")
    return
  end
  for idx, auction in ipairs(auctions) do
    Merchant.UI.AddAuctionRow(auction.ItemId, auction.ItemDisplayName,
                              auction.Buyout, auction.Quantity)
  end
  if #auctions > 9 then
    Merchant.UI.AuctionsScrollFrameSlider:Show()
  else
    Merchant.UI.AuctionsScrollFrameSlider:Hide()
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.DropDownHandler(self, arg1, arg2, checked)
  Merchant.UI.SelectedCharacter = arg1
  UIDropDownMenu_SetText(Merchant.UI.DropDown,
                         Merchant.Utils.GetPrettyCharacterName(arg1))
  Merchant.UI.DrawAuctionsTable(arg1)
end

--------------------------------------------------------------------------------

function Merchant.UI.TestAuctionsOrder(label, compareFunc)
  local auctions = Merchant_Vars.Accounts[Merchant.RealmName]
                   .Auctions[Merchant.UI.SelectedCharacter]
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

Merchant.UI.SortFuncs = {
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

function Merchant.UI.SortAuctions(frame)
  local test = false
  if Merchant.UI.SortBy == nil then
    Merchant.UI.SortBy = frame.Label
    Merchant.UI.SortOrder = "Asc"
    test = true
  elseif Merchant.UI.SortBy == frame.Label then
    if Merchant.UI.SortOrder == "Desc" then
      Merchant.UI.SortOrder = "Asc"
    else
      Merchant.UI.SortOrder = "Desc"
    end
  else
    Merchant.UI.SortBy = frame.Label
    Merchant.UI.SortOrder = "Asc"
    test = true
  end

  local doSort = true
  if test == true then
    local areAsc = Merchant.UI.TestAuctionsOrder(Merchant.UI.SortBy,
      function(a, b) return a <= b end)
    local areDesc = Merchant.UI.TestAuctionsOrder(Merchant.UI.SortBy,
      function(a, b) return a >= b end)

    if areAsc == true then
      Merchant.UI.SortOrder = "Desc"
    end

    if areDesc == true then
      Merchant.UI.SortOrder = "Asc"
    end

    if areAsc == true and areDesc == true then
      doSort = false
    end
  end

  if doSort == true then
    table.sort(Merchant_Vars.Accounts[Merchant.RealmName]
               .Auctions[Merchant.UI.SelectedCharacter],
               Merchant.UI.SortFuncs[Merchant.UI.SortBy
                                     .. Merchant.UI.SortOrder])
    Merchant.UI.DrawAuctionsTable(Merchant.UI.SelectedCharacter)
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.FillAuctionsFrame(tabFrame)
  Merchant.UI.AuctionsFrame = tabFrame
  Merchant.UI.AuctionsScrollFrame = CreateFrame("ScrollFrame",
                                                "$parentScrollFrame",
                                                Merchant.UI.AuctionsFrame)
  Merchant.UI.AuctionsScrollFrame:EnableMouseWheel(true)
  Merchant.UI.AuctionsScrollFrame:SetPoint("TOPLEFT", 0, -42 - 20 - 10)
  Merchant.UI.AuctionsScrollFrame:SetPoint("BOTTOMRIGHT", 0, 5)
  Merchant.UI.AuctionsScrollFrame:SetScript("OnMouseWheel",
    function(frame, value)
      Merchant.UI.AuctionsScrollFrameSlider:SetValue(math.min(math.max(
        Merchant.UI.AuctionsScrollValue + value * (1000 /
          ((Merchant.UI.AuctionsScrollFrame:GetHeight() -
            Merchant.UI.AuctionsScrollFrameContent:GetHeight())
            / 45)), 0), 1000))
  end)
  Merchant.UI.AuctionsScrollFrameSlider = CreateFrame("Slider", "$parentSlider",
                    Merchant.UI.AuctionsScrollFrame, "UIPanelScrollBarTemplate")
  Merchant.UI.AuctionsScrollFrameSlider:SetPoint("TOPLEFT",
    Merchant.UI.AuctionsScrollFrame, "TOPRIGHT", -5, 0)
	Merchant.UI.AuctionsScrollFrameSlider:SetPoint("BOTTOMLEFT",
    Merchant.UI.AuctionsScrollFrame, "BOTTOMRIGHT", 0, 0)
	Merchant.UI.AuctionsScrollFrameSlider:SetMinMaxValues(0, 1000)
	Merchant.UI.AuctionsScrollFrameSlider:SetValueStep(1)
	Merchant.UI.AuctionsScrollFrameSlider:SetValue(0)
	Merchant.UI.AuctionsScrollFrameSlider:SetWidth(16)
  local function scrollRefresh(value)
    local scrollFrameHeight = Merchant.UI.AuctionsScrollFrame:GetHeight()
    local contentHeight = Merchant.UI.AuctionsScrollFrameContent:GetHeight()
    local offset
    if scrollFrameHeight > contentHeight then
      offset = 0
    else
      offset = math.floor((contentHeight - scrollFrameHeight) / 1000.0 * value)
      offset = offset - offset % 35
    end
    Merchant.UI.AuctionsScrollFrameContent:ClearAllPoints()
    Merchant.UI.AuctionsScrollFrameContent:SetPoint("TOPLEFT", 0, offset)
    Merchant.UI.AuctionsScrollFrameContent:SetPoint("TOPRIGHT", 0, offset)
    Merchant.UI.AuctionsScrollValue = value
  end

	Merchant.UI.AuctionsScrollFrameSlider:SetScript("OnValueChanged",
                                                  function(frame, value)
    scrollRefresh(value)
  end)

  Merchant.UI.AuctionsScrollFrameSliderBackground
    = Merchant.UI.AuctionsScrollFrameSlider:CreateTexture(nil, "BACKGROUND")
	Merchant.UI.AuctionsScrollFrameSliderBackground:SetAllPoints(
    Merchant.UI.AuctionsScrollFrameSlider)
	Merchant.UI.AuctionsScrollFrameSliderBackground:SetColorTexture(0, 0, 0, 0.4)

  Merchant.UI.AuctionsScrollFrameContent = CreateFrame("Frame",
    "$parentContent", Merchant.UI.AuctionsScrollFrame)
  Merchant.UI.AuctionsScrollFrameContent:SetPoint("TOPLEFT")
  Merchant.UI.AuctionsScrollFrameContent:SetPoint("TOPRIGHT")
  Merchant.UI.AuctionsScrollFrameContent:SetHeight(0)

  Merchant.UI.AuctionsScrollFrame:SetScrollChild(
    Merchant.UI.AuctionsScrollFrameContent)


  local fixedContent = Merchant.UI.AuctionsFrame
  Merchant.UI.DropDown = CreateFrame("Frame", "$parentDropDown", fixedContent,
                                     "UIDropDownMenuTemplate")
  Merchant.UI.DropDown:ClearAllPoints()
  Merchant.UI.DropDown:SetPoint("TOPLEFT", -20, 0)
  UIDropDownMenu_SetWidth(Merchant.UI.DropDown, 125)
  UIDropDownMenu_Initialize(Merchant.UI.DropDown, function(frame, level,
    menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.func = Merchant.UI.DropDownHandler
    for key, value
      in pairs(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) do
      info.arg1 = key
      info.text = Merchant.Utils.GetPrettyCharacterName(key)
                  .. "                  "
      UIDropDownMenu_AddButton(info)
      default = key
    end
  end)
  for key, value in
    pairs(Merchant_Vars.Accounts[Merchant.RealmName].Auctions) do
    if key == Merchant.CharName then
      Merchant.UI.SelectedCharacter = key
    end
  end
  if Merchant.UI.SelectedCharacter == nil then
    Merchant.UI.SelectedCharacter = default
  end
  UIDropDownMenu_SetText(Merchant.UI.DropDown,
    Merchant.Utils.GetPrettyCharacterName(Merchant.UI.SelectedCharacter))

  local template = "OptionsFrameTabButtonTemplate"
  local x = 30
  local y = -42
  nameButton = CreateFrame("Button", "$parentNameButton", fixedContent,
                           template)
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
  nameButton:SetScript("OnClick", Merchant.UI.SortAuctions)
  x = -235
  quantityButton = CreateFrame("Button", "$parentQuantityButton", fixedContent,
                               template)
  quantityButton:SetPoint("TOPRIGHT", x, y)
  quantityButton:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR
                         .. L("TITLE_QUANTITY"))
  quantityButton.Label = "Quantity"
  quantityButton:SetScript("OnClick", Merchant.UI.SortAuctions)
  x = x + 97
  buyoutButton = CreateFrame("Button", "$parentBuyoutButton", fixedContent,
                             template)
  buyoutButton:SetPoint("TOPRIGHT", x, y)
  buyoutButton:SetText("  |cFF" .. Merchant.Constants.UI.SECOND_COLOR
                       .. L("TITLE_BUYOUT") .. "  ")
  buyoutButton.Label = "Buyout"
  buyoutButton:SetScript("OnClick", Merchant.UI.SortAuctions)
  x = x + 123
  totalButton = CreateFrame("Button", "$parentTotalButton", fixedContent,
                            template)
  totalButton:SetPoint("TOPRIGHT", x, y)
  totalButton:SetText("     |cFF" .. Merchant.Constants.UI.SECOND_COLOR
                      .. L("TITLE_TOTAL") .. "     ")
  totalButton.Label = "Total"
  totalButton:SetScript("OnClick", Merchant.UI.SortAuctions)

  scrollRefresh(0)
end

--------------------------------------------------------------------------------

function Merchant.UI.FillOptionsFrame(frame)

  local y = 0
  local fontString = frame:CreateFontString("$parentTransparentPanelText",
                                            "ARTWORK", "GameFontNormal")
  fontString:SetPoint("TOPLEFT")
  fontString:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR
                     .. L("OPTION_TRANSPARENT_PANEL"))

  local checkBox = CreateFrame("CheckButton",
    "$parentTransparentPanelCheckButton",
    frame, "ChatConfigCheckButtonTemplate")
  checkBox:SetSize(40, 40)
  checkBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10)
  checkBox:SetChecked(Merchant_Vars.Config.TransparentPanel)
  checkBox:SetScript("OnClick", function(self)
    if self:GetChecked() == true then
      Merchant_Vars.Config.TransparentPanel = true
      Merchant.UI.MainFrame:SetBackdrop(Merchant.UI.Backdrop.Transparent)
    else
      Merchant_Vars.Config.TransparentPanel = false
      Merchant.UI.MainFrame:SetBackdrop(Merchant.UI.Backdrop.Black)
    end
  end)

  y = y + 30
  fontString = frame:CreateFontString("$parentTransparentPanelText",
                                      "ARTWORK", "GameFontNormal")
  fontString:SetPoint("TOPLEFT", 0, -y)
  fontString:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR
                     .. L("OPTION_DEBUG_MODE"))

  checkBox = CreateFrame("CheckButton", "$parentTransparentPanelCheckButton",
                         frame, "ChatConfigCheckButtonTemplate")
  checkBox:SetSize(40, 40)
  checkBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10 - y)
  checkBox:SetChecked(Merchant_Vars.Config.DebugMode)
  checkBox:SetScript("OnClick", function(self)
    if self:GetChecked() == true then
      Merchant_Vars.Config.DebugMode = true
    else
      Merchant_Vars.Config.DebugMode = false
    end
  end)
end

--------------------------------------------------------------------------------

function Merchant.UI.SelectTab(tabIdx)
  selectedTab = Merchant.UI.Tabs[tabIdx]
  previousTab = Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx]
  previousTab.button:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR
                             .. L(previousTab.StringKey))
  previousTab.frame:Hide()
  selectedTab.button:SetText("|cFFFFFFFF" .. L(selectedTab.StringKey))
  selectedTab.frame:Show()
  Merchant_Vars.UI.SelectedTabIdx = tabIdx
end

--------------------------------------------------------------------------------

function Merchant.UI.OnTabButtonClick(button)
  for key, value in pairs(Merchant.UI.Tabs) do
    if value.StringKey == button.name then
      selectedTabKey = key
    end
  end
  Merchant.UI.SelectTab(selectedTabKey)
end

--------------------------------------------------------------------------------

function Merchant.UI.CreateTabs()
  local buttonHeight = 22
  local margin = 20
  local y = -30

  Merchant.UI.BorderFrame = CreateFrame("Frame", "$parentBorderFrame",
                                        Merchant.UI.MainFrame)
  Merchant.UI.BorderFrame:SetBackdrop(Merchant.UI.Backdrop.Thin)
  Merchant.UI.BorderFrame:SetSize(Merchant.UI.MainFrame:GetWidth() - 2 * margin,
    Merchant.UI.MainFrame:GetHeight() - 30 - buttonHeight - 1 * margin)
  Merchant.UI.BorderFrame:SetPoint("TOPLEFT", Merchant.UI.MainFrame, "TOPLEFT",
                                   margin, -30 - buttonHeight)
  -- Merchant.UI.BorderFrame:Show()

  local x = 0
  for idx, value in ipairs(Merchant.UI.Tabs) do
    local tabButton = CreateFrame("Button", "$parentTabButton" .. tostring(idx),
      Merchant.UI.MainFrame, "OptionsFrameTabButtonTemplate")
    tabButton:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR
                      .. L(value.StringKey))
    tabButton:SetPoint("TOPLEFT", margin + x, y)
    tabButton.name = value.StringKey
    value.button = tabButton
    tabButton:SetScript("OnClick", Merchant.UI.OnTabButtonClick)
    x = x + tabButton:GetWidth() + 30

    value.frame = CreateFrame("Frame", "$parentContentFrame" .. tostring(idx),
                              Merchant.UI.MainFrame)
    value.frame:SetSize(Merchant.UI.BorderFrame:GetWidth() - 2 * margin,
                        Merchant.UI.BorderFrame:GetHeight() - 2 * margin)
    value.frame:SetPoint("TOPLEFT", Merchant.UI.BorderFrame, "TOPLEFT",
                         margin, -margin)
    value.frame:Hide()
    value.FillFrame(value.frame)
  end

  local selectedTab = Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx]
  selectedTab.button:SetText("|cFFFFFFFF" .. L(selectedTab.StringKey))
end

--------------------------------------------------------------------------------

function Merchant.UI.Create()
  Merchant.UI.MainFrame = CreateFrame( "Frame", "MerchantAddonPanel", UIParent)

  if Merchant_Vars.Config.TransparentPanel == true then
    Merchant.UI.MainFrame:SetBackdrop(Merchant.UI.Backdrop.Transparent)
  else
    Merchant.UI.MainFrame:SetBackdrop(Merchant.UI.Backdrop.Black)
  end

 Merchant.UI.MainFrame:SetFrameStrata("DIALOG")
 Merchant.UI.MainFrame:SetPoint("CENTER", 0, 0)
 Merchant.UI.MainFrame:SetSize(700, 500)
 Merchant.UI.MainFrame:SetClampedToScreen(true)
 Merchant.UI.MainFrame:EnableMouse(true)
 Merchant.UI.MainFrame:SetPropagateKeyboardInput(true)
 Merchant.UI.MainFrame:SetScript("OnShow", function(self, button)
   Merchant.UI.PanelShown = true
   Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx].frame:Show()
   Merchant.UI.DrawAuctionsTable(Merchant.UI.SelectedCharacter)
 end)
 Merchant.UI.MainFrame:SetScript("OnHide", function(self, button)
   Merchant.UI.PanelShown = false
 end)
 Merchant.UI.MainFrame:SetMovable(true)
 Merchant.UI.MainFrame:RegisterForDrag("LeftButton")
 Merchant.UI.MainFrame:SetScript("OnDragStart", function(self, button)
   Merchant.UI.MainFrame:StartMoving()
 end)
 Merchant.UI.MainFrame:SetScript("OnDragStop", function(self, button)
   Merchant.UI.MainFrame:StopMovingOrSizing()
 end)
 tinsert(UISpecialFrames, Merchant.UI.MainFrame:GetName())

 texture = Merchant.UI.MainFrame:CreateTexture("$parentHeader", "ARTWORK")
 texture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
 texture:SetSize(185, 68)
 texture:SetPoint("TOP", 0, 12)

 text = Merchant.UI.MainFrame:CreateFontString("$parentHeaderText", "ARTWORK",
                                               "GameFontNormal")
 text:SetPoint("TOP","$parentHeader","TOP",0,-14)
 text:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. "Merchant")

 button = CreateFrame("BUTTON", "$parentCloseButton", Merchant.UI.MainFrame,
                      "UIPanelButtonTemplate")
 button:SetPoint("TOPRIGHT", -10, -10)
 button:SetWidth(25)
 button:SetText("X")
 button:SetScript("OnClick", function(self)
   Merchant.UI.MainFrame:Hide()
 end)

 Merchant.UI.Tabs[1].FillFrame = Merchant.UI.FillAuctionsFrame
 Merchant.UI.Tabs[2].FillFrame = Merchant.UI.FillOptionsFrame

 Merchant.UI.CreateTabs()

 Merchant.UI.CreateMinimapIcon()
end
