# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:result_sets) do
      add_foreign_key :case_id, :cases
    end

    alter_table(:runs) do
      add_foreign_key :suite_id, :suites
    end
  end
end
