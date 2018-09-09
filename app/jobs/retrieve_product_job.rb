require 'open-uri'

class RetrieveProductJob < ApplicationJob
  queue_as :default

  rescue_from OpenURI::HTTPError, with: :handle_source_error

  # @param [String] asin
  def perform(asin)
    @asin = asin

    product.raw_html = product_page_html
    process_product_detail
    product.update! not_found: false, last_updated_at: Time.current
  end

  private

  attr_reader :asin

  # @return [Product]
  def product
    @product ||= Product.find_or_initialize_by asin: asin
  end

  def process_product_detail
    product.data['name'] = product_page.css('#productTitle').text.strip
    img = product_page.css('#imgTagWrapperId img')
    product.data['main_image'] = img.attr('src').value if img.present?

    product_details = product_details_rows.map do |row|
      label = row.css('td.label,th').text.strip

      {
        'label' => label,
        'value' => value_for(label, row: row)
      }
    end

    product.data['product_details'] = product_details

    ranks = product_details.find { |item| item['label'] == ranks_label }

    if ranks.present?
      product.data['main_category'] = ranks['value'].first['category']
      product.data['rankings'] = ranks['value']
    end
  end

  # @param [String] label
  # @param [Nokogiri::XML::NodeSet] row
  def value_for(label, row:)
    value_node = row.css('td.value,td:last-child')

    case label
    when ranks_label
      extract_ranks_from_node(value_node)
    else
      value_node.text.gsub(/[\n\r\s ]+/, ' ').strip
    end
  end

  def ranks_label
    'Best Sellers Rank'
  end

  def extract_ranks_from_node(value_node)
    ranks = []
    sub_categories = value_node.css('ul li,span span')

    sub_categories.remove

    left_over = value_node.text.strip

    if left_over.present?
      ranks << extract_rank_from_string(left_over)
    end

    sub_categories.each do |item|
      ranks << extract_rank_from_string(item.text.strip)
    end

    ranks
  end

  def extract_rank_from_string(string)
    match = /\A\#(.*)[\n\r\s ]+in[\n\r\s ]+(.*?)([\n\r\s ]+\(See top.*\))?\z/.match(string)

    {
      'rank' => match[1],
      'category' => match[2]
    }
  end

  def product_details_rows
    @product_details_rows ||= product_page.css('#prodDetails table tr')
  end

  # @return [Nokogiri::HTML::Document]
  def product_page
    @product_page ||= Nokogiri::HTML(product.raw_html)
  end

  # @return [String]
  def product_page_html
    @product_page_html ||= product_page_html_file.read
  end

  # @return [Tempfile]
  def product_page_html_file
    @product_page_html_file ||= open(
      amazon_product_page_url,
      'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'accept-language' => 'en-US,en;q=0.9',
      'cookie' => amazon_cookie,
      'referer' => Rails.cache.fetch('amazon-referer') { amazon_product_page_url },
      'upgrade-insecure-requests' => '1',
      'user-agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
    )
  ensure
    # NOTE: Try and fool Amazon into thinking it's not a scraper.
    Rails.cache.write('amazon-referer', amazon_product_page_url)

    if @product_page_html_file.present?
      set_cookie = @product_page_html_file.meta['set-cookie']

      if set_cookie
        Rails.cache.write('amazon-cookie', [amazon_cookie, set_cookie.split('; ', 2)[0]].join('; '))
      end
    end
  end

  def amazon_cookie
    Rails.cache.fetch('amazon-cookie') do
      'session-id=142-3890860-1146932; session-id-time=2082787201l; x-wl-uid=1BtZAYdZJiS8rhY0b2cLGjZAdbkvckhleAxU2ub1lfhDzgTZb4aotL//F4fZ8WjYJsIREPagMqnw=; ubid-main=132-9770205-5722210; session-token=KT6ZvaimgH7yPrylXxUaMkreSgj1YSYl5Aw1XxejfpHIgACnkIlnItKIGe+kxV/XpslRhpS/kOCz3c26GzEBiXyYXvZvLQUvLPniB5eQKWYQQPfxtbgs6S6r3W4oiVvRYjly5TFymtX7Dq2BL7pHreZuTGR/0ZLWFT4vxpQTFZ2H9coZqAM7+Qo8OwBVuBgI28fvYdtg+0UjpuBln9Lz+Ur8ROqWlbSP2xYAXI/tRN0oe3lPnrUowZbMcf0sXRMO; csm-hit=tb:s-J3JXKP3BEPE7PNXS5ZTA|1536472201902&adb:adblk_no'
    end
  end

  # @return [String]
  def amazon_product_page_url
    @amazon_product_page_url ||= "https://www.amazon.com/dp/#{asin}"
  end

  # Warning: If there are more than one external request done for this job please make changes to
  #          cover the scenario. Make the original handling specific to request to Amazon only.
  def handle_source_error(exception)
    if exception.io.status == ["404", "Not Found"]
      product.update! not_found: true, last_updated_at: Time.current
    else
      raise
    end
  end
end
