require "kemal"

get "/" do
  "Hello World of Crystal and Kemal!"
  %Q(
  <html><head><title>Hello World</title></head>
  <body><h1>Hello World</h1>
  <form action="/test">
  <div><label for="param1">Param1</label><input type="text" name="param1" id="param1" /></div>
  <div><label for="param2">Param2</label><input type="text" name="param2" id="param2" /></div>
  <div><input type="submit" value="Submit" /></div>
  </form>
  </body>
  </html>
  )
end

get "/fred" do |env|
  puts "\nenv.params:#{env.params.inspect}"
  msg = HTML.escape(env.params.query["msg"]? || "")
  title = "Hello World of Crystal and Kemal (Math: #{5 * 5}) and Fred!"
  "<html><head><title>#{title}</title></head><body><h1>#{title}</h1><p><b>Msg:</b><pre>#{msg}</pre></p></body></html>"
end

get "/test" do |env|
  param1 = HTML.escape(env.params.query["param1"]? || "")
  param2 = HTML.escape(env.params.query["param2"]? || "")
  title = "Hello World of Crystal and Kemal GET Test"
  %Q(
  <html><head><title>#{title}</title></head>
  <body><h1>#{title}</h1><p><b>1:</b><pre>#{param1}</pre></p>
  <p><b>2:</b><pre>#{param2}</pre></p>
  <div><a href="/">Back</a>
  </body>
  </html>
  )
end

post "/test" do |env|
  param1 = HTML.escape(env.params.body["param1"]? || env.params.json["param1"]?.as(String) || "")
  param2 = HTML.escape(env.params.body["param2"]? || env.params.json["param2"]?.as(String) || "")
  puts "env.params.query:#{env.params.query}"
  puts "env.params.body:#{env.params.body}"
  puts "env.params.json:#{env.params.json}"
  puts "env.params:#{env.params.inspect}"
  title = "Hello World of Crystal and Kemal POST Test"
  %Q(
  <html><head><title>#{title}</title></head>
  <body><h1>#{title}</h1><p><b>1:</b><pre>#{param1}</pre></p>
  <p><b>2:</b><pre>#{param2}</pre></p></body>
  </html>
  )
end

class MyApp
  property config = Kemal.config

  def initialize
    @config.setup
    HTTP::Server.build_middleware(@config.handlers)
  end

  def call(env)
    @config.handlers.first.call(env)
  end

end
