class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.decimal :balance, default: 0.0
      t.string :currency, default: 'dollar'
      t.bigint :user_id, null: false, foreign_key: true

      t.timestamps
    end

    add_index :accounts, :user_id
    add_index :accounts, :currency
    add_index :accounts, [:currency, :user_id], unique: true
  end
end
