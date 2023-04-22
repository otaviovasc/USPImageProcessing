class RemoveDuplicateUserIdFromImages < ActiveRecord::Migration[7.0]
  def change
    remove_column :images, :user_id
  end
end
