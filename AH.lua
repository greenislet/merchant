-- FROM AUCTIONATOR
function Merchant.AH.getKeyFromItemInfo(replicateItemInfo)
  local name = replicateItemInfo[1]
  local itemId = replicateItemInfo[17]
  --Special case for pets in cages
  if itemId==82800 then
    if name~=nil then
      local speciesId, _ = C_PetJournal.FindPetIDByName(name)
      return "p:"..tostring(speciesId)
    else
      return nil
    end
  else
    return tostring(itemId)
  end
end

function Merchant.AH.processPrices(prices)
  for itemKey, itemPrices in pairs(prices) do
    local minPrice = itemPrices[1]

    for i = 1, #itemPrices do
      if itemPrices[i] < minPrice then
        minPrice = itemPrices[i]
      end
    end

    Merchant_Prices[itemKey] = minPrice
  end
end

function Merchant.AH.scan()
  Merchant.debug("%d item infos", C_AuctionHouse.GetNumReplicateItems())
  prices = {}
	for i = 0, C_AuctionHouse.GetNumReplicateItems()-1 do
		auction = {C_AuctionHouse.GetReplicateItemInfo(i)}

		count = auction[3]
		buyoutPrice = auction[10]
		unitPrice = buyoutPrice / count
		key = Merchant.AH.getKeyFromItemInfo(auction)
    if key == nil then
      Merchant.debug("key from item info is nil")
    end
		if prices[key] == nil then
			prices[key] = { unitPrice }
		else
			table.insert(prices[key], unitPrice)
		end
	end
  return prices
end
