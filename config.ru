#encoding: UTF-8
puts "[STARTING] rack..."
run lambda { |_| [200, { 'Content-Type' => 'text/plain' }, StringIO.new("Tweet something like \"@bitconversions 123 #EUR\"!")] }
