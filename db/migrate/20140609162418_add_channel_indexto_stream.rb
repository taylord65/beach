class AddChannelIndextoStream < ActiveRecord::Migration
  def change
    add_reference :channels, :stream, index: true
  end
end
