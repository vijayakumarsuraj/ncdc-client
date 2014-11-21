require 'rspec'
require 'logger'

require 'ncdc/client'

RSpec.configure do |c|
  c.before(:each) do
    @client = Ncdc::Client.new('<auth token>')
    @client.limit = 1000
    @client.logging = Logger::DEBUG
  end
end
