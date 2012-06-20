require 'fog'
require 'node'

class Mothership
  attr_reader :nodes

  def initialize
    @nodes = []
  end

  def spawn_node
    @nodes << Node.new
  end
end
