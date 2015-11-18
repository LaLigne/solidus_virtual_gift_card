class CreateGiftCards < ActiveRecord::Migration
  def change
    create_table :spree_gift_cards do |t|
      t.string   "redemption_code"
      t.integer  "payment_method_id"
      t.integer  "user_id"
      t.integer  "virtual_gift_card_id"
      t.timestamps
    end
  end
end
