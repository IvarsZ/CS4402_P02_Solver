module CP
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
end
