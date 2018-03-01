Sequel.migration do
  up do
    add_column :users, :product_position, 'integer[]'
  end

  down do
    drop_column :users, :product_position
  end
end
