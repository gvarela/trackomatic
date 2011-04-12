require 'spec_helper'

describe Trackomatic::CollectorServer do
  include Goliath::TestHelper

  let(:err) { Proc.new { |c| fail "HTTP Request failed #{c.response}" } }

  it "responds with a gif" do
    with_api(Trackomatic::CollectorServer) do
      get_request({}, err) do |c|
        c.response_header.status.should == 200
        c.response_header['CONTENT_TYPE'].should == 'image/gif'
      end
    end
  end

  it "collects the request into mongo" do
    with_api(Trackomatic::CollectorServer) do
      get_request({}, err) do |c|

      end
    end
  end
end
