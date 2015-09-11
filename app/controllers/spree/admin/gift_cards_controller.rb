class Spree::Admin::GiftCardsController < Spree::Admin::BaseController
  before_filter :load_gift_card_history, only: [:show]
  before_filter :load_user, only: [:lookup ]

  def index
    @gift_cards = Spree::VirtualGiftCard.page(params[:page])
  end

  def show
  end

  def lookup
  end

  private

  def load_gift_card_history
    redemption_code = Spree::RedemptionCodeGenerator.format_redemption_code_for_lookup(params[:id])
    @gift_cards = Spree::VirtualGiftCard.where(redemption_code: redemption_code)

    if @gift_cards.empty?
      flash[:error] = Spree.t('admin.gift_cards.errors.not_found')
      redirect_to(admin_gift_cards_path)
    end
  end

  def load_user
    @user = Spree::User.find(params[:user_id])
  end

  def model_class
    Spree::VirtualGiftCard
  end
end
