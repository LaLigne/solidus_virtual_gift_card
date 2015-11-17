class ChangeVirtualGiftCardPurchaserToPurchaserEmail < ActiveRecord::Migration
  def change
    add_column :spree_virtual_gift_cards, :purchaser_email, :string
    add_index :spree_virtual_gift_cards, :purchaser_email
    remove_column :spree_virtual_gift_cards, :purchaser_id

    add_column :spree_virtual_gift_cards, :redeemer_email, :string
    add_index :spree_virtual_gift_cards, :redeemer_email
    remove_column :spree_virtual_gift_cards, :redeemer_id
  end
end
