local _, addonTable = ...
local zc = addonTable.zc

local L = Merchant.Locales.getString

local function showPriceInTooltip(tooltip, link)
  local key = Merchant.Utils.itemKeyFromLink(link)
  local price = Merchant_Prices[key]
  if price ~= nil then
    tooltip:AddDoubleLine("|c" .. Merchant.Constants.MAIN_COLOR .. L("AH_PRICE"), "|cffffffff" .. zc.priceToMoneyString(price, true))
    tooltip:Show()
  end
end

hooksecurefunc (GameTooltip, "SetBagItem",
  function(tip, bag, slot)
		local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
		if itemLocation:IsValid() then
			local itemLink = C_Item.GetItemLink(itemLocation)
      showPriceInTooltip(tip, itemLink)
		end
  end
)

hooksecurefunc (GameTooltip, "SetBuybackItem",
  function(tip, slotIndex)
    local itemLink = GetBuybackItemLink(slotIndex)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetMerchantItem",
  function(tip, index)
    local itemLink = GetMerchantItemLink(index)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetInventoryItem",
  function(tip, unit, slot)
    local itemLink = GetInventoryItemLink(unit, slot)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function(tip, tab, slot)
    local itemLink = GetGuildBankItemLink(tab, slot)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc( GameTooltip, 'SetRecipeResultItem',
  function(tip, recipeResultItemId)
    local itemLink = C_TradeSkillUI.GetRecipeItemLink(recipeResultItemId)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc( GameTooltip, 'SetRecipeReagentItem',
  function( tip, reagentId, index )
    local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(reagentId, index)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetLootItem",
  function (tip, slot)
    if LootSlotHasItem(slot) then
      local itemLink, _, itemCount = GetLootSlotLink(slot)
      showPriceInTooltip(tip, itemLink)
    end
  end
)

hooksecurefunc (GameTooltip, "SetLootRollItem",
  function (tip, slot)
    local itemLink = GetLootRollItemLink(slot)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetQuestItem",
  function (tip, type, index)
    local itemLink = GetQuestItemLink(type, index)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetQuestLogItem",
  function (tip, type, index)
    local itemLink = GetQuestLogItemLink(type, index)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetSendMailItem",
  function (tip, id)
    local itemLink = GetSendMailItemLink(id)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetInboxItem",
  function(tip, index, attachIndex)
    local attachmentIndex = attachIndex or 1
    local itemLink = GetInboxItemLink(index, attachmentIndex)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc(ItemRefTooltip, "SetHyperlink",
  function(tip, itemstring)
    local _, itemLink = GetItemInfo(itemstring)
    showPriceInTooltip(tip, itemLink)
  end
)

hooksecurefunc (GameTooltip, "SetTradePlayerItem",
  function (tip, id)
    local itemLink = GetTradePlayerItemLink(id)
    if itemLink ~= nil then
      showPriceInTooltip(tip, itemLink)
    end
  end
)

hooksecurefunc (GameTooltip, "SetTradeTargetItem",
  function (tip, id)
    local itemLink = GetTradeTargetItemLink(id)
    if itemLink ~= nil then
      showPriceInTooltip(tip, itemLink)
    end
  end
)

local called = false

function Merchant.Tooltips.hookAH()
  if called == true then
    return
  end
  called = true
  hooksecurefunc(AuctionHouseUtil, "SetAuctionHouseTooltip",
    function(owner, rowData)
      if rowData.itemLink then
        showPriceInTooltip(GameTooltip, rowData.itemLink)
      else
        local itemLink = select(2, GetItemInfo(rowData.itemKey.itemID))
        if itemLink ~= nil then
          showPriceInTooltip(GameTooltip, itemLink)
        end
      end
    end
  )
end
