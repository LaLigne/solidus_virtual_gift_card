require 'spec_helper'

describe Spree::Admin::GiftCardsController do
  stub_authorization!
  let!(:gc_category) { create(:store_credit_gift_card_category) }
  let!(:credit_type) { create(:secondary_credit_type, name: "Non-expiring") }

  describe 'GET index' do
    subject { spree_get :index }

    it "returns a 200 status code" do
      subject
      expect(response.code).to eq "200"
    end
  end

  describe 'GET show' do
    let(:gift_card) { create(:virtual_gift_card) }
    let(:redemption_code) { gift_card.redemption_code }

    subject { spree_get :show, id: redemption_code }

    context 'with a valid redemption code' do
      it 'loads the gift cards' do
        subject
        expect(assigns(:gift_cards)).to eq [gift_card]
      end

      it 'returns a 200 status code' do
        subject
        expect(response.code).to eq '200'
      end
    end

    context 'with an invalid redemption code' do
      let(:redemption_code) { "DOES-NOT-EXIST" }

      it "redirects to index" do
        expect(subject).to redirect_to spree.admin_gift_cards_path
      end

      it "sets the flash error" do
        subject
        expect(flash[:error]).to eq Spree.t('admin.gift_cards.errors.not_found')
      end
    end
  end

  describe 'GET lookup' do
    let(:user) { create :user }
    subject { spree_get :lookup, user_id: user.id }

    it "returns a 200 status code" do
      subject
      expect(response.code).to eq "200"
    end
  end
end
