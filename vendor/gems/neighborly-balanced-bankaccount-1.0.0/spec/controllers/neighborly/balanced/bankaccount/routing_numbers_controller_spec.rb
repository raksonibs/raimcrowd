require 'spec_helper'

module Neighborly::Balanced::Bankaccount
  describe RoutingNumbersController do
    routes { Neighborly::Balanced::Bankaccount::Engine.routes }

    describe '#show' do
      context 'when routing number is incorrect' do
        before { get :show, id: 123 }
        it { expect(response.status).to eq 200 }
        it { expect(response.body).to eq({ ok: false, bank_name: nil }.to_json) }
      end

      context 'when routing number is correct' do
        let(:routing_number) { RoutingNumber.create! number: 123456, bank_name: 'Bank of America' }
        before { get :show, id: routing_number.number }
        it { expect(response.status).to eq 200 }
        it { expect(response.body).to eq({ ok: true, bank_name: 'Bank of America' }.to_json) }
      end
    end
  end
end
