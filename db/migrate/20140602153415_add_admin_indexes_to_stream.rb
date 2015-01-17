class AddAdminIndexesToStream < ActiveRecord::Migration
  def change
    add_reference :admins, :stream, index: true
  end
end
