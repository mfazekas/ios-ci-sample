require 'percy/ios'
raise 'please pass derived-data as first argument' if ARGV[0].nil?
percy = Percy::IOS.new
percy.derived_data_dir=ARGV[0]
percy.upload_screenshots
