require_relative '../../tests/test_management'
http, product_name, plan_name, run_name, result_set_name, message = nil
describe 'Result Set Smoke' do
  before :each do
    http = Http.new(token: AuthFunctions.create_user_and_get_token)
    product_name = 'Product_' + http.random_name
    plan_name = 'Plan_' + http.random_name
    run_name = 'Run_' + http.random_name
    result_set_name = 'Result_set_' + http.random_name
  end

  describe 'Create new result_sets' do
    it '1. Create product, plan, run and result set in one time' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_name: product_name,
                                                                           name: result_set_name)[0].body)
      expect(responce.keys.size).to eq(5)
      expect(responce['product']['name']).to eq(product_name)
      expect(responce['plan']['name']).to eq(plan_name)
      expect(responce['run']['name']).to eq(run_name)
      expect(responce['result_sets'][0]['name']).to eq(result_set_name)
    end

    it '2. Create plan, run and result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_id: product['id'],
                                                                           name: result_set_name)[0].body)
      expect(responce.keys.size).to eq(5)
      expect(responce['product']['id']).to eq(product['id'])
      expect(responce['plan']['name']).to eq(plan_name)
      expect(responce['run']['name']).to eq(run_name)
      expect(responce['result_sets'][0]['name']).to eq(result_set_name)
    end

    it '3. Create run and result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                           run_name: run_name,
                                                                           name: result_set_name)[0].body)
      expect(responce.keys.size).to eq(4)
      expect(responce['plan']['id']).to eq(plan['id'])
      expect(responce['run']['name']).to eq(run_name)
      expect(responce['result_sets'][0]['name']).to eq(result_set_name)
    end

    it '4. Create result set in one time' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set_name = http.random_name
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, run_id: run['id'],
                                                                           name: result_set_name)[0].body)
      expect(responce.keys.size).to eq(2)
      expect(responce['run']['id']).to eq(run['id'])
      expect(responce['result_sets'][0]['name']).to eq(result_set_name)
    end
  end

  describe 'Show result_set' do
    it 'get result_sets by run_id' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                             run_id: run['id'])[0].body)['result_sets'][0]
      responce = JSON.parse(ResultSetFunctions.get_result_sets(http, id: run['id']).body)
      expect(responce['errors']).to eq([])
      expect(responce['result_sets'].first['id']).to eq(result_set['id'])
      expect(responce['result_sets'].first['run_id']).to eq(result_set['run_id'])
    end

    it 'get result_set | show method' do
      product = JSON.parse(ProductFunctions.create_new_product(http)[0].body)['product']
      plan = JSON.parse(PlanFunctions.create_new_plan(http, product_name: product['name'])[0].body)['plan']
      run = JSON.parse(RunFunctions.create_new_run(http, plan_id: plan['id'])[0].body)['run']
      result_set = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_id: plan['id'],
                                                                             run_id: run['id'])[0].body)['result_sets'][0]
      responce = JSON.parse(ResultSetFunctions.get_result_set(http, id: result_set['id']).body)['result_set']
      expect(responce).to eq(result_set)
    end
  end

  describe 'Delete result_set' do
    it 'Delete result set' do
      product_name, plan_name, run_name, result_set_name = Array.new(4).map { http.random_name }
      responce = JSON.parse(ResultSetFunctions.create_new_result_set(http, plan_name: plan_name,
                                                                           run_name: run_name,
                                                                           product_name: product_name,
                                                                           name: result_set_name)[0].body)['result_sets'][0]
      delete_responce = JSON.parse(ResultSetFunctions.delete_result_set(http, id: responce['id']).body)
      result_ser_after_deleting = ResultSetFunctions.get_result_set(http, id: responce['id'])
      expect(delete_responce['result_set']['id']).to eq(responce['id'])
      expect(result_ser_after_deleting.code).to eq('500')
    end
  end

  describe 'Get result sets by status' do
    it 'get result_sets by status' do
      status = 'Passed'
      result_first = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                             run_name: run_name,
                                                             product_name: product_name,
                                                             result_set_name: result_set_name + '1',
                                                             message: message,
                                                             status: status)
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name + '2',
                                              message: message,
                                              status: 'Failed')
      result_second = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                              run_name: run_name,
                                                              product_name: product_name,
                                                              result_set_name: result_set_name,
                                                              message: message,
                                                              status: status)
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       product_name: product_name,
                                                                       status: status)
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['status'][0]['name']).to eq(status)
      expect(body['result_sets'].count).to eq(2)
      expect(body['result_sets'][0]).to eq(JSON.parse(result_first.body)['result_sets'][0])
      expect(body['result_sets'][1]).to eq(JSON.parse(result_second.body)['result_sets'][0])
    end

    it 'get result_sets by status if it not found' do
      status = 'Passed'
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name,
                                              message: message,
                                              status: 'Failed')
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       product_name: product_name,
                                                                       result_set_name: result_set_name,
                                                                       status: status)
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['status'][0]['name']).to eq(status)
      expect(body['result_sets']).to eq([])
    end

    describe 'Incorrect data' do

      before :each do
        ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                run_name: run_name,
                                                product_name: product_name,
                                                result_set_name: result_set_name + '1',
                                                message: message,
                                                status: 'Passed')
        ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                run_name: run_name,
                                                product_name: product_name,
                                                result_set_name: result_set_name + '2',
                                                message: message,
                                                status: 'Failed')
      end

      it 'getting result_set_by_status with incorrect product name' do
        result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: 'incorrect_product_name',
                                                                         plan_name: plan_name,
                                                                         run_name: run_name,
                                                                         result_set_name: result_set_name,
                                                                         status: 'Passed')
        body = JSON.parse(result_sets.body)
        expect(body['product']).to be_nil
        expect(body['product_errors']).to eq('product not found')
      end

      it 'getting result_set_by_status with incorrect plan name' do
        result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                         plan_name: 'incorrect_plan_name',
                                                                         run_name: run_name,
                                                                         status: 'Passed')
        body = JSON.parse(result_sets.body)
        expect(body['product']['name']).to eq(product_name)
        expect(body['plan']).to be_nil
        expect(body['plan_errors']).to eq('plan not found')
      end

      it 'getting result_set_by_status with incorrect run name' do
        result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                         plan_name: plan_name,
                                                                         run_name: 'incorrect_run_name',
                                                                         status: 'Passed')
        body = JSON.parse(result_sets.body)
        expect(body['product']['name']).to eq(product_name)
        expect(body['plan']['name']).to eq(plan_name)
        expect(body['run']).to be_nil
        expect(body['run_errors']).to eq('run not found')
      end

      it 'getting result_set_by_status with incorrect status name' do
        result_sets = ResultSetFunctions.get_result_sets_by_status(http, product_name: product_name,
                                                                         plan_name: plan_name,
                                                                         run_name: run_name,
                                                                         status: 'incorrect_status')
        body = JSON.parse(result_sets.body)
        expect(body['product']['name']).to eq(product_name)
        expect(body['plan']['name']).to eq(plan_name)
        expect(body['run']['name']).to eq(run_name)
        expect(body['status']).to be_nil
        expect(body['status_errors']).to eq('status not found')
      end
    end

    it 'get result_sets by statuses(multiple)' do
      statuses = %w[Passed Failed]
      result_first = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                             run_name: run_name,
                                                             product_name: product_name,
                                                             result_set_name: result_set_name + 'important_1',
                                                             message: message,
                                                             status: 'Passed')
      result_second = ResultFunctions.create_new_result(http, plan_name: plan_name,
                                                              run_name: run_name,
                                                              product_name: product_name,
                                                              result_set_name: result_set_name + 'important_2',
                                                              message: message,
                                                              status: 'Failed')
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name,
                                              message: message,
                                              status: 'Pending')
      ResultFunctions.create_new_result(http, plan_name: plan_name,
                                              run_name: run_name,
                                              product_name: product_name,
                                              result_set_name: result_set_name,
                                              message: message,
                                              status: 'Aborted')
      result_sets = ResultSetFunctions.get_result_sets_by_status(http, plan_name: plan_name,
                                                                       run_name: run_name,
                                                                       product_name: product_name,
                                                                       status: statuses)
      body = JSON.parse(result_sets.body)
      expect(body['product']['name']).to eq(product_name)
      expect(body['plan']['name']).to eq(plan_name)
      expect(body['run']['name']).to eq(run_name)
      expect(body['status'].count).to eq(2)
      expect(body['status'][0]['name']).to eq(statuses[1])
      expect(body['status'][1]['name']).to eq(statuses[0])
      expect(body['result_sets'].count).to eq(2)
      expect(body['result_sets'][0]).to eq(JSON.parse(result_first.body)['result_sets'][0])
      expect(body['result_sets'][1]).to eq(JSON.parse(result_second.body)['result_sets'][0])
    end
  end
end
