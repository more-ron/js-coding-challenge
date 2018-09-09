class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :asin, null: false
      t.jsonb :data, null: false, default: {}
      t.text :raw_html
      t.datetime :last_updated_at
      t.boolean :not_found
      t.timestamps

      t.index :asin, unique: true
    end
  end
end
