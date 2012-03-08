require 'open-uri'

module YrForecast
  include Radiant::Taggable
  include ActionView::Helpers::DateHelper

  VERSION = 0.1
  
  def fetch_xml(uri, cache_time)
    path = File.join(ActionController::Base.page_cache_directory, uri.tr(':/','_'))
    contents = ""
    begin
      contents = File.read(path)
      timestamp = File.mtime(path)
      since = timestamp.httpdate
    rescue
      uri = URI.parse(uri)
      agent = "RadiantCMS yr_forecast Extension #{VERSION}"
      begin
        extra_headers = {"If-Modified-Since" => since, 'User-Agent' => agent}
        open(uri, extra_headers) {|f| contents = f.read }
      rescue
      end
    end
    contents
  end

  def cache?
    false
  end

  tag "yr_forecast" do |tag|
    tag.expand
  end

  desc %{
    Retrieves a forecast from the specified uri, expecting it to match
    the format of yr.com.
    
    Optional attributes:
    * @cache_time@: length of time to cache the feed before seeing if it's been updated
    * @num_days@: how many days to show
    
    *Usage:*

    <pre><code>
      <r:yr_forecast url="http://www.yr.no/place/Norway/Akershus/B%C3%A6rum/Lysaker/forecast.xml" [cache_time="3600"] />
    </code></pre>
  }
  tag "yr_forecast" do |tag|
    attr = tag.attr.symbolize_keys
    result = []

    begin
      items = fetch_rss(attr[:url], attr[:cache_time].to_i || 900).items
    rescue
      return "<!-- RssReader error: #{$!} -->"
    end

    items = sql_sort(items, attr[:order]) if attr[:order]
    items = items.slice(0, attr[:limit].to_i) if attr[:limit]

    attr[:matching] = Regexp.new(attr[:matching]) if attr[:matching]
    last_item = nil
    items.each do |item|
      next if attr[:matching] and !item.to_s.match(attr[:matching])
    	tag.locals.item = item
    	tag.locals.last_item = last_item if last_item
      result << tag.expand
      last_item = item
    end

    result
  end
end
