class CreateVirtualGiftCardEvents < ActiveRecord::Migration
  def change
    create_table :spree_virtual_gift_card_events do |t|
      t.integer :virtual_gift_card_id, null: false
      t.string  :action,               null: false
      t.decimal :amount,               precision: 8,  scale: 2
      t.decimal :user_total_amount,    precision: 8,  scale: 2, default: 0.0, null: false
      t.string  :authorization_code,   null: false
      t.integer :update_reason_id
      t.datetime :deleted_at
      t.references :originator, polymorphic: true
      t.timestamps null: true
    end

    add_index :spree_virtual_gift_card_events, :virtual_gift_card_id
    add_index :spree_virtual_gift_card_events, :deleted_at

    create_table :spree_gift_card_update_reasons do |t|
      t.string :name
      t.timestamps null: true
    end
  end
end
