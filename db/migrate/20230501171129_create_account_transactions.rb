class CreateAccountTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :account_transactions do |t|
      t.decimal :amount, null: false
      t.bigint :account_id, null: false, foreign_key: true
      t.string :status, null: false
      t.string :transaction_type, null: false
      t.string :direction, null: false

      t.timestamps
    end

    add_index :account_transactions, :account_id
    add_index :account_transactions, :status
    add_index :account_transactions, :transaction_type
    add_index :account_transactions, :direction
  end
end
