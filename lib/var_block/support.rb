module VarBlock
  module Support
    # copied directly from Rails Array class
    # https://apidock.com/rails/v4.2.7/Array/wrap/class
    def array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end