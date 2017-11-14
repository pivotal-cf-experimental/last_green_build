require 'webrick'
require 'net/http'
require 'json'
require 'openssl'

class LastGreenBuild

  def initialize(target:, pipeline:, job:, resource:, username:, password:, skip_ssl:)
    @target = target
    @pipeline = pipeline
    @job = job
    @resource = resource
    @username = username
    @password = password
    @skip_ssl = skip_ssl
  end
  
  def call(env)
    fetch_token!
    job_info = fetch_job_info
    last_build_id = job_info['finished_build']['id']
    last_completed = job_info['finished_build']['end_time']
    resource_list = get_resources_of_build(build_id: last_build_id)
    last_green_sha = resource_list['inputs'].find{ |i| i['name'] == @resource }['version']['ref']
    resource_versions = get_resource_version_list

    res = Rack::Response.new
    res.set_header('Access-Control-Allow-Origin', '*')
    res.write("#{last_completed}: #{last_build_id}: #{last_green_sha}")
    res.finish
  end
  
  private
  
  def fetch_token!
    uri = URI("https://#{@target}/api/v1/teams/main/auth/token")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth(@username, @password)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: verify_mode) { |http| http.request(req) }
    @token = JSON.parse(res.body)
  end

  def fetch_job_info
    make_request("https://#{@target}/api/v1/teams/main/pipelines/#{@pipeline}/jobs/#{@job}")
  end

  def make_request(url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "#{@token['type']} #{@token['value']}" if @token
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: verify_mode) { |http| http.request(req) }
    JSON.parse(res.body)
  end

  def get_resources_of_build(build_id:)
    # https://om.ci.cf-app.com/api/v1/builds/31830/resources
    make_request("https://#{@target}/api/v1/builds/#{build_id}/resources")
  end

  def get_resource_version_list
    # https://om.ci.cf-app.com/api/v1/teams/main/pipelines/opsmanager-master/resources/installation/versions?limit=100
    make_request("https://#{@target}/api/v1/teams/main/pipelines/#{@pipeline}/resources/#{@resource}/versions?limit=100")
  end

  def verify_mode
    @skip_ssl.nil? ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end
end
