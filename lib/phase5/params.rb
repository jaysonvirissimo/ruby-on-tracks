require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}.merge!(route_params)

      unless req.body.nil?
        parsed_body = parse_www_encoded_form(req.body)
        @params.merge!(parsed_body)
      end
      unless req.query_string.nil?
        parsed_query_string = parse_www_encoded_form(req.query_string)
        @params.merge!(parsed_query_string)
      end
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end

    private

    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      params = {}
      pairs = URI.decode_www_form(www_encoded_form)

      pairs.each do |key, value|
        level = params # I am embarassed by the name of this variable.
        sequence_of_keys = parse_key(key)

        x = 1
        sequence_of_keys.each do |inner_key|
          if x == sequence_of_keys.length
            level[inner_key] = value
          else
            level[inner_key] = Hash.new if level[inner_key].nil?
            level = level[inner_key]
          end
          x += 1
        end
      end
      params
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      magic_regex = /\]\[|\[|\]/ # I got this magic from Ned Ruggeri.
      key.split(magic_regex)
    end
  end
end
