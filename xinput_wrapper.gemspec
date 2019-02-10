Gem::Specification.new do |s|
  s.name = 'xinput_wrapper'
  s.version = '0.2.2'
  s.summary = 'A wrapper for the Linux utility xinput.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/xinput_wrapper.rb']
  s.add_runtime_dependency('c32', '~> 0.1', '>=0.1.2')
  s.signing_key = '../privatekeys/xinput_wrapper.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/xinput_wrapper'
end
