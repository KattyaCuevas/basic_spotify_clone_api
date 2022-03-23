class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :vote, default: 0
      t.references :votable, polymorphic: true

      t.timestamps
    end
  end
end
