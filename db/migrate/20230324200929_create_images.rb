class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :text_output

      t.timestamps
    end
  end
end
