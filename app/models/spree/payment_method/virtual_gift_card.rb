module Spree
  class PaymentMethod::VirtualGiftCard < Spree::PaymentMethod
    def payment_source_class
      ::Spree::GiftCard
    end

    def payment_profiles_supported?
      true
    end

    def create_profile(payment)
      virtual_gift_card = Spree::VirtualGiftCard.find_by redemption_code: payment.source.redemption_code

      if virtual_gift_card
        payment.source.update_attributes!({
          virtual_gift_card_id: virtual_gift_card.id
        })
      else
        payment.send(:gateway_error, Spree.t('gift_card.unable_to_find'))
      end
    end

    def authorize(amount_in_cents, gift_card, gateway_options = {})
      if gift_card.nil? || gift_card.virtual_gift_card.nil?
        ActiveMerchant::Billing::Response.new(false, Spree.t('gift_card.unable_to_find'), {}, {})
      else
        action = -> (virtual_gift_card) {
          virtual_gift_card.authorize(
            amount_in_cents / 100.0.to_d,
            gateway_options[:currency],
            action_originator: gateway_options[:originator]
          )
        }
        handle_action_call(gift_card.virtual_gift_card, action, :authorize)
      end
    end

    def capture(amount_in_cents, auth_code, gateway_options = {})
      action = -> (gift_card) {
        gift_card.capture(
          amount_in_cents / 100.0.to_d,
          auth_code,
          gateway_options[:currency],
          action_originator: gateway_options[:originator]
        )
      }

      handle_action(action, :capture, auth_code)
    end

    def purchase(amount_in_cents, gift_card, gateway_options = {})
      virtual_gift_card = gift_card.virtual_gift_card
      eligible_events = virtual_gift_card.virtual_gift_card_events.where(amount: amount_in_cents / 100.0.to_d, action: Spree::VirtualGiftCard::ELIGIBLE_ACTION)
      event = eligible_events.find do |eligible_event|
        virtual_gift_card.virtual_gift_card_events.where(authorization_code: eligible_event.authorization_code)
                                        .where.not(action: Spree::VirtualGiftCard::ELIGIBLE_ACTION).empty?
      end

      if event.blank?
        ActiveMerchant::Billing::Response.new(false, Spree.t('gift_card.unable_to_find'), {}, {})
      else
        capture(amount_in_cents, event.authorization_code, gateway_options)
      end
    end

    def void(auth_code, gift_card, gateway_options={})
      action = -> (virtual_gift_card) {
        virtual_gift_card.void(auth_code, action_originator: gateway_options[:originator])
      }
      handle_action(action, :void, auth_code)
    end

    def credit(amount_in_cents, gift_card, auth_code, gateway_options)
      action = -> (virtual_gift_card) do
        currency = gateway_options[:currency] || virtual_gift_card.currency
        originator = gateway_options[:originator]

        virtual_gift_card.credit(amount_in_cents / 100.0.to_d, auth_code, currency, action_originator: originator)
      end

      handle_action(action, :credit, auth_code)
    end

    def cancel(auth_code)
      store_credit_event = auth_or_capture_event(auth_code)
      store_credit = store_credit_event.try(:store_credit)

      if store_credit_event.nil? || store_credit.nil?
        return false
      elsif store_credit_event.capture_action?
        store_credit.credit(store_credit_event.amount, auth_code, store_credit.currency)
      elsif store_credit_event.authorization_action?
        store_credit.void(auth_code)
      else
        return false
      end
    end

    def source_required?
      true
    end

    private

    def handle_action_call(gift_card, action, action_name, auth_code=nil)
      gift_card.with_lock do
        if response = action.call(gift_card)
          # note that we only need to return the auth code on an 'auth', but it's innocuous to always return
          ActiveMerchant::Billing::Response.new(true,
                                                Spree.t('gift_card.successful_action', action: action_name),
                                                {}, { authorization: auth_code || response })
        else
          ActiveMerchant::Billing::Response.new(false, gift_card.errors.full_messages.join, {}, {})
        end
      end
    end

    def handle_action(action, action_name, auth_code)
      # Find first event with provided auth_code
      virtual_gift_card = VirtualGiftCardEvent.find_by_authorization_code(auth_code).try(:virtual_gift_card)

      if virtual_gift_card.nil?
        ActiveMerchant::Billing::Response.new(false, Spree.t('gift_card.unable_to_find_for_action', auth_code: auth_code, action: action_name), {}, {})
      else
        handle_action_call(virtual_gift_card, action, action_name, auth_code)
      end
    end

    def auth_or_capture_event(auth_code)
      capture_event = VirtualGiftCardEvent.find_by(authorization_code: auth_code, action: Spree::VirtualGiftCard::CAPTURE_ACTION)
      auth_event = VirtualGiftCardEvent.find_by(authorization_code: auth_code, action: Spree::VirtualGiftCard::AUTHORIZE_ACTION)
      return capture_event || auth_event
    end
  end
end