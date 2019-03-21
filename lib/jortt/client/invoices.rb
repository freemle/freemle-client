require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of invoices.
    #
    # @see { Jortt::Client.invoices }
    class Invoices < Base

      def initialize(config)
        @resource = RestClient::Resource.new(
          "#{config.base_url}/invoices",
          user: config.app_name,
          password: config.api_key,
        )
      end

      ##
      # Creates an Invoice using the POST /invoices endpoint.
      # See https://app.jortt.nl/api-documentatie#factuur-aanmaken
      #
      # @example
      #   Jortt::Client.invoices.create(
      #     customer_id: 'customer_id', # optional
      #     delivery_period: '31-12-2015', # optional
      #     reference: 'reference', # optional
      #     line_items: [{
      #       vat: 21, # mandatory, percentage
      #       amount: 499, # mandatory, ex vat
      #       quantity: 4, # mandatory
      #       description: 'Your Thinkas' # mandatory
      #     }]
      #   )
      def create(payload)
        with_valid_json do
          resource.post(JSON.generate('invoice' => payload))
        end
      end

      def get(id)
        with_valid_json do
          resource["id/#{id}"].get
        end
      end

      def download(id)
        with_valid_response do
          resource["id/#{id}"].get(params: {format: "pdf"}).body
        end
      end

      def search(query)
        with_valid_json do
          resource['search'].get(params: {query: query})
        end
      end

      def status(invoice_status, page: 1, per_page: 100)
        with_valid_json do
          resource["status/#{invoice_status}"].get(params: {page: page, per_page: per_page})
        end
      end

    private

      attr_reader :resource

    end

  end
end
