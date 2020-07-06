-- FROM AUCTIONATOR
function Merchant.Utils.ItemKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    if itemString ~= nil then
      local linkType, itemId, _, _, _, _, _, _, _ = strsplit(":", itemString)
      if linkType == "battlepet" then
        return "p:"..itemId
      elseif linkType == "item" then
        return itemId
      end
    end
  end
  return nil
end

--------------------------------------------------------------------------------

-- FROM AUCTIONATOR
function Merchant.Utils.RemoveColor(text)
  return gsub(gsub(text, "|c........", ""), "|r", "")
end

--------------------------------------------------------------------------------

function Merchant.Utils.GetPrettyCharacterName(charName)
  local charClass = Merchant_Vars.Characters[Merchant.RealmName][charName].Class
  local classColor = Merchant.Constants.UI.CLASS_COLORS[charClass]
  return "|cFF" .. classColor .. charName
end
