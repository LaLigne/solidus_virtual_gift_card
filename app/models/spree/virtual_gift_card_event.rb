module Spree
  class VirtualGiftCardEvent < ActiveRecord::Base
    acts_as_paranoid

    belongs_to :virtual_gift_card
    belongs_to :originator, polymorphic: true
    belongs_to :update_reason, class_name: "Spree::GiftCardUpdateReason"

    validates_presence_of :update_reason, if: :action_requires_reason?

    NON_EXPOSED_ACTIONS = [Spree::VirtualGiftCard::ELIGIBLE_ACTION, Spree::VirtualGiftCard::AUTHORIZE_ACTION]

    scope :exposed_events, -> { exposable_actions.not_invalidated }
    scope :exposable_actions, -> { where.not(action: NON_EXPOSED_ACTIONS) }
    scope :not_invalidated, -> { joins(:store_credit).where(spree_store_credits: { invalidated_at: nil }) }
    scope :chronological, -> { order(:created_at) }
    scope :reverse_chronological, -> { order(created_at: :desc) }

    delegate :currency, to: :store_credit

    def capture_action?
      action == Spree::VirtualGiftCard::CAPTURE_ACTION
    end

    def authorization_action?
      action == Spree::VirtualGiftCard::AUTHORIZE_ACTION
    end

    def action_requires_reason?
      [Spree::VirtualGiftCard::ADJUSTMENT_ACTION, Spree::VirtualGiftCard::INVALIDATE_ACTION].include?(action)
    end

    def display_amount
      Spree::Money.new(amount, { currency: currency })
    end

    def display_user_total_amount
      Spree::Money.new(user_total_amount, { currency: currency })
    end

    def display_event_date
      I18n.l(created_at.to_date, format: :long)
    end

    def display_action
      return if NON_EXPOSED_ACTIONS.include?(action)
      Spree.t("gift_card.display_action.#{action}")
    end

    def order
      Spree::Payment.find_by_response_code(authorization_code).try(:order)
    end
  end
end
