require 'spec_helper'

describe Jortt::Client::Invoices do
  let(:invoices) do
    described_class.new(
      double(base_url: 'foo', app_name: 'app', api_key: 'secret'),
    )
  end

  describe '#create' do
    let(:request_body) { JSON.generate(invoice: {line_items: []}) }
    let(:response_body) { JSON.generate(invoice_id: 'abc') }
    subject { invoices.create(line_items: []) }
    before do
      stub_request(:post, 'http://foo/invoices').
        with(body: request_body).
        to_return(status: 200, body: response_body)
    end
    it { should eq('invoice_id' => 'abc') }
  end

  describe '#get' do
    subject { invoices.get('foo') }

    context 'with valid id' do
      before do
        stub_request(:get, 'http://foo/invoices/id/foo').
          to_return(status: 200, body: '{"id": "foo"}')
      end
      it { should eq('id' => 'foo') }
    end

    context 'with invalid id' do
      before do
        stub_request(:get, 'http://foo/invoices/id/foo').
          to_return(status: 400, body: '{"errors":{"invoice_id":{"code":"not_found"}}}')
      end
      it { expect { subject }.to raise_error(Jortt::Error) }
    end
  end

  describe '#download' do
    subject { invoices.download('foo') }

    context 'with valid id' do
      before do
        stub_request(:get, 'http://foo/invoices/id/foo?format=pdf').
          to_return(status: 200, body: 'pdf body')
      end
      it { should eq('pdf body') }
    end

    context 'with invalid id' do
      before do
        stub_request(:get, 'http://foo/invoices/id/foo?format=pdf').
          to_return(status: 400, body: '{"errors":{"invoice_id":{"code":"not_found"}}}')
      end
      it { expect { subject }.to raise_error(Jortt::Error) }
    end
  end

  describe '#search' do
    subject { invoices.search('terms') }
    before do
      stub_request(:get, 'http://foo/invoices/search?query=terms').
        to_return(status: 200, body: '{"invoices": []}')
    end
    it { should eq('invoices' => []) }
  end

  describe '#status' do
    subject { invoices.status('due', page: 1, per_page: 3) }
    before do
      stub_request(:get, 'http://foo/invoices/status/due?page=1&per_page=3').
        to_return(status: 200, body: '{"invoices": [], "page": 1, "per_page": 3, "total_pages": 0}')
    end
    it { should eq('invoices' => [], 'page' => 1, 'per_page' => 3, 'total_pages' => 0) }
  end
end
