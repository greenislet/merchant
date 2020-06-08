function Merchant.print(key, ...)
  str = Merchant.Locales.getString(key)

  print(format("|c" .. Merchant.Constants.MAIN_COLOR .. "Merchant: "..str, ...))
end

function Merchant.debug(str, ...)
	if Merchant_Settings.debug == false then
		return
	end
	print(format("|c" .. Merchant.Constants.DEBUG_COLOR .. "Merchant: " .. str, ...))
end

 local function initPersistentVars()
   if Merchant_LastScanTime == nil then
     Merchant_LastScanTime = 0
   end
   if Merchant_Prices == nil then
     Merchant_Prices = {}
   end
   if Merchant_Settings == nil then
     Merchant_Settings = {
       debug = false
     }
   end
 end

local function printNextScan()
  nbSec = 15 * 60 - (time() - Merchant_LastScanTime)
  if nbSec / 60 ~= 0 then
    Merchant.print("NEXT_SCAN", nbSec / 60, nbSec % 60)
  else
    Merchant.print("NEXT_SCAN_SECONDS", nbSec)
  end
end

local handlers = {
  ["AUCTION_HOUSE_SHOW"] = function(frame)
    Merchant.debug("AH opened")
    if time() - Merchant_LastScanTime > 15 * 60 then
		  C_AuctionHouse.ReplicateItems()
		  Merchant.print("UPDATED_AH")
      Merchant_LastScanTime = time()
      FrameUtil.RegisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
    else
      printNextScan()
    end
    Merchant.Tooltips.hookAH()
    FrameUtil.UnregisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_CLOSED" })
  end,

  ["REPLICATE_ITEM_LIST_UPDATE"] = function(frame)
    prices = Merchant.AH.scan()
    Merchant.AH.processPrices(prices)
    Merchant.print("DONE_SCANNING")
    FrameUtil.UnregisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
  end,


  ["ADDON_LOADED"] = function(frame)
    initPersistentVars()
    Merchant.debug("loaded")
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
		FrameUtil.UnregisterFrameForEvents(frame, {"ADDON_LOADED"})
  end,


  ["AUCTION_HOUSE_CLOSED"] = function(frame)
    Merchant.debug("AH closed")
    FrameUtil.RegisterFrameForEvents(frame, { "AUCTION_HOUSE_SHOW" })
    FrameUtil.UnregisterFrameForEvents(frame, { "AUCTION_HOUSE_CLOSED" })
    FrameUtil.UnregisterFrameForEvents(frame, { "REPLICATE_ITEM_LIST_UPDATE" })
  end,
}

function Merchant.onEvent(frame, event)
  handlers[event](frame)
end
