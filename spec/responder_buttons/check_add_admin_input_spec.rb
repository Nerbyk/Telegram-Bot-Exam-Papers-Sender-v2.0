# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'

describe ReceiverHelper do
  describe '.check_add_admin_input' do
    context 'array of strings' do
      context "given ['1234', 'nameSurname']" do
        it 'returns true' do
          expect(ReceiverHelper.check_add_admin_input(%w[1234 nameSurname])).to eq(true)
        end
      end

      context "given ['nameSurname', '1234']" do
        it 'returns false' do
          expect(ReceiverHelper.check_add_admin_input(%w[nameSurname 1234])).to eq(false)
        end
      end
    end
  end
end
