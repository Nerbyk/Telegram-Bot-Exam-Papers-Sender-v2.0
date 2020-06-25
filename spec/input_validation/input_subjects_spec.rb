# frozen_string_literal: true

require './actions/input_validation/check_input.rb'

describe CheckUserInput do
  describe '.single_subject' do
    context 'string and array of strings' do
      context "given 'Test' and [123, 3456, 324] " do
        it 'returns false' do
          expect(CheckUserInput.single_subject(subject: 'Test', available_list: [123, 3456, 324])).to eq(false)
        end
      end

      context "given 'TestString' and ['TestString']" do
        it 'returns false' do
          expect(CheckUserInput.single_subject(subject: 'TestString', available_list: ['TestString'])).to eq(false)
        end
      end

      context "given 'Name Surname" do
        it 'returns true' do
          expect(CheckUserInput.name(input: 'Name Surname')).to eq(true)
        end
      end
    end
  end
end
