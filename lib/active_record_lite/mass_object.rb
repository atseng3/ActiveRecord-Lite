class MassObject
  def self.my_attr_accessible(*attributes)
    attributes.each do |each_attribute|
      getter_name = each_attribute.to_s
      instance_var = ("@" + getter_name).to_sym
      define_method(getter_name) do 
        instance_variable_get(instance_var)
      end
      
      setter_name = each_attribute.to_s + "="
      define_method(setter_name) do |argument|
        instance_variable_set(instance_var, argument)
      end
    end
    
    @attributes ||= []
    @attributes += attributes unless @attributes.include?(attributes)
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send (attr_name.to_s + "=").to_sym, value
      end
    end
  end
end

# 
# class MyClass < MassObject
#   my_attr_accessible :x, :y
# end
# 
# MyClass.new(:x => :x_val, :y => :y_val)
# 
# MyClass.attributes