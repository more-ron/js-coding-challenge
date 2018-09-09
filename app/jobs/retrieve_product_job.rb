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
    product.data['main_image'] = product_page.css('#imgTagWrapperId img').attr('src').value

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
    sub_categories = value_node.css('ul')

    sub_categories.remove
    ranks << extract_rank_from_string(value_node.text.strip)

    sub_categories.css('li').each do |li|
      ranks << extract_rank_from_string(li.text.strip)
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
    @product_page_html_file ||= open(amazon_product_page_url)
  end

  # @return [String]
  def amazon_product_page_url
    "https://www.amazon.com/dp/#{asin}"
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
