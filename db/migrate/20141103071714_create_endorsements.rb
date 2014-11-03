class CreateEndorsements < ActiveRecord::Migration
  def change
    create_table :endorsements do |t|
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
  end
end
