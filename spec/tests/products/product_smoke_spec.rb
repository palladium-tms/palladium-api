require_relative '../../tests/test_management'
describe 'Product Smoke' do
  before :each do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      product = @user.create_new_product
      expect(product.product_errors).to be_nil
      expect(product.id).not_to be_nil
    end

    it 'check creating new product with correct user_data and exists correct product_data' do
      product = @user.create_new_product
      product_2 = @user.create_new_product(product.name)
      expect(product_2.response.code).to eq('200')
      expect(product_2.name).to eq(product.name)
    end
  end

  describe 'Delete product' do
    it 'check deleting product after product create' do
      product = @user.create_new_product
      response = @user.delete_product(product.id)
      expect(response.code).to eq('200')
      JSON.parse(response.body)
      expect(JSON.parse(response.body)['product']).to eq(product.id)
      expect(JSON.parse(response.body)['errors'].empty?).to be_truthy
    end

    it 'delete product with plans' do
      product = @user.create_new_product
      plan = @user.create_new_plan(product_id: product.id)
      start_product_pack = @user.get_all_products
      product_response = @user.delete_product(product.id)
      end_product_pack = @user.get_all_products
      show_plan = @user.show_plan(id: plan.id)
      expect(product_response.code).to eq('200')
      expect(JSON.parse(product_response.body)['product']).to eq(product.id)
      expect(JSON.parse(product_response.body)['errors']).to be_empty
      expect(start_product_pack.diff(end_product_pack)).to eq([product.id])
      expect(show_plan.is_null).to be_truthy
    end
  end

  describe 'Get Products' do
    it 'get all products after creating' do
      product = @user.create_new_product
      all_product = @user.get_all_products
      expect(all_product.get_product_by_id(product.id).name).to eq(product.name)
    end

    it 'get one product | show method' do
      res_new_product = @user.create_new_product
      res_product = @user.show_product(res_new_product.id)
      expect(res_new_product.like_a?(res_product)).to be_truthy
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      new_name = rand_product_name
      product = @user.create_new_product
      @user.update_product(product.id, new_name)
      product_after_edit = @user.show_product(product.id)
      expect(product.like_a?(product_after_edit)).not_to be_truthy
      expect(product_after_edit.name).to eq(new_name)
    end
  end

  describe 'Last Plan' do
    it 'new product without plans' do
      product = @user.create_new_product
      expect(product.product_errors).to be_nil
      expect(product.id).not_to be_nil
      expect(product.last_plan).to be_nil
      end

    it 'new product with plans' do
      product_new = @user.create_new_product
      plan = @user.create_new_plan({product_id: product_new.id})
      product = @user.get_all_products.get_product_by_id(product_new.id)
      expect(product.product_errors).to be_nil
      expect(product.id).not_to be_nil
      expect(plan.product_id).to eq(product.last_plan['product_id'])
      expect(plan.updated_at).to eq(product.last_plan['updated_at'])
      expect(plan.id).to eq(product.last_plan['id'])
      expect(plan.name).to eq(product.last_plan['name'])
    end
  end
end
