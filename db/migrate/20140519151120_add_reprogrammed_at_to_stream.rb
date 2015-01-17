class AddReprogrammedAtToStream < ActiveRecord::Migration
  def change
    add_column :streams, :reprogrammed_at, :datetime
  end
end
