module ViewHelper
  def format_address(address)
    formatted = "#{address['address1']}\n"
    formatted += "#{address['address2']}\n" if address['address2']
    formatted += address['city']
    formatted += ", #{address['province_code']}"
    formatted += " #{address['zip']}"
    formatted
  end

  # trimmed down version of ActionView::Helper::TextHelper::simple_format
  # surrounds double newlines in <p> tags and replaces single newlines with <br>
  def simple_format(str)
    newline = str =~ /\r\n/ ? "\r\n" : "\n"
    paragraphs = str.split(newline + newline)
    paragraphs.map{|s| "<p>#{s.gsub("\n", "<br>")}</p>"}.join
  end
end
