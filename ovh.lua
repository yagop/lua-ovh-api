local https = require 'ssl.https'
local URL = require 'socket.url'
local crypto = require 'crypto'
local json = require 'dkjson'
local ltn12 = require 'ltn12'

local Ovh = {
  _VERSION     = 'ovh-api v1.0.0',
  _DESCRIPTION = [[
    Simple lua wrapper over the OVH REST API.
    It handles requesting credential, signing queries...
    - To get your API keys: https://eu.api.ovh.com/createApp/
    - To get started with API: https://api.ovh.com/g934.first_step_with_api
  ]],
  _URL         = 'https://github.com/yagop/lua-ovh-api',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2015 Yago Pérez Sáiz

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

Ovh.__index = Ovh

local ENDPOINTS = {
  ['ovh-eu'] = 'https://eu.api.ovh.com/1.0',
  ['ovh-ca'] = 'https://ca.api.ovh.com/1.0',
  ['kimsufi-eu'] = 'https://eu.api.kimsufi.com/1.0',
  ['kimsufi-ca']  = 'https://ca.api.kimsufi.com/1.0',
  ['soyoustart-eu'] = 'https://eu.api.soyoustart.com/1.0',
  ['soyoustart-ca'] = 'https://ca.api.soyoustart.com/1.0',
  ['runabove-ca'] = 'https://api.runabove.com/1.0'
}

-- Get the api consumer key
function Ovh:request_consumerkey(accessRules)
  -- By default read only
  accessRules = accessRules or {
    [1] = { method = 'GET', path = '/*'}
  }
  local reqbody = json.encode({
    accessRules = accessRules
  })
  local headers = {
    ['X-Ovh-Application'] = self.api_key,
    ['content-type'] = 'application/json',
    ["content-length"] = tostring(#reqbody)
  }
  local respbody = {}
  local a,code = https.request{
    url = self.api_base..'/auth/credential',
    headers = headers,
    method = 'POST',
    source = ltn12.source.string(reqbody),
    sink = ltn12.sink.table(respbody)
  }
  respbody = table.concat(respbody)
  local data = json.decode(respbody)

  if code >= 100 and code < 300 then
    self.consumer_key = data.consumerKey
    return data
  else
    if data.message then
      error(data.message)
    else
      error(code)
    end
  end
end

function Ovh.client(end_point, api_key, secret_key, consumer_key)
  local api_base = ENDPOINTS[end_point]
  -- Default end point
  api_base = api_base or ENDPOINTS['ovh-eu']
  local self = setmetatable({
    api_base = api_base,
    api_key = api_key,
    secret_key = secret_key,
    consumer_key = consumer_key
  }, Ovh)
  return self
end

function Ovh:auth_request(method, path, query, body)
  -- "$1$" + SHA1_HEX(AS+"+"+CK+"+"+METHOD+"+"+QUERY+"+"+BODY+"+"+TSTAMP)
  local url = self.api_base..path
  if  query then
    url = url..'?'
    for key, val in pairs(query) do
      key = URL.escape(key)
      val = URL.escape(val)
      url = url..key..'='..val..'&'
    end
  end
  local body = body or ''
  local timestamp = os.time()
  local text = table.concat({ self.secret_key,
    self.consumer_key,
    method,
    url,
    body,
    timestamp},'+')

  local sign = '$1$'..crypto.digest('sha1', text, false)

  local headers = {
    ['Content-type'] = 'application/json',
    ["content-length"] = tostring(#body),
    ['X-Ovh-Timestamp'] = timestamp,
    ['X-Ovh-Signature'] = sign,
    ['X-Ovh-Consumer'] = self.consumer_key,
    ['X-Ovh-Application'] = self.api_key
  }

  local respbody = {}
  local a,code = https.request{
    url = url,
    sink = ltn12.sink.table(respbody),
    headers = headers,
    method = method,
    source = ltn12.source.string(body)
  }
  respbody = table.concat(respbody)
  local data = json.decode(respbody)

  if code >= 100 and code < 300 then
    return data
  else
    if data.message then
      error(data.message)
    else
      error(code)
    end
  end
end

function Ovh:get(path, query)
  return self:auth_request('GET', path, query)
end

function Ovh:put(path, data)
  return self:auth_request('PUT', path, nil, data)
end

function Ovh:post(path, data)
  return self:auth_request('POST', path, nil, data)
end

function Ovh:delete(path, data)
  return self:auth_request('DELETE', path, nil, data)
end

return Ovh
