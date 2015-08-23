local OVH = require 'ovh-api'

-- Get configuration from environment variables
local END_POINT    = os.getenv("OVH_END_POINT")
local API_KEY      = os.getenv("OVH_API_KEY")
local SECRET_KEY   = os.getenv("OVH_SECRET_KEY")
local CONSUMER_KEY = os.getenv("OVH_CONSUMER_KEY")

local client = OVH.client(
  END_POINT,
  API_KEY,
  SECRET_KEY,
  CONSUMER_KEY
)

local credentials = client:get('/me/api/credential', {status='validated'})

local text = 'List of validated credentials: \n'
for _, credentialId in pairs(credentials) do
  local url = '/me/api/credential/'..credentialId
  credential_data = client:get(url)
  credentail_app = client:get(url..'/application')

  local expiration = credential_data.expiration or ''
  local lastUse = credential_data.expiration or ''
  text = text..'Credential ID: '..credentialId..'\n'
    ..'Name: '..credentail_app.name..'\n'
    ..'Description: '..credentail_app.description..'\n'
    ..'Status: '..credentail_app.status..'\n'
    ..'Creation: '..credential_data.creation..'\n'
    ..'Expiration: '..expiration..'\n'
    ..'Last Use: '..lastUse..'\n\n'
end

print(text)
