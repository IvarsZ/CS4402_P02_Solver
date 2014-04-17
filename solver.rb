class Array
  def swap!(a,b)
    self[a], self[b] = self[b], self[a]
    self
  end
end

class Problem
  
  attr_reader :variables
  attr_reader :constraints

  def initialize(heuristics)
    @heuristics = heuristics
    @variables = Hash.new
    @constraints = Array.new
  end
  
  def size
    @variables.length
  end

  def variable(name, *domain)
    @variables[name] = Variable.new(name, *domain)
  end

  def constrain(*variable_names, &block)
  
    # TODO local?, size.

    variables = variable_names.collect {|name| @variables[name]}
    constraint = Constraint.new(variables, &block)
    @constraints << constraint

    variables.each do |variable|
      variable.add_constraint(constraint)
    end
  end

  # forward checking
  def solve()
    order
    forward_checking(0)
  end
  
  def set_order(*names_order)
    @variable_order = names_order.collect {|name| @variables[name]}
  end
  
  def order
    @variable_order ||= @variables.values
  end
  
  def sdf_order(depth)
    sdf_variable = @variable_order.last(size - depth).each_with_index.min { |v1, v2| v1[0].domain_size <=> v2[0].domain_size }[1]
    @variable_order.swap!(sdf_variable + depth, depth)
  end
  
  def forward_checking(depth)
  
    if @heuristics == "sdf"
      sdf_order(depth)
    end
  
    variable = @variable_order[depth]
    variable.domain.each_index do |domain_index|
    
      variable.assign(domain_index)
      
      if consistent?(depth)
        if depth + 1 == size
          print_solution
        else
          forward_checking(depth + 1)
        end
      end
      undo_pruning(depth)
    end
  end
  
  def undo_pruning(depth)    
    @variable_order.last(size - depth - 1).each { |variable| variable.undo_pruning(depth) }
  end
  
  def print_solution
    puts "A solution:"
    @variable_order.each do |variable|
      puts "#{variable.name}: #{variable.value}"
    end
    puts 
  end
  
  def consistent?(depth)
  
    current_variable = @variable_order[depth]
    
    @variable_order.last(size - depth - 1).each do |future_variable|
    
      future_variable.revise(current_variable, depth)
      
      if future_variable.not_consistent
        return false
      end
    end
    
    return true
  end
end

class Variable
  attr_reader :name
  attr_reader :domain
  attr_accessor :value
  
  def initialize(name, domain)
    @name, @domain = name, domain
    @value = nil
    @constraints = Hash.new { |constraints, variable| constraints[variable] = Array.new }
    @values_pruned_at = Array.new
  end
  
  def add_constraint(constraint)
    constraint.variables.each do |variable|
      if variable != self
        @constraints[variable] << constraint
      end
    end
  end
  
  def not_consistent
    @domain.empty?
  end
  
  def domain_size
    @domain.length
  end
  
  def assign(domain_index)
    @value = domain[domain_index]
  end
  
  def revise(variable, depth)
    @domain, @values_pruned_at[depth] = @domain.partition { |value| has_support?(value, variable) }
  end
  
  def has_support?(value, variable)
    @value = value
    all_satisfied = @constraints[variable].all? { |constraint| constraint.satisfied? }
    @value = nil;
    all_satisfied
  end
  
  def undo_pruning(depth)
    @domain.push(*@values_pruned_at[depth])
  end
end

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

problem = Problem.new("sdf")
problem.variable(:c, (1..1).to_a)
problem.variable(:a, (1..5).to_a)
problem.variable(:b, (3..4).to_a)
problem.constrain(:a, :b) { |a, b| a > b }

problem.set_order(:b, :a, :c)
problem.solve
