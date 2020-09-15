Sequel.migration do
  up do
    add_column :plans, :statistic, String
  end
end
