class AddAmountUsedAndAuthorizedToVirtualGiftCards < ActiveRecord::Migration
  def change
    add_column :spree_virtual_gift_cards, :amount_used, :decimal, precision: 8, scale: 2, default: 0.0, null: false
    add_column :spree_virtual_gift_cards, :amount_authorized, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
