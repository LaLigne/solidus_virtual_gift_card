class AddInvalidatedAtToVirtualGiftCard < ActiveRecord::Migration
  def change
    add_column :spree_virtual_gift_cards, :invalidated_at, :datetime
  end
end
