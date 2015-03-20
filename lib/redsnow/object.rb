# Essential extensions to base object class
module RedSnow
  # Class from MatterCompiler as ascendant
  class Object
    # Symbolizes keys of a hash
    def deep_symbolize_keys
      return each_with_object({}) { |memo, (k, v)| memo[k.to_sym] = v.deep_symbolize_keys } if self.is_a?(Hash)
      return each_with_object([]) { |memo, v| memo << v.deep_symbolize_keys } if self.is_a?(Array)
      self
    end

    # Returns true if object is nil or empty, false otherwise
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end
