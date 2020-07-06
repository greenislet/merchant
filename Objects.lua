Merchant = {
  Locales = {},
  AH = {},
  Utils = {},
  Constants = {},
  Tooltips = {
    AHHooked = false
  },
  UI = {
    Backdrop = {
      Black = {
        bgFile = "Interface\\AddOns\\Merchant\\images\\black.tga",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", tile = true,
          tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 11, top = 12, bottom = 10 }
      },
      Transparent = {
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", tile = true,
          tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 11, top = 12, bottom = 10 }
      },
      Thin = {
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
      }
    },
    Tabs = {
      [1] = {
          StringKey = "TAB_AUCTIONS"
      },
      [2] = {
          StringKey = "TAB_OPTIONS"
      }
    },
    AuctionRows = {},
    AuctionRowCnt = 1
  }
}
