#require 'percy-capybara'
require 'plist'
require 'byebug'
require 'percy'

images_dir = "Logs/Test/Attachments"

class Screenshot
  def initialize(client, build, path, data)
    @client = client
    @build = build
    @path = path
    @data = data
  end


  def rescue_connection_failures(&block)
    raise ArgumentError.new('block is required') if !block_given?
    begin
      block.call
    rescue Percy::Client::ServerError,  # Rescue server errors.
        Percy::Client::PaymentRequiredError,  # Rescue quota exceeded errors.
        Percy::Client::ConnectionFailed,  # Rescue some networking errors.
        Percy::Client::TimeoutError => e
      Percy.logger.error(e)
      @enabled = false
      @failed = true
      nil
    end
  end

  def failed?
    @failed
  end

  attr_reader :client

  def load_resources
    resources = []
    image_path = path_as_png_url
    index_path = path_as_index_url
    #.gsub('/','_').gsub('"','_').gsub(' ','_')
    html = "<img src=\"#{image_path}\" height=\"1136\" width=\"640\">"
    resources << Percy::Client::Resource.new(index_path, is_root:true, content:html)
    #byebug
    resources << Percy::Client::Resource.new(image_path, content: File.read(@data[:image]))
    #File.open("index.html", 'w') { |file| file.write(html) }
    #File.open(image_path, 'w') { |file| file.write(File.read(@data[:image])) }
  end

  def path_as_png_url
    "/" + @path.gsub('"','_').gsub(' ','_') + ".png"
  end

  def path_as_index_url
    "/index/" + @path.gsub('"','_').gsub(' ','_') + ".html"
  end

  def current_build_id
    @build['data']['id']
  end

  def upload
    options = {}
    resources = load_resources
    resource_map = {}
    resources.each do |r|
      resource_map[r.sha] = r
    end

    rescue_connection_failures do
      start = Time.now
      rescue_connection_failures do
        snapshot = client.create_snapshot(current_build_id, resources, options)
        snapshot['data']['relationships']['missing-resources']['data'].each do |missing_resource|
          sha = missing_resource['id']
          client.upload_resource(current_build_id, resource_map[sha].content)
        end
        Percy.logger.debug { "All snapshot resources uploaded (#{Time.now - start}s)" }

        # Finalize the snapshot.
        client.finalize_snapshot(snapshot['data']['id'])
      end
      if failed?
        Percy.logger.error { "Percy build failed! Check log above for errors." }
        return
      end
      true
    end
  end
end

class Build
  def initialize()
    @client = Percy.client
    @build = Percy.create_build(client.config.repo)
  end

  def screenshot(path, data)
    Screenshot.new(Percy.client, @build, path, data)
  end

  def finalize
    Percy.finalize_build(build_id)
  end

  def build_id
    @build['data']['id']
  end


  attr_accessor :client
end

def extract_tests(nodes, result, ident = 0, titles = [])
  existing_titles = {}
  nodes.each_with_index do |node, node_idx|
    puts "#{'  '*ident} IDX:#{node_idx} title:#{node["Title"]}"
    if node["Title"]
      title = node["Title"]
      if existing_titles[title]
        existing_titles[title] += 1
        title = "#{title}#{existing_titles[title]}"
      else
        existing_titles[title] = 1
      end
      ntitles = titles + [title]
    else
      ntitles = titles
    end
    extract_tests(node["Tests"], result, ident+1, ntitles) if node["Tests"]
    extract_tests(node["Subtests"], result, ident+1, ntitles) if node["Subtests"]
    extract_tests(node["ActivitySummaries"], result, ident+1, ntitles) if node["ActivitySummaries"]
    extract_tests(node["SubActivities"], result, ident+1, ntitles) if node["SubActivities"]
    if node["HasScreenshotData"]
      path = ntitles.join("/")
      puts "#{'  '*ident} title:#{ntitles.join("/")} UUID:#{node["UUID"]}"
      result[path] = {UUID: node["UUID"]}
    end
  end
end

derived_data_dir = "./derived-data"
summaries = Dir[File.join(derived_data_dir, "Logs", "Test", "*_TestSummaries.plist")]
summaries.each do |summary|
  result = Plist::parse_xml(summary)
  puts "Summary:#{result}"
  screenshots = {}
  extract_tests(result["TestableSummaries"], screenshots)
  build = Build.new
  begin
    screenshots.each do |path, data|
      image = File.join(derived_data_dir, "Logs", "Test", "Attachments", "Screenshot_#{data[:UUID]}.png")
      screenshot = build.screenshot(path, data.merge(image: image))
      screenshot.upload
      puts "path:\"#{path}\" data:#{data} image:#{image}"
    end
  ensure
    build.finalize
  end
end
