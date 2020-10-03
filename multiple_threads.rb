# ab -n 10000 -c 100 -p ./section_one/ostechnix.txt localhost:1234/
# head -c 100000 /dev/urandom > section_one/ostechnix_big.txt

require 'socket'
require './lib/response'
require './lib/request'
require './lib/errors/not_found_error.rb'
require './lib/errors/forbidden_error.rb'

MAX_EOL = 2

socket = TCPServer.new(ENV['HOST'], ENV['PORT'])

def handle_request(request_text, client)
  request = Request.new(request_text)
  puts "#{client.peeraddr[3]}"

  file_path = File.dirname(__FILE__) + request.path
  raise NotFoundError unless File.exist?(file_path)
  raise ForbiddenError unless File.readable?(file_path)

  file_content = File.read(file_path)
  response = Response.new(code: 200, data: "12312312312")

  response.send(client)

  client.shutdown
end

def handle_connection(client)
  request_text = ''
  eol_count = 0

  loop do
    buf = client.recv(1)
    puts "#{client} #{buf}"
    request_text += buf
    eol_count += 1 if buf == "\n"

    if eol_count == MAX_EOL
      handle_request(request_text, client)
      break
    end

    # sleep 1
  end
rescue BaseError => e
  handle_error(client, e.code, e.message)
rescue => e
  handle_error(client, 500, "Internal Server Error")
end

def handle_error(client, code, message)
  response = Response.new(code: code, data: message)
  response.send(client)

  client.close
end

puts "Listening on #{ENV['HOST']}:#{ENV['PORT']}. Press CTRL+C to cancel."

loop do
  Thread.start(socket.accept) do |client|
    handle_connection(client)
  end
end
