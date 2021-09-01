# frozen_string_literal: true

require_relative '../../tests/test_management'
describe 'Product Smoke' do
  before do
    @user = AccountFunctions.create_and_parse
    @user.login
  end

  describe 'Create new product' do
    it 'check creating new product with correct user_data and correct product_data' do
      products_before_create = @user.get_all_products
      product = @user.create_new_product
      expect(product.product_errors).to be_nil
      expect(product.id).not_to be_nil
      products_after_create = @user.get_all_products
      expect(products_before_create.diff(products_after_create)).to eq([product.id])
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
      expect(JSON.parse(response.body)['errors']).to be_empty
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
      expect(res_new_product).to be_like_a(res_product)
    end
  end

  describe 'Edit product' do
    it 'edit product after creating' do
      new_name = rand_product_name
      product = @user.create_new_product
      @user.update_product(product.id, new_name)
      product_after_edit = @user.show_product(product.id)
      expect(product).not_to be_like_a(product_after_edit)
      expect(product_after_edit.name).to eq(new_name)
    end
  end
end
