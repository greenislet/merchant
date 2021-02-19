local _, addonTable = ...
local zc = addonTable.zc
local L = Merchant.Locales.GetString

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Grid.EmptyGrid()
  for key, case in pairs(Merchant.UI.Stockpile.Grid.Cases) do
    case.ItemTexture:SetTexture("")
    case.ItemCountText:SetText("")
  end
  Merchant.UI.Stockpile.Grid.CaseCnt = 1
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Grid.Update()
  local stockpile = Merchant.UI.Stockpile.GetFilteredStockpile()
  FauxScrollFrame_Update(Merchant.UI.Stockpile.Grid.ScrollFrame, #stockpile / Merchant.UI.Stockpile.Grid.MaxCasesPerLine, 9, 42);
  local offset = FauxScrollFrame_GetOffset(Merchant.UI.Stockpile.Grid.ScrollFrame)
  Merchant.UI.Stockpile.Grid.EmptyGrid()
  local stop = math.min(#stockpile, 8 * Merchant.UI.Stockpile.Grid.MaxCasesPerLine)
  for i = 1, stop do
    local case = Merchant.UI.Stockpile.Grid.Cases[i]
    local stock = stockpile[i + offset]
    case.ItemTexture:SetTexture(GetItemIcon(stock.ItemID))
    case.ItemCountText:SetText("|cFFFFFFFF" .. tostring(stock.ItemCount))
  end
end

--------------------------------------------------------------------------------

function Merchant.UI.Stockpile.Grid.Fill()
  Merchant.UI.Stockpile.Grid.Frame = CreateFrame("Frame", "$parentGridFrame", Merchant.UI.Stockpile.Frame)
  Merchant.UI.Stockpile.Grid.Frame:SetAllPoints()

  Merchant.UI.Stockpile.Grid.ScrollFrame = CreateFrame("ScrollFrame", "$parentGridScrollFrame", Merchant.UI.Stockpile.Grid.Frame, "FauxScrollFrameTemplate")
  Merchant.UI.Stockpile.Grid.ScrollFrame:SetPoint("TOPLEFT", 0, -42 - 20 - 10)
  Merchant.UI.Stockpile.Grid.ScrollFrame:SetPoint("BOTTOMRIGHT", -10, 5)

  Merchant.UI.Stockpile.Grid.ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 35, Merchant.UI.Stockpile.Grid.Update);
  end)

  local frame = Merchant.UI.Stockpile.Grid.Frame
  for i = 0, 8 * Merchant.UI.Stockpile.Grid.MaxCasesPerLine do
    local x = (32 + 10) * (i % Merchant.UI.Stockpile.Grid.MaxCasesPerLine)
    local y = -10 - 20 - 10 + (-32 - 10) * math.floor(i / Merchant.UI.Stockpile.Grid.MaxCasesPerLine)

    local iconFrame = CreateFrame("Frame", nil, frame)
    iconFrame:SetSize(32, 32)
    iconFrame:SetPoint("TOPLEFT", x, y)
    local itemTexture = iconFrame:CreateTexture(nil, "OVERLAY")
    itemTexture:SetAllPoints()

    local countFrame = CreateFrame("Frame", nil, frame)
    countFrame:SetSize(32, 32)
    countFrame:SetPoint("TOPLEFT", x, y - 9)
    local itemCountText = countFrame:CreateFontString(nil, "OVERLAY")
    itemCountText:SetAllPoints()
    itemCountText:SetFont("Fonts\\FRIZQT__.TTF", 11, "THICKOUTLINE")
    itemCountText:SetJustifyH("RIGHT")

    table.insert(Merchant.UI.Stockpile.Grid.Cases, {
      IconFrame = iconFrame,
      ItemTexture = itemTexture,
      ItemCountFrame = countFrame,
      ItemCountText = itemCountText
    })
  end
end
