require 'yr_forecast'

class YrForecastExtension < Radiant::Extension
  version VERSION
  description "This extension lets you display forecasts from yr.no on your pages."
  url "https://github.com/cayblood/radiant-yr-forecast"
  
  def activate
    cache_dir = ActionController::Base.page_cache_directory
    Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
    Page.send :include, YrForecast
  end
  
  def deactivate
  end
end