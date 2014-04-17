module CP

  class Constraint
    attr_reader :variables

    def initialize(*variables, &block)
      @variables, @block = *variables, block
    end

    def satisfied?
      values = @variables.collect {|variable| variable.value}
      @variables.each { |variable| }
      @block.call(*values)
    end
  end
end
