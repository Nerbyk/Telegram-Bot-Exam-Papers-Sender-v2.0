# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'

describe ReceiverButtonHelper do
  describe '.check_db_string' do
    context 'array of strings' do
      context "given ['1234', 'nameSurname']" do
        it 'returns true' do
          expect(ReceiverButtonHelper.check_db_string(%w[1234 nameSurname])).to eq(true)
        end
      end

      context "given ['nameSurname', '1234']" do
        it 'returns false' do
          expect(ReceiverButtonHelper.check_db_string(%w[nameSurname 1234])).to eq(false)
        end
      end

      context "given ['nameSurname', '1234', 'oneMoreItem']" do
        it 'returns false' do
          expect(ReceiverButtonHelper.check_db_string(%w[nameSurname 1234 oneMoreItem])).to eq(false)
        end
      end

      context 'given [1234]' do
        it 'returns false' do
          expect(ReceiverButtonHelper.check_db_string([1234])).to eq(false)
        end
      end
    end
  end
end
