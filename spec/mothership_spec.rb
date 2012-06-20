require 'spec_helper'
require 'mothership'

describe Mothership do
  before(:all) do
    Fog.mock!
  end

  let(:mothership) { Mothership.new }

  it "adds a new node to it's nodes" do
    expect { mothership.spawn_node }.to change { mothership.nodes.length }.by(1)
  end
end
