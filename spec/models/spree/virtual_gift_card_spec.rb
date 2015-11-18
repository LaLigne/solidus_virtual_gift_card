require 'spec_helper'

describe Spree::VirtualGiftCard do
  let!(:gc_category) { create(:store_credit_gift_card_category) }
  let!(:credit_type) { create(:secondary_credit_type, name: "Non-expiring") }

  context 'validations' do
    let(:invalid_gift_card) { Spree::VirtualGiftCard.new(amount: 0, currency: 'USD', purchaser_email: generate(:random_email)) }

    context 'given an amount less than one' do
      it 'is not valid' do
        expect(invalid_gift_card).not_to be_valid
      end

      it 'adds an error to amount' do
        invalid_gift_card.save
        expect(invalid_gift_card.errors.full_messages).to include 'Amount must be greater than 0'
      end
    end
  end

  context 'before create callbacks' do
    let(:gift_card) { Spree::VirtualGiftCard.new(amount: 20, currency: 'USD', purchaser_email: generate(:random_email), line_item: create(:line_item) ) }
    subject { gift_card.save }

    context 'a redemption code is set already' do
      before { gift_card.redemption_code = 'foo' }
      it 'keeps that redemption code' do
        subject
        expect(gift_card.redemption_code).to eq 'foo'
      end
    end

    context 'no collision on redemption code' do
      it 'sets an initial redemption code' do
        subject
        expect(gift_card.redemption_code).to be_present
      end
    end


    context 'there is a collision on redemption code' do 
      context 'the existing giftcard has not been redeemed yet' do
        let!(:existing_giftcard) { create(:virtual_gift_card) }
        let(:expected_code) { 'EXPECTEDCODE' }
        let(:generator) { Spree::RedemptionCodeGenerator }

        it 'recursively generates redemption codes' do
          expect(generator).to receive(:generate_redemption_code).and_return(existing_giftcard.redemption_code)
          expect(generator).to receive(:generate_redemption_code).and_return(expected_code)

          subject

          expect(gift_card.redemption_code).to eq expected_code
        end
      end

      context 'the existing gift card has been redeemed' do
        let!(:existing_giftcard) { create(:virtual_gift_card, redeemed_at: Time.now) }
        let(:generator) { Spree::RedemptionCodeGenerator }

        it 'recursively generates redemption codes' do
          expect(generator).to receive(:generate_redemption_code).and_return(existing_giftcard.redemption_code)

          subject

          expect(gift_card.redemption_code).to eq existing_giftcard.redemption_code
        end
      end
    end
  end

  describe '#formatted_redemption_code' do
    let(:redemption_code) { 'AAAABBBBCCCCDDDD' }
    let(:formatted_redemption_code) { 'AAAA-BBBB-CCCC-DDDD' }
    let(:gift_card) { Spree::VirtualGiftCard.create(amount: 20, currency: 'USD') }

    subject { gift_card.formatted_redemption_code }

    it 'inserts dashes into the code after every 4 characters' do
      expect(gift_card).to receive(:redemption_code).and_return(redemption_code)
      expect(subject).to eq formatted_redemption_code
    end
  end
end
