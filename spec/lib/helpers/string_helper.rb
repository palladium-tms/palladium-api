module StringHelper
  def rand_product_name
    "Product_#{Time.now.nsec}"
  end

  def rand_plan_name
    "Plan_#{Time.now.nsec}"
  end

  def rand_run_name
    "Run_#{Time.now.nsec}"
  end

  def rand_result_set_name
    "ResultSet_#{Time.now.nsec}"
  end

  def rand_status_name
    "Status_#{Time.now.nsec}"
  end

  def rand_message
    "message_#{Time.now.nsec}"
  end
end