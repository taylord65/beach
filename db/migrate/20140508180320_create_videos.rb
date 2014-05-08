class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :url
      t.text :name
      t.integer :playcount
      t.integer :length

      t.timestamps
    end
  end
end
