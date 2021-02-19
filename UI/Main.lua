local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.CreateMinimapIcon()
  if LibStub("LibDataBroker-1.1", true) then
    dataBroker = LibStub("LibDataBroker-1.1"):NewDataObject("Merchant", {type = "launcher", label = "Merchant", icon = "Interface/Icons/Inv_misc_bag_10"})

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
      GameTooltip:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. "Merchant")
	    GameTooltip:AddLine("|cFFFFFFFFversion " .. Merchant.Constants.VERSION)
      GameTooltip:AddLine("")
      GameTooltip:AddDoubleLine("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("LEFT_CLICK"), "|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("LEFT_CLICK_EXPLANATION"))
    end
  end

  if LibStub("LibDBIcon-1.0", true) then
    LibStub("LibDBIcon-1.0"):Register("Merchant", dataBroker, Merchant_Vars.Minimap)
  end

  LibStub("LibDBIcon-1.0"):Show("Merchant")
end

--------------------------------------------------------------------------------

function Merchant.UI.ShortenNameWidget(nameWidget)
  local pixelLimit = 237
  local charLimit = 30
  local itemName = nameWidget:GetText()
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

  if nameWidget:GetWidth() > pixelLimit then
    ReduceText(nameWidget, itemName, charLimit, offset, false)
    if nameWidget:GetWidth() < pixelLimit then
      local previous = nameWidget:GetText()
      while true == true do
        ReduceText(nameWidget, itemName, charLimit, offset, true)
        if nameWidget:GetWidth() > pixelLimit then
          break
        end
        offset = offset + 1
        previous = nameWidget:GetText()
      end
      nameWidget:SetText(previous)
      local leftPart, rightPart = SplitText(itemName, charLimit, offset, false)
      local points = "..."
      while true == true do
        points = points .. "."
        nameWidget:SetText(leftPart .. points .. rightPart)
        if nameWidget:GetWidth() > pixelLimit then
          break
        end
        previous = nameWidget:GetText()
      end
      nameWidget:SetText(previous)
    end
  end
end

--------------------------------------------------------------------------------


function Merchant.UI.SelectTab(tabIdx)
  selectedTab = Merchant.UI.Tabs[tabIdx]
  previousTab = Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx]
  previousTab.button:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. L(previousTab.StringKey))
  previousTab.frame:Hide()
  selectedTab.button:SetText("|cFFFFFFFF" .. L(selectedTab.StringKey))
  selectedTab.Draw()
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

  Merchant.UI.BorderFrame = CreateFrame("Frame", "$parentBorderFrame", Merchant.UI.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
  Merchant.UI.BorderFrame:SetBackdrop(Merchant.UI.Backdrop.Thin)
  Merchant.UI.BorderFrame:SetSize(Merchant.UI.MainFrame:GetWidth() - 2 * margin, Merchant.UI.MainFrame:GetHeight() - 30 - buttonHeight - 1 * margin)
  Merchant.UI.BorderFrame:SetPoint("TOPLEFT", Merchant.UI.MainFrame, "TOPLEFT", margin, -30 - buttonHeight)

  local x = 0
  for idx, value in ipairs(Merchant.UI.Tabs) do
    local tabButton = CreateFrame("Button", "$parentTabButton" .. tostring(idx), Merchant.UI.MainFrame, "OptionsFrameTabButtonTemplate")
    tabButton:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. L(value.StringKey))
    tabButton:SetPoint("TOPLEFT", margin + x, y)
    tabButton.name = value.StringKey
    value.button = tabButton
    tabButton:SetScript("OnClick", Merchant.UI.OnTabButtonClick)
    x = x + tabButton:GetTextWidth() + 20

    value.frame = CreateFrame("Frame", "$parentContentFrame" .. tostring(idx), Merchant.UI.MainFrame)
    value.frame:SetSize(Merchant.UI.BorderFrame:GetWidth() - 2 * margin, Merchant.UI.BorderFrame:GetHeight() - 2 * margin)
    value.frame:SetPoint("TOPLEFT", Merchant.UI.BorderFrame, "TOPLEFT", margin, -margin)
    value.frame:Hide()
    value.FillFrame(value.frame)
  end

  local selectedTab = Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx]
  selectedTab.button:SetText("|cFFFFFFFF" .. L(selectedTab.StringKey))
end

--------------------------------------------------------------------------------

function Merchant.UI.Create()
  Merchant.UI.MainFrame = CreateFrame("Frame", "MerchantAddonPanel", UIParent, BackdropTemplateMixin and "BackdropTemplate")

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
   Merchant.UI.Tabs[Merchant_Vars.UI.SelectedTabIdx].Draw()
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

 local texture = Merchant.UI.MainFrame:CreateTexture("$parentHeader", "ARTWORK")
 texture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
 texture:SetSize(185, 68)
 texture:SetPoint("TOP", 0, 12)

 local text = Merchant.UI.MainFrame:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormal")
 text:SetPoint("TOP","$parentHeader","TOP",0,-14)
 text:SetText("|cFF" .. Merchant.Constants.UI.MAIN_COLOR .. "Merchant")

 local button = CreateFrame("BUTTON", "$parentCloseButton", Merchant.UI.MainFrame, "UIPanelButtonTemplate")
 button:SetPoint("TOPRIGHT", -10, -10)
 button:SetWidth(25)
 button:SetText("X")
 button:SetScript("OnClick", function(self)
   Merchant.UI.MainFrame:Hide()
 end)

 table.insert(Merchant.UI.Tabs, {StringKey = "TAB_AUCTIONS", FillFrame = Merchant.UI.Auctions.Fill, Draw = Merchant.UI.Auctions.Draw})
 table.insert(Merchant.UI.Tabs, {StringKey = "TAB_STOCKPILE", FillFrame = Merchant.UI.Stockpile.Fill, Draw = Merchant.UI.Stockpile.Draw})
 -- table.insert(Merchant.UI.Tabs, {StringKey = "TAB_PRICES", FillFrame = Merchant.UI.Prices.Fill, Draw = Merchant.UI.Prices.Draw})
 table.insert(Merchant.UI.Tabs, {StringKey = "TAB_OPTIONS", FillFrame = Merchant.UI.Options.Fill, Draw = Merchant.UI.Options.Draw})

 Merchant.UI.CreateTabs()

 Merchant.UI.CreateMinimapIcon()
end
