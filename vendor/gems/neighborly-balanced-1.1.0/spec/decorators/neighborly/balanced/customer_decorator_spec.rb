require 'spec_helper'

describe Neighborly::Balanced::CustomerDecorator do
  let(:remote_source) { double('Balanced::Customer') }
  let(:source) do
    double('Neighborly::Balanced::Customer',fetch: remote_source)
  end
  subject { described_class.new(source) }

  describe 'bank account name' do
    it 'gets this info fetching the bank accout of the customer' do
      bank_account = double('Balanced::BankAccount',
                            bank_name:      'JPMORGAN CHASE BANK',
                            account_number: 'xxxxxx0002')
      remote_source.stub(:bank_accounts).and_return([bank_account])
      expect(subject.bank_account_name).to eql('JPMORGAN CHASE BANK xxxxxx0002')
    end
  end
end
