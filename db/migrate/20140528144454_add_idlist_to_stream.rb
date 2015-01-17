class AddIdlistToStream < ActiveRecord::Migration
  def change
    add_column :streams , :idlist , :string ,array: true , default: []
  end
end
