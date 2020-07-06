function Merchant.Locales.GetStrings(localeStr)
  strings = Merchant.Locales[localeStr]
  if strings ~= nil then
    return localeStr, strings
  end
  return "enUS", Merchant.Locales["enUS"]
end

--------------------------------------------------------------------------------

function Merchant.Locales.GetString(key)
  locale, strings = Merchant.Locales.GetStrings(GetLocale())
  str = strings[key]
  if str == nil then
    locale, strings = Merchant.Locales.GetStrings("enUS")
    if strings == nil then
      return "missing default locale"
    end
    str = strings[key]
    if str == nil then
      return "missing locale"
    end
  end
  return str
end
