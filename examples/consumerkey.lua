local OVH = require 'ovh-api'

local client = OVH.client(
  'ovh-eu',
  'API_KEY',
  'SECRET_KEY',
)

local data = client:request_consumerkey({
  { method = 'GET', path = '/*'},
  { method = 'POST', path = '/*'},
  { method = 'PUT', path = '/*'}
})

print('Your consumer key is: '..data.consumerKey..'\n')
print('Visit '..data.validationUrl..' to validate the consumer key\n')
print('Press enter when validated\n')
io.read()
print('Welcome '..client:get('/me')['firstname'])
