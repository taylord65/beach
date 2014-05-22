class AddTotallengthToStream < ActiveRecord::Migration
  def change
    add_column :streams, :totallength, :integer
  end
end
