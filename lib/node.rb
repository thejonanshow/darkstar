require 'config/secret/aws_credentials'
require 'eventmachine'

class Node
  attr_reader :server

  def initialize
  end

  def die!
    @server.destroy
  end
end
