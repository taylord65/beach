class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :title
      t.text :description
      t.string :current_playlist, :array => true

      t.timestamps
    end
  end
end
