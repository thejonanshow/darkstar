require 'spec_helper'
require 'node'

describe Node do
  before(:all) do
    Fog.mock!
  end

  it "accepts a server argument" do
    node = Node.new(double)
    node.server.should be_a Fog::Compute::AWS::Server
  end

  it "raises an argument error without a server" do
    expect { Node.new }.to raise_error ArgumentError
  end
end
