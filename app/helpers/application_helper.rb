module ApplicationHelper
  def locale_switcher
    res = []
    I18n.available_locales.each do |locale|
      res << link_to_if(I18n.locale != locale, "#{locale}", locale: locale)
    end
    res.join(' | ').html_safe
  end
end
