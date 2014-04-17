require_relative 'variable'
require_relative 'constraint'

class Array
  def swap!(a,b)
    self[a], self[b] = self[b], self[a]
    self
  end
end

module CP
  class Problem
    
    attr_reader :variables
    attr_reader :constraints
    attr_reader :nodes_count
    attr_reader :revision_count
    
    attr_writer :heuristics

    def initialize
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
    
      @nodes_count = 0
      @revision_count = 0
      
      order
      
      forward_checking
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
    
      puts @nodes_count
    
      if @heuristics == "sdf"
        sdf_order(depth)
      end
    
      variable = @variable_order[depth]
      variable.domain.each_index do |domain_index|
      
        @nodes_count += 1
        variable.assign(domain_index)
        
        if consistent?(depth)
          if depth + 1 == size
            print_solution
            return true
          else
            if forward_checking(depth + 1)
              return true
            end
          end
        end
        undo_pruning(depth)
      end
      
      return false
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
      
        @revision_count += 1
        future_variable.revise(current_variable, depth)
        
        if future_variable.not_consistent
          return false
        end
      end
      
      return true
    end
  end
end
