require 'net/http'
require 'json'
class ProductFunctions
  # @param [String] name name for product. Max size = 30 simbols. If it empty - will be generate
  # return array with request and product name [request, product_name]
  def self.create_new_product(token, product_name = nil)
    product_name = 30.times.map { StaticData::ALPHABET.sample }.join if product_name.nil?
    request = Net::HTTP::Post.new('/api/product_new', 'Authorization' => token)
    request.set_form_data({"product_data[name]": product_name})
    [request, product_name]
  end

  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def self.get_all_products(token)
    url = URI.parse(StaticData::MAINPAGE + '/api/products')
    req = Net::HTTP::Get.new(url.path)
    req[:Authorization] = token
    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end
    result = {}
    JSON.parse(res.body)['products'].each do |current_product|
      result.merge!({current_product['id'] => current_product})
    end
    result
  end

  # @param [Integer] id is a id of product for deleting
  # return hash which keys - id of product, values - is a hash {'name': 'product_name'}
  def self.delete_product(token, id)
    request = Net::HTTP::Post.new('/api/product_delete', 'Authorization' => token)
    request.set_form_data({"product_data[id]": id})
    request
  end

  # @param [Hash] product_data like a {:id => product_id, :name => product_name}
  def self.update_product(token, product_data)
    request = Net::HTTP::Post.new('/api/product_edit', 'Authorization' => token)
    request.set_form_data({"product_data[id]": product_data[:id], "product_data[name]": product_data[:name]})
    request
  end

  # @param [Integer] id is a id of product for deleting
  def self.show_product(token, id)
    uri = URI(StaticData::MAINPAGE + '/product')
    uri.query = URI.encode_www_form({"product_data[id]": id})
    result = JSON.parse(Net::HTTP.get_response(uri).body)
    if result['product'].empty?
      {'product': [], 'errors': result['errors']}
    else
      {id: result['product']['id'], name: result['product']['name'], created_at: result['product']['created_at'], updated_at: result['product']['updated_at']}
    end
  end
end