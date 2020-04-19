class CreateDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :domains do |t|
      t.string :host
      t.string :origin
      t.boolean :verified

      t.timestamps
    end
  end
end
