module Payonline
  class VoidGateway
    BASE_URL = 'https://secure.payonlinesystem.com'

    SIGNED_PARAMS = %w(transaction_id)
    PERMITTED_PARAMS = %w(transaction_id)

    def initialize(params = {})
      @params = prepare_params(params)
    end

    def url
      params = Payonline::Signature.new(@params, SIGNED_PARAMS).sign

      "#{BASE_URL}/payment/transaction/void/?#{params.to_query}"
    end

    private

    def prepare_params(params)
      params
        .with_indifferent_access
        .slice(*PERMITTED_PARAMS)
        .merge(default_params)
    end

    def default_params
      {}
    end
  end
end
