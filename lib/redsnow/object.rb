# Essential extensions to base object class
module RedSnow
  # Class from MatterCompiler as ascendant
  class Object

    # Symbolizes keys of a hash
    def deep_symbolize_keys
      return self.reduce({}){|memo, (k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
      return self.reduce([]){|memo, v | memo << v.deep_symbolize_keys; memo} if self.is_a? Array
      return self
    end

    # Returns true if object is nil or empty, false otherwise
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end
