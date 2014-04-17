require_relative 'solver'

include CP

def colour_k_graph(k, heuristics)

  puts "Colour K_#{k} graph"

  not_equals_lambda = lambda { |a, b| a != b }

  k_graph = Problem.new
  colours = (1..k-1).to_a
  
  vertices = ('a'..'z').first(k).to_a
  
  vertices.each do |vertex|
    k_graph.variable(vertex, colours)
  end
  
  vertices.combination(2) do |v1, v2|
    k_graph.constrain(v1, v2, &not_equals_lambda)
  end
  
  k_graph.heuristics = heuristics
  k_graph.solve
  puts k_graph.nodes_count
  puts k_graph.revision_count
end

#colour_k_graph(10, :sdf)
#colour_k_graph(10, nil)

def colour_xy_graph(n, k, heuristics)

  puts "Colour xy_#{n} graph"

  not_equals_lambda = lambda { |a, b| a != b }

  xy_graph = Problem.new
  colours = (1..k).to_a
  
  vertices = (1..n).to_a
  
  vertices.each do |vertex|
    xy_graph.variable("v#{vertex}", colours)
  end
  
  vertices.combination(2) do |x, y|
    if x + y <= n and x * y <= n
      xy_graph.constrain("v#{x + y}", "v#{x*y}", &not_equals_lambda)
    end
  end
  
  vertices.each do |x|
    if x + x <= n and x * x <= n
      xy_graph.constrain("v#{x + x}", "v#{x*x}", &not_equals_lambda)
    end
  end
  
  xy_graph.heuristics = heuristics
  xy_graph.solve
  puts xy_graph.nodes_count
  puts xy_graph.revision_count
end

colour_xy_graph(500, 4, :sdf)
colour_xy_graph(500, 4, nil)
