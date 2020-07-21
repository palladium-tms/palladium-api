Sequel.migration do
  change do
    alter_table(:cases) do
      add_foreign_key :plan_id, :plans
    end
  end
end
