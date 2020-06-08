local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", Merchant.onEvent)

SLASH_MERCHANT1 = "/merchant"

SlashCmdList["MERCHANT"] = function(msg, editbox)
  if Merchant_Settings.debug == false then
    Merchant_Settings.debug = true
    Merchant.print("DEBUG_MODE_ENABLED")
  else
    Merchant_Settings.debug = false
    Merchant.print("DEBUG_MODE_DISABLED")
  end
end
