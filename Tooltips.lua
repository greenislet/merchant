local _, addonTable = ...
local zc = addonTable.zc

local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.Tooltips.ShowPriceInTooltip(tooltip, link, count)
  local key = Merchant.Utils.ItemKeyFromLink(link)
  local price = Merchant_Vars.AHPrices[Merchant.RealmName][key]
  local show = false
  if price ~= nil then
    tooltip:AddDoubleLine("|cFF" .. Merchant.Constants.UI.MAIN_COLOR
      .. L("AH_PRICE"), "|cFFFFFFFF" .. zc.priceToMoneyString(price, true))
    show = true
    if count ~= nil and count > 1 then
      tooltip:AddDoubleLine("|cFF" .. Merchant.Constants.UI.MAIN_COLOR
        .. L("AH_TOTAL"), "|cFFFFFFFF"
        .. zc.priceToMoneyString(count * price, true))
    end
  end

  if show == true then
    tooltip:Show()
  end
end

--------------------------------------------------------------------------------

-- FROM AUCTIONATOR

function Merchant.Tooltips.hookAH()
  hooksecurefunc(AuctionHouseUtil, "SetAuctionHouseTooltip",
    function(owner, rowData)
      if rowData.itemLink then
        Merchant.Tooltips.ShowPriceInTooltip(GameTooltip, rowData.itemLink, nil)
      else
        local itemLink = select(2, GetItemInfo(rowData.itemKey.itemID))
        if itemLink ~= nil then
          Merchant.Tooltips.ShowPriceInTooltip(GameTooltip, itemLink, nil)
        end
      end
    end
  )
end

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetBagItem",
  function(tip, bag, slot)
		local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
		if itemLocation:IsValid() then
			local itemLink = C_Item.GetItemLink(itemLocation)
      local itemCount = C_Item.GetStackCount(itemLocation)
      Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
		end
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetBuybackItem",
  function(tip, slotIndex)
    local itemLink = GetBuybackItemLink(slotIndex)
    local _, _, _, itemCount = GetBuybackItemInfo(slotIndex);
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetMerchantItem",
  function(tip, index)
    local itemLink = GetMerchantItemLink(index)
    local _, _, _, itemCount = GetMerchantItemInfo(index);
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetInventoryItem",
  function(tip, unit, slot)
    local itemLink = GetInventoryItemLink(unit, slot)
    local itemCount = GetInventoryItemCount(unit, slot)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function(tip, tab, slot)
    local itemLink = GetGuildBankItemLink(tab, slot)
    local _, itemCount = GetGuildBankItemInfo(tab, slot)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc( GameTooltip, 'SetRecipeResultItem',
  function(tip, recipeResultItemId)
    local itemLink = C_TradeSkillUI.GetRecipeItemLink(recipeResultItemId)
    local itemCount
      = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeResultItemId)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc( GameTooltip, 'SetRecipeReagentItem',
  function( tip, reagentId, index )
    local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(reagentId, index)
    local itemCount
      = select(3, C_TradeSkillUI.GetRecipeReagentInfo(reagentId, index))
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetLootItem",
  function (tip, slot)
    if LootSlotHasItem(slot) then
      local itemLink, _, itemCount = GetLootSlotLink(slot)
      Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
    end
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetLootRollItem",
  function (tip, slot)
    local itemLink = GetLootRollItemLink(slot)
    local _, _, itemCount = GetLootRollItemInfo(slot)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetQuestItem",
  function (tip, type, index)
    local itemLink = GetQuestItemLink(type, index)
    local _, _, itemCount = GetQuestItemInfo(type, index);
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetQuestLogItem",
  function (tip, type, index)
    local itemLink = GetQuestLogItemLink(type, index)
    local itemCount;
    if type == "choice" then
      _, _, itemCount = GetQuestLogChoiceInfo(index);
    else
      _, _, itemCount = GetQuestLogRewardInfo(index)
    end
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetSendMailItem",
  function (tip, id)
    local _, _, _, itemCount = GetSendMailItem(id)
    local itemLink = GetSendMailItemLink(id)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetInboxItem",
  function(tip, index, attachIndex)
    local attachmentIndex = attachIndex or 1
    local itemLink = GetInboxItemLink(index, attachmentIndex)
    local _, _, _, itemCount = GetInboxItem(index, attachmentIndex);
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc(ItemRefTooltip, "SetHyperlink",
  function(tip, itemstring)
    local _, itemLink = GetItemInfo(itemstring)
    Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, nil)
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetTradePlayerItem",
  function (tip, id)
    local itemLink = GetTradePlayerItemLink(id)
    if itemLink ~= nil then
      local _, _, itemCount = GetTradePlayerItemInfo(id);
      Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
    end
  end
)

--------------------------------------------------------------------------------

hooksecurefunc (GameTooltip, "SetTradeTargetItem",
  function (tip, id)
    local itemLink = GetTradeTargetItemLink(id)
    if itemLink ~= nil then
      local _, _, itemCount = GetTradeTargetItemInfo(id)
      Merchant.Tooltips.ShowPriceInTooltip(tip, itemLink, itemCount)
    end
  end
)
