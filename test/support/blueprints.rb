require 'machinist/data_mapper'
require 'faker'
require 'sham'

Encoder.blueprint do
  name { Faker::Name.name }
end

Video.blueprint do
  encoder
  file { File.dirname(__FILE__) + "/afile.mpg" }
  state { "unencoded" }
  created_at DateTime.now
  updated_at DateTime.now
end

Video.blueprint(:with_callback) do
  callback_url { "http://example.com/call/back/id" }
end

EncodingTask.blueprint do
  name { "320x240 flv"}
  output_file_suffix { ".foo.flv" }
  command { "-ss 00:00:02 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 180x136"}
end

EncodingTask.blueprint(:with_encoder) do
  name { "320x240 flv"}
  output_file_suffix { ".foo.flv" }
  command { "-ss 00:00:02 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 180x136"}
  encoder
end

