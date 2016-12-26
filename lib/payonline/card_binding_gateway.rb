require 'digest/sha1'

module Payonline
  class CardBindingGateway
    BASE_URL = 'https://secure.payonlinesystem.com'

    SIGNED_PARAMS = %w(order_id amount currency valid_until order_description)
    PERMITTED_PARAMS = %w(
      order_id amount currency valid_until order_description return_url fail_url
    )

    def initialize(params = {})
      @params = prepare_params(params)
    end

    def payment_url(language: :ru)
      params = Payonline::Signature.new(@params, SIGNED_PARAMS).sign

      "#{BASE_URL}/#{language}/payment/verification/randomamount/?#{params.to_query}"
    end

    def self.random_amount(random_string)
      str = "Amount=#{random_string}&" \
      "PrivateSecurityKey=#{Payonline.configuration.private_security_key}"
      summ = 100
      f = Digest::SHA1.hexdigest(str)
      (0..19).each do |i|
        starting = i * 2
        ending = starting + 1
        summ += f[starting..ending].to_i(16) % 31.0
      end
      summ / 100.0
    end

    private

    def prepare_params(params)
      params
        .with_indifferent_access
        .slice(*PERMITTED_PARAMS)
        .merge(default_params)
    end

    def default_params
      {
        return_url: Payonline.configuration.return_url,
        fail_url: Payonline.configuration.fail_url
      }
    end
  end
end
