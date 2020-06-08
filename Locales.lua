function Merchant.Locales.getStrings(localeStr)
  strings = Merchant.Locales[localeStr]
  if strings ~= nil then
    return localeStr, strings
  end
  return "enUS", Merchant.Locales["enUS"]
end

function Merchant.Locales.getString(key)
  locale, strings = Merchant.Locales.getStrings(GetLocale())
  str = strings[key]
  if str == nil then
    locale, strings = Merchant.Locales.getStrings("enUS")
    str = strings[key]
    if str == nil then
      return "missing locale"
    end
  end
  return str
end
