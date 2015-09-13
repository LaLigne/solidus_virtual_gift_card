class ChangeAmountTypeInSpreeVirtualGiftCards < ActiveRecord::Migration
  def change
    change_column :spree_virtual_gift_cards, :amount, :decimal, precision: 10, scale: 2
  end
end
