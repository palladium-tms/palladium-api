require_relative '../../tests/test_management'
http = nil
describe 'Product Smoke' do
  before :all do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
  end
  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      product, new_product_name = ProductFunctions.create_new_product(http)
      expect(product.name).to eq(new_product_name)
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      product = ProductFunctions.create_new_product(http)[0]
      new_product, _, code = ProductFunctions.create_new_product(http, product.name)
      expect(code).to eq('200')
      expect(new_product.name).to eq(product.name)
    end
  end

  describe 'Delete product' do
    it 'check deleting product after product create' do
      product, = ProductFunctions.create_new_product(http)
      responce, code = ProductFunctions.delete_product(http, product.id)
      expect(code).to eq('200')
      expect(responce['product']).to eq(product.id)
      expect(responce['errors'].empty?).to be_truthy
    end

    it 'delete product with plans' do
      product, = ProductFunctions.create_new_product(http)
      plan = PlanFunctions.create_new_plan(http, product_id: product.id)[0]
      start_product_pack = ProductFunctions.get_all_products(http)
      product_response, code = ProductFunctions.delete_product(http, product.id)
      end_product_pack = ProductFunctions.get_all_products(http)
      show_plan = PlanFunctions.show_plan(http, id: plan.id)[0]
      expect(code).to eq('200')
      expect(product_response['product']).to eq(product.id)
      expect(start_product_pack.diff(end_product_pack)).to eq([product.id])
      expect(product_response['errors'].empty?).to be_truthy
      expect(show_plan.is_null).to be_truthy
    end
  end

  describe 'Get Products' do
    it 'get all products after creating' do
      res_new_product, = ProductFunctions.create_new_product(http)
      response = ProductFunctions.get_all_products(http)
      response.get_product_by_id(res_new_product.id)
      expect(response.get_product_by_id(res_new_product.id).name).to eq(res_new_product.name)
    end

    it 'get one product | show method' do
      res_new_product, = ProductFunctions.create_new_product(http)
      res_product = ProductFunctions.show_product(http, res_new_product.id)
      expect(res_new_product.like_a?(res_product)).to be_truthy
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      product_name_for_updating = http.random_name
      product = ProductFunctions.create_new_product(http)[0]
      ProductFunctions.update_product(http, product.id, product_name_for_updating)
      product_after_edit = ProductFunctions.show_product(http, product.id)
      expect(product.like_a?(product_after_edit)).not_to be_truthy
      expect(product_after_edit.name).to eq(product_name_for_updating)
    end
  end
end
