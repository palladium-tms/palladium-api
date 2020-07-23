Sequel.migration do
  change do
    alter_table(:suites) do
      add_foreign_key :plan_id, :plans
    end
  end
end
