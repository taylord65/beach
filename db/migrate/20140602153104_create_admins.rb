class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.integer :admin_key

      t.timestamps
    end
  end
end
