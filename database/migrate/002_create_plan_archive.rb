Sequel.migration do
  up do
    add_column :plans, :is_archived, TrueClass, default: false
  end
end
