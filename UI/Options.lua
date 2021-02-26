local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Options.Draw()
  Merchant.UI.Options.Frame:Show()
end

--------------------------------------------------------------------------------

function Merchant.UI.Options.Fill(frame)
  Merchant.UI.Options.Frame = frame

  local y = 0
  local fontString = frame:CreateFontString("$parentTransparentPanelText", "ARTWORK", "GameFontNormal")
  fontString:SetPoint("TOPLEFT")
  fontString:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("OPTION_TRANSPARENT_PANEL"))

  local checkBox = CreateFrame("CheckButton", "$parentTransparentPanelCheckButton", frame, "ChatConfigCheckButtonTemplate")
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
  fontString = frame:CreateFontString("$parentDebugModeText", "ARTWORK", "GameFontNormal")
  fontString:SetPoint("TOPLEFT", 0, -y)
  fontString:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("OPTION_DEBUG_MODE"))

  checkBox = CreateFrame("CheckButton", "$parentDebugModeCheckButton", frame, "ChatConfigCheckButtonTemplate")
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

  y = y + 30
  fontString = frame:CreateFontString("$parentAutoscanText", "ARTWORK", "GameFontNormal")
  fontString:SetPoint("TOPLEFT", 0, -y)
  fontString:SetText("|cFF" .. Merchant.Constants.UI.SECOND_COLOR .. L("OPTION_AUTOSCAN"))

  checkBox = CreateFrame("CheckButton", "$parentAutoscanCheckButton", frame, "ChatConfigCheckButtonTemplate")
  checkBox:SetSize(40, 40)
  checkBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10 - y)
  checkBox:SetChecked(Merchant_Vars.Config.Autoscan)
  checkBox:SetScript("OnClick", function(self)
    if self:GetChecked() == true then
      Merchant_Vars.Config.Autoscan = true
    else
      Merchant_Vars.Config.Autoscan = false
    end
  end)

  y = y + 30
  local button = CreateFrame("Button", "$parentForceScanButton", frame, "UIPanelButtonTemplate")
  button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 5, 5 - y)
  button:SetSize(180, 30)
  button:SetText("Reset autoscan cooldown")
  button:SetScript("OnClick", function(self)
    Merchant_Vars.LastScanTime = time() - 15 * 60
  end)
end
