require 'rails_helper'

RSpec.describe Item, type: :model do

  describe 'Relationships' do
    it { should belong_to :merchant }
  end

  describe 'Validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
  end

  describe 'Class Methods' do
  end

  describe 'Instance Methods' do
  end
end
