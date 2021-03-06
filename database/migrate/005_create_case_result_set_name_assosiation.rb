Sequel.migration do
  change do
    alter_table(:result_sets) do
      add_foreign_key :case_id, :cases
    end
  end


  down do
    drop_column :result_sets, :case_id, Integer
  end
end
