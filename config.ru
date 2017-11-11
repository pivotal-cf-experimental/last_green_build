require './last_green_build.rb'

target = ENV['TARGET'] or raise 'missing TARGET environment variable: the url of the concourse ATC to check'
pipeline = ENV['PIPELINE'] or raise 'missing PIPELINE environment variable: the name of the pipeline to check'
job = ENV['JOB'] or raise 'missing JOB environment variable: the name of the job to check'
username = ENV['CONCOURSE_USERNAME'] or raise 'missing CONCOURSE_USERNAME environment variable: basic auth user for this concourse'
password = ENV['CONCOURSE_PASSWORD'] or raise 'missing CONCOURSE_PASSWORD environment variable: basic auth password for user'
skip_ssl = ENV['SKIP_SSL']

run LastGreenBuild.new(
  target: target,
  pipeline: pipeline,
  job: job,
  username: username,
  password: password,
  skip_ssl: skip_ssl)
