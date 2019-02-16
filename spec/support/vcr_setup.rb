VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :typhoeus
  c.configure_rspec_metadata!
  Rails.application.credentials.integrations.each_pair do |key, secret|
    c.filter_sensitive_data("<#{key.to_s.upcase}_SECRET>") { secret }
  end
end
