Spree::PaymentMethod.class_eval do
  def gift_card?
    is_a? Spree::PaymentMethod::VirtualGiftCard
  end
end
