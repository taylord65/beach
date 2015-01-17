class AddSubsToStream < ActiveRecord::Migration
  def change
    add_column :streams, :subs, :integer
  end
end
