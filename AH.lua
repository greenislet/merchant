-- FROM AUCTIONATOR
function Merchant.AH.GetKeyFromItemInfo(replicateItemInfo)
  local name = replicateItemInfo[1]
  local itemId = replicateItemInfo[17]
  --Special case for pets in cages
  if itemId == 82800 then
    if name ~= nil then
      local speciesId, _ = C_PetJournal.FindPetIDByName(name)
      return "p:" .. tostring(speciesId)
    else
      return nil
    end
  else
    return tostring(itemId)
  end
end

--------------------------------------------------------------------------------

function Merchant.AH.ProcessPrices(prices)
  for itemKey, itemPrices in pairs(prices) do
    local minPrice = itemPrices[1]

    for i = 1, #itemPrices do
      if itemPrices[i] < minPrice then
        minPrice = itemPrices[i]
      end
    end

    Merchant_Vars.AHPrices[Merchant.RealmName][itemKey] = minPrice
  end
end

--------------------------------------------------------------------------------

function Merchant.AH.Scan()
  Merchant.Debug("%d item infos", C_AuctionHouse.GetNumReplicateItems())
  prices = {}
  playerAuctions = {}
	for i = 0, C_AuctionHouse.GetNumReplicateItems()-1 do
		auction = {C_AuctionHouse.GetReplicateItemInfo(i)}

		count = auction[3]
		buyoutPrice = auction[10]
		unitPrice = buyoutPrice / count
		key = Merchant.AH.GetKeyFromItemInfo(auction)
    owner = auction[14]
    if owner == Merchant.CharName then
      count = auction[3]
      table.insert(playerAuctions, {
        itemId = key,
        count = count,
        buyout = buyoutPrice
      })
    end
		if prices[key] == nil then
			prices[key] = { unitPrice }
		else
			table.insert(prices[key], unitPrice)
		end
	end

  Merchant.AH.ProcessPrices(prices)
end

--------------------------------------------------------------------------------

function Merchant.AH.FetchPlayerAuctions(frame)
  local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
  local full = C_AuctionHouse.HasFullOwnedAuctionResults()
  if numOwnedAuctions > 0 and full == true then
    Merchant.Debug("registering %d auctions", numOwnedAuctions)
    playerAuctions = {}
    for i = 1, numOwnedAuctions do
      local auction = C_AuctionHouse.GetOwnedAuctionInfo(i)
      local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auction.itemKey)
      local _, _, itemRarity = GetItemInfo(auction.itemKey.itemID)
      table.insert(playerAuctions, {
        ItemID = auction.itemKey.itemID,
        Rarity = itemRarity,
        Quantity = auction.quantity,
        Buyout = auction.buyoutAmount,
        Total = auction.quantity * auction.buyoutAmount,
        Status = auction.status
      })
    end
    Merchant_Vars.Accounts[Merchant.RealmName].Auctions[Merchant.CharName] = playerAuctions
    FrameUtil.UnregisterFrameForEvents(frame, { "OWNED_AUCTIONS_UPDATED" })
  end
end

--------------------------------------------------------------------------------

function Merchant.AH.GetItemMarketValue(itemID)
  local value = Merchant_Vars.AHPrices[Merchant.RealmName][itemID]
  return value
end
