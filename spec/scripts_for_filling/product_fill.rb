# frozen_string_literal: true

require 'palladium'
require_relative '../tests/test_management'
@user = AccountFunctions.create_and_parse
@user.login

20.times do |product_index|
  logger.info("product_index: #{product_index}")
  product = @user.create_new_product("Product_#{product_index}")
  next unless product_index == 0

  20.times do |plan_index|
    logger.info("plan_index: #{plan_index}")
    plan = @user.create_new_plan(name: "Plan_#{plan_index}", product_id: product.id)
    next unless plan_index == 19

    20.times do |run_index|
      logger.info("run_index: #{run_index}")
      run = @user.create_new_run(name: "Run_#{run_index}", plan_id: plan.id)
      next unless run_index == 0

      20.times do |result_set_index|
        logger.info("result_set_index: #{result_set_index}")
        result_set = @user.create_new_result_set(name: "ResultSet_#{result_set_index}", run_id: run.id)
        next unless result_set_index == 0

        20.times do |result_index|
          logger.info("result_index: #{result_index}")
          @user.create_new_result(result_set_id: result_set.id,
                                  message: "Result_#{result_index}",
                                  status: 'Passed')
        end
      end
    end
  end
end
