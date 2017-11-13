require 'webrick'
require 'net/http'
require 'json'
require 'openssl'

class LastGreenBuild

  def initialize(target:, pipeline:, job:, username:, password:, skip_ssl:)
    @target = target
    @pipeline = pipeline
    @job = job
    @username = username
    @password = password
    @skip_ssl = skip_ssl
  end

  def fetch_token
    uri = URI("https://#{@target}/api/v1/teams/main/auth/token")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth(@username, @password)
    res = make_request(req)
    JSON.parse(res.body)
  end

  def fetch_job_info(token)
    uri = URI("https://#{@target}/api/v1/teams/main/pipelines/#{@pipeline}/jobs/#{@job}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "#{token['type']} #{token['value']}"
    res = make_request(req)
    JSON.parse(res.body)
  end

  def make_request(req)
    uri = req.uri
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: verify_mode) { |http| http.request(req) }
  end

  def verify_mode
    @skip_ssl.nil? ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end

  def call(env)
    token = fetch_token
    job_info = fetch_job_info(token)
    last_completed = job_info['finished_build']['end_time']

    res = Rack::Response.new
    res.set_header('Access-Control-Allow-Origin', '*')
    res.write last_completed
    res.finish
  end
end
