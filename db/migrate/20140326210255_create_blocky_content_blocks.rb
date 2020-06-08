class CreateBlockyContentBlocks < ActiveRecord::Migration
  def change
    create_table :blocky_content_blocks do |t|
      t.string :content_key, index: true
      t.text   :content
      t.string :description # Optional description for the content block
      t.boolean :multiple, null: false, default: false
      t.integer :order, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
