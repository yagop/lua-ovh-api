local OVH = require 'ovh-api'

local client = OVH.client(
  'ovh-eu',
  'API_KEY',
  'SECRET_KEY',
  'CONSUMER_KEY'
)

-- Print nice welcome message
print('Welcome '..client:get('/me')['firstname'])
