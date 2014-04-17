require_relative 'solver'

include CP

problem = Problem.new
problem.variable(:c, (1..1).to_a)
problem.variable(:a, (1..5).to_a)
problem.variable(:b, (3..4).to_a)
problem.constrain(:a, :b) { |a, b| a > b }

problem.set_order(:b, :a, :c)
problem.heuristics = "sdf"
problem.solve

puts "Colour Petersen graph"
pietersen = Problem.new

colours = (1..3).to_a
not_equals_lambda = lambda { |a, b| a != b }

pietersen.variable(:o1, colours);
pietersen.variable(:o2, colours);
pietersen.variable(:o3, colours);
pietersen.variable(:o4, colours);
pietersen.variable(:o5, colours);

pietersen.variable(:i1, colours);
pietersen.variable(:i2, colours);
pietersen.variable(:i3, colours);
pietersen.variable(:i4, colours);
pietersen.variable(:i5, colours);

pietersen.constrain(:o1, :i1, &not_equals_lambda)
pietersen.constrain(:o2, :i2, &not_equals_lambda)
pietersen.constrain(:o3, :i3, &not_equals_lambda)
pietersen.constrain(:o4, :i4, &not_equals_lambda)
pietersen.constrain(:o5, :i5, &not_equals_lambda)

pietersen.constrain(:o1, :o2, &not_equals_lambda)
pietersen.constrain(:o2, :o3, &not_equals_lambda)
pietersen.constrain(:o3, :o4, &not_equals_lambda)
pietersen.constrain(:o4, :o5, &not_equals_lambda)
pietersen.constrain(:o5, :o1, &not_equals_lambda)

pietersen.constrain(:i1, :i3, &not_equals_lambda)
pietersen.constrain(:i3, :i5, &not_equals_lambda)
pietersen.constrain(:i5, :i2, &not_equals_lambda)
pietersen.constrain(:i2, :i4, &not_equals_lambda)
pietersen.constrain(:i4, :i1, &not_equals_lambda)

pietersen.heuristics = "sdf"
pietersen.solve
puts pietersen.nodes_count

puts "Colour K_5 graph"
k5 = Problem.new
colours = (1..4).to_a

k5.variable(:a, colours);
k5.variable(:b, colours);
k5.variable(:c, colours);
k5.variable(:d, colours);
k5.variable(:e, colours);

vertices = [:a, :b, :c, :d, :e]
vertices.each do |v1|
  vertices.each do |v2|
    if v1 != v2
      k5.constrain(v1, v2, &not_equals_lambda)
    end
  end
end

k5.heuristics = "sdf"
k5.solve
puts k5.nodes_count
