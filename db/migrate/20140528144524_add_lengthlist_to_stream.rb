class AddLengthlistToStream < ActiveRecord::Migration
  def change
    add_column :streams , :lengthlist , :integer ,array:  true , default: []
  end
end
