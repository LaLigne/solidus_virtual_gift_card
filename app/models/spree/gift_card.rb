module Spree
  class GiftCard < Spree::Base
    belongs_to :payment_method
    belongs_to :virtual_gift_card
    has_many :payments, as: :source

    attr_accessor :imported

    def actions
      %w{capture void credit}
    end

    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def can_void?(payment)
      payment.pending?
    end

    def can_credit?(payment)
      payment.completed? && payment.credit_allowed > 0
    end
  end
end
