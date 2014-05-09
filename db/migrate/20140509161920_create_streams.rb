class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
