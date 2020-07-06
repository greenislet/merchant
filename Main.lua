local f = CreateFrame("Frame", "MerchantAddon", UIParent)

f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", Merchant.OnEvent)
