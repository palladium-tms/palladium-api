require_relative '../../tests/test_management'
http = nil
describe 'Product Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end
  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      res_new_product, new_product_name = ProductFunctions.create_new_product(http)
      expect(JSON.parse(res_new_product.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(res_new_product.body)['product']['id'].nil?).to be_falsey
      expect(JSON.parse(res_new_product.body)['product']['name']).to eq(new_product_name)
    end

    it 'check creating new product with correct user_data and correct product_data' do
      res_new_product, new_product_name = ProductFunctions.create_new_product(http)
      expect(JSON.parse(res_new_product.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(res_new_product.body)['product']['id'].nil?).to be_falsey
      expect(JSON.parse(res_new_product.body)['product']['name']).to eq(new_product_name)
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      new_product_name = ProductFunctions.create_new_product(http)[1]
      res_new_product, new_product_name = ProductFunctions.create_new_product(http, new_product_name)
      expect(res_new_product.code).to eq('200')
      expect(JSON.parse(res_new_product.body)['errors'].nil?).to be_truthy
      expect(JSON.parse(res_new_product.body)['product']['id']).to be_truthy
      expect(JSON.parse(res_new_product.body)['product']['name']).to eq(new_product_name)
    end
  end

  describe 'Delete product' do
    it 'check deleting product after product create' do
      res_new_product, = ProductFunctions.create_new_product(http)
      product_id_for_deleting = JSON.parse(res_new_product.body)['product']['id']
      responce = ProductFunctions.delete_product(http, product_id_for_deleting)
      expect(responce.code).to eq('200')
      expect(JSON.parse(responce.body)['product']).to eq(product_id_for_deleting)
      expect(JSON.parse(responce.body)['errors'].empty?).to be_truthy
    end

    it 'delete product with plans' do
      res_new_product, = ProductFunctions.create_new_product(http)
      product_id_for_deleting = JSON.parse(res_new_product.body)['product']['id']
      plan_response = PlanFunctions.create_new_plan(http, product_id: product_id_for_deleting)[0]
      products_before_deleting = JSON.parse(ProductFunctions.get_all_products(http).body)['products']
      product_response = ProductFunctions.delete_product(http, product_id_for_deleting)
      products_after_deleting = JSON.parse(ProductFunctions.get_all_products(http).body)['products']
      show_plan = PlanFunctions.show_plan(http, id: JSON.parse(plan_response.body)['plan']['id'])
      expect(product_response.code).to eq('200')
      expect(JSON.parse(product_response.body)['product']).to eq(product_id_for_deleting)
      expect(products_before_deleting - products_after_deleting).to eq([JSON.parse(res_new_product.body)['product']])
      expect(JSON.parse(product_response.body)['errors'].empty?).to be_truthy
      expect(JSON.parse(show_plan.body)['plan']).to be_nil
    end
  end

  describe 'Get Products' do
    it 'get all products after creating' do
      res_new_product, = ProductFunctions.create_new_product(http)
      response = ProductFunctions.get_all_products(http)
      products = {}
      JSON.parse(response.body)['products'].each do |current_product|
        products.merge!(current_product['id'] => current_product)
      end
      expect(products[JSON.parse(res_new_product.body)['product']['id']]['name']).to eq(JSON.parse(res_new_product.body)['product']['name'])
    end

    it 'get one product | show method' do
      res_new_product, = ProductFunctions.create_new_product(http)
      product_data = JSON.parse(res_new_product.body)
      res_product = ProductFunctions.show_product(http, product_data['product']['id'])
      expect(res_product.code).to eq('200')
      expect(JSON.parse(res_product.body)['product']).to eq(JSON.parse(res_new_product.body)['product'])
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      product_name_for_updating = http.random_name
      product_id = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']['id']
      ProductFunctions.update_product(http, product_id, product_name_for_updating)
      response = ProductFunctions.show_product(http, product_id)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['product']['name']).to eq(product_name_for_updating)
    end
  end
end
