require 'rubygems'
require 'bundler/setup'
require 'goliath'
require 'em-synchrony/em-mongo'
require 'em-synchrony/em-http'
require 'pp'
require 'digest/md5'

# module Trackomatic
  class CollectorServer < Goliath::API
    use Goliath::Rack::Params
    use Rack::Session::Cookie, :key => '_trackomatic',
      # :domain => 'trackomatic.com',
      :path => '/',
      # :expire_after => 2592000,
      :secret => 'beer_is_good'

    ROOT_PATH = File.expand_path( File.join(File.dirname(__FILE__), '../../public') )

    def on_headers(env, headers)
      env['client-headers'] = headers
    end

    def response(env)
      record_request
      render_pixel
    end

    def render_pixel
      env['rack.session']['user_id'] ||= Digest::MD5.hexdigest(Time.now.to_i.to_s + rand(10000000000000).to_i.to_s)
      image_env = env.dup
      image_env['PATH_INFO'] = 'images/pixel.gif'
      response = ::Rack::File.new(ROOT_PATH).call(image_env)
      response[1]['Last-Modified'] = Time.now.httpdate
      response[1]['Cache-Control'] = "no-cache, no-store, max-age=0, must-revalidate"
      response[1]['Pragma'] = 'no-cache'
      response[1]['Expires'] = "Fri, 29 Aug 1997 02:14:00 EST"
      response
    end

    def record_request
      e = env
      EM.next_tick do
        doc = {
          http_method: e[Goliath::Request::REQUEST_METHOD],
          tracking_pixel_path: e[Goliath::Request::REQUEST_PATH],
          headers: e['client-headers'],
          params: e.params,
          tracked_uri: e['client-headers']['Referer'],
          params: e.params,
          date: Time.now.to_i,
        }
        e.mongo.update({ session: e['rack.session']['user_id'] }, {'$push' =>  {requests: doc }}, { upsert: true })
      end
    end
  end
# end
