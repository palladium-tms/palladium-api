# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :cases, :deleted, TrueClass, default: false
    add_column :suites, :deleted, TrueClass, default: false
  end
end
