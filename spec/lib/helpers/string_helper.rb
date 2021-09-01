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

  def rand_message_custom_data
    { "subdescriber": [{ "title": 'title_subdescriber', "value": 'value_subdescriber' }],
      "describer": [{ "title": 'title_describer', "value": 'value_describer' }] }.to_json
  end

  def rand_message_custom_with_numbers
    { "subdescriber": [{ "title": 3, "value": 1 }],
      "describer": [{ "title": 4, "value": 2 }] }.to_json
  end
end
