Gem::Specification.new do |s|
  s.name        = 'dkvs'
  s.version     = '0.0.1'
  s.date        = '2019-07-29'
  s.summary     = "Distributed Key/Value Store"
  s.description = "A simple key/value store"
  s.authors     = ["Edward Dal Santo"]
  s.email       = "ejds001@gmail.com"
  s.add_dependency("rspec")
  s.add_dependency("pry")
  s.add_dependency("protobuf")
  s.add_dependency("google-protobuf")
end
