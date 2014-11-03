# This migration comes from neighborly_balanced_bankaccount (originally 20140224220426)
class CreateRoutingNumber < ActiveRecord::Migration
  def change
    create_table :routing_numbers do |t|
      t.string :number, null: false
      t.string :bank_name, null: false

      t.timestamps
    end
  end
end
