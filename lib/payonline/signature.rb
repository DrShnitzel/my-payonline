module Payonline
  class Signature
    def initialize(params, keys, add_merchant_id = true, use_hack = false)
      @keys = keys

      # HACK: PayOnline sends both TransactionId and TransactionID (notice the letter case)
      # hack is needed when TransactionID is send
      @use_hack = use_hack

      # The order of parameter keys matters
      @params = prepare_params(params, add_merchant_id)

      # Permitted content_type values: text, xml
      @params[:security_key] = digest
      @params[:content_type] = 'text'
    end

    # A signed copy of params
    def sign
      @params.transform_keys { |key| key.to_s.camelize }
    end

    def digest
      Digest::MD5.hexdigest(digest_data)
    end

    private

    # Prepend params hash with merchant_id
    def prepare_params(params, add_merchant_id = true)
      if add_merchant_id
        params.reverse_merge!(merchant_id: Payonline.configuration.merchant_id)
        @keys.unshift(:merchant_id)
      end

      params.with_indifferent_access
    end

    # Prepare params for digest
    def digest_data
      digest_params = @params.slice(*@keys) if @keys.present?
      digest_params[:private_security_key] = Payonline.configuration.private_security_key

      digest_params = digest_params.transform_keys { |key| key.to_s.camelize }
      digest_params = fix_transaction_id(digest_params) if @use_hack

      digest_params.map { |key, value| "#{key}=#{value}" }.join('&')
    end

    def fix_transaction_id(params)
      params.transform_keys do |key|
        key == 'TransactionId' ? 'TransactionID' : key
      end
    end
  end
end
