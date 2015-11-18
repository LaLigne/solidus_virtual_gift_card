Spree::Payment.class_eval do
  after_create :create_eligible_gift_card_event

  # @return [Boolean] true when the payment method exists and is a store credit payment method
  def gift_card?
    payment_method.try!(:gift_card?)
  end

  def create_eligible_gift_card_event
    # When cancelling an order, a payment with the negative amount
    # of the payment total is created to refund the customer. That
    # payment has a source of itself (Spree::Payment) no matter the
    # type of payment getting refunded, hence the additional check
    # if the source is a store credit.
    if source.is_a?(Spree::GiftCard)
      virtual_gift_card = Spree::VirtualGiftCard.find_by redemption_code: source.redemption_code
      if virtual_gift_card
        virtual_gift_card.update_attributes!({
          action: Spree::VirtualGiftCard::ELIGIBLE_ACTION,
          action_amount: amount,
          action_authorization_code: response_code,
        })
      end
    end
  end
end
