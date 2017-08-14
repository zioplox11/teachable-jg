VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
  c.ignore_localhost = false
  c.default_cassette_options = { :record => :new_episodes }
  c.configure_rspec_metadata!
  c.after_http_request do |request, response|
    $last_vcr_request  = request
    $last_vcr_response = response
  end
end