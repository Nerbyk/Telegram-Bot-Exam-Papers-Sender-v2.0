# frozen_string_literal: true

require './actions/input_validation/check_input.rb'
require 'spec_helper'

describe CheckUserInput do
  describe '.name' do
    context 'string' do
      context "given 'My Test String'" do
        it 'returns false' do
          expect(CheckUserInput.name(input: 'My Test String')).to eq(false)
        end
      end

      context "given 'TestString'" do
        it 'returns false' do
          expect(CheckUserInput.name(input: 'TestString')).to eq(false)
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
