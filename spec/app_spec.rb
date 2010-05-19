require 'spec/spec_helper'

require 'sinatra'
require 'rack/test'
require 'app'

describe 'App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  before do
    @url = 'http://github.com/images/modules/header/logov3.png'
    @escaped_url = Rack::Utils.escape_html @url
    StubMe.stub!(:secret).and_return nil
  end

  it "resizes" do
    get "magick?url=#{@escaped_url}&size=200x"
    File.open('/tmp/xxx.png', 'w'){|f| f.write last_response.body}
    `identify /tmp/xxx.png`.should =~ /PNG 200x90 /
  end

  it "returns error when hash does not match" do
    StubMe.stub!(:secret).and_return 'xxx'
    get "magick?url=#{@escaped_url}&size=200x"
    last_response.body.should == 'Hash does not match!'
  end

  it "resizes if hash does match" do
    StubMe.stub!(:secret).and_return 'xxx'
    hash = MD5.md5('xxx' + {'url' => @url, 'size' => '200x'}.sort.inspect)
    get "magick?url=#{@escaped_url}&size=200x&hash=#{hash}"
    last_response.body.should_not == 'Hash does not match!'
  end
end