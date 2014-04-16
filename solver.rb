class Problem
  
  attr_reader :variables
  attr_reader :constraints

  def initialize
    @variables = Hash.new
    @constraints = Array.new    
    @variables_to_constraints = Hash.new { |constraints, variable| constraints[variable] = Array.new }
  end

  def variable(name, *domain)
    @variables[name] = Variable.new(*domain)
  end

  def constrain(*variable_names, &block)

    variables = variable_names.collect {|name| @variables[name]}
    constraint = Constraint.new(variables, &block)
    @constraints << constraint

    variables.each do |variable|
      @variables_to_constraints[variable] << constraint
    end
  end

  def solve()
    @variables.each_value do |variable|
      variable.value = variable.domain.sample
    end
  
    @constraints.each do |constraint|
      unless constraint.satisfied?
        solve
      end
    end
  end
end

class Variable
  attr_reader :domain
  attr_accessor :value
  
  def initialize(domain)
    @domain = domain
    @value = nil
  end
end

class Constraint
  attr_reader :variables

  def initialize(*variables, &block)
    @variables, @block = *variables, block
  end

  def satisfied?
    values = @variables.collect {|variable| variable.value}
    @block.call(*values)
  end
end

problem = Problem.new
problem.variable(:a, (1..5).to_a)
problem.variable(:b, (3..4).to_a)
problem.variable(:c, (1..1).to_a)
problem.constrain(:a, :b) { |a, b| a > b }

problem.solve
puts problem.variables
