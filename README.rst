Lightweight wrapper around OVH's APIs. Handles all the hard work including
credential creation and requests signing.

.. code:: lua

    local OVH = require 'ovh-api'

    local client = OVH.client(
      "ovh-eu",
      "API_KEY",
      "SECRET_KEY",
      "CONSUMER_KEY"
    )

    -- Print nice welcome message
    print("Welcome"..client:get('/me')['firstname'])

Installation
============

The easiest way to get the latest stable release is to grab it from ```luarocks``.

.. code:: bash

    luarocks install ovh-api

Example Usage
=============

Use the API on behalf of a user
-------------------------------

1. Create an application
************************

To interact with the APIs, the SDK needs to identify itself using an
``application_key`` and an ``application_secret``. To get them, you need
to register your application. Depending the API you plan yo use, visit:

- `OVH Europe <https://eu.api.ovh.com/createApp/>`_
- `OVH North-America <https://ca.api.ovh.com/createApp/>`_
- `So you Start Europe <https://eu.api.soyoustart.com/createApp/>`_
- `So you Start North America <https://ca.api.soyoustart.com/createApp/>`_
- `Kimsufi Europe <https://eu.api.kimsufi.com/createApp/>`_
- `Kimsufi North America <https://ca.api.kimsufi.com/createApp/>`_
- `RunAbove <https://api.runabove.com/createApp/>`_

Once created, you will obtain an **application key (AK)** and an **application
secret (AS)**.

2. Authorize your application to access a customer account
**********************************************************

To allow your application to access a customer account using the API on your
behalf, you need a **consumer key (CK)**.

Here is a sample code you can use to allow your application to access a
customer's informations:

.. code:: lua

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


Returned ``consumerKey`` should then be kept to avoid re-authenticating your
end-user on each use.

.. note:: To request full and unlimited access to the API, you may use wildcards:

.. code:: lua

    client:request_consumerkey({
      { method = 'GET', path = '/*'},
      { method = 'POST', path = '/*'},
      { method = 'PUT', path = '/*'},
      { method = 'DELETE', path = '/*'}
    })

List application authorized to access your account
--------------------------------------------------

Thanks to the application key / consumer key mechanism, it is possible to
finely track applications having access to your data and revoke this access.
This examples lists validated applications. It could easily be adapted to
manage revocation too.

This example assumes an existing Configuration_ with valid ``API_KEY``,
``SECRET_KEY`` and ``CONSUMER_KEY``.

.. code:: lua

    local OVH = require '../ovh'

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

Supported APIs
==============

OVH Europe
----------

- **Documentation**: https://eu.api.ovh.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.ovh.com/console
- **Create application credentials**: https://eu.api.ovh.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.ovh.com/createToken/

OVH North America
-----------------

- **Documentation**: https://ca.api.ovh.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.ovh.com/console
- **Create application credentials**: https://ca.api.ovh.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.ovh.com/createToken/

So you Start Europe
-------------------

- **Documentation**: https://eu.api.soyoustart.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.soyoustart.com/console/
- **Create application credentials**: https://eu.api.soyoustart.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.soyoustart.com/createToken/

So you Start North America
--------------------------

- **Documentation**: https://ca.api.soyoustart.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.soyoustart.com/console/
- **Create application credentials**: https://ca.api.soyoustart.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.soyoustart.com/createToken/

Kimsufi Europe
--------------

- **Documentation**: https://eu.api.kimsufi.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://eu.api.kimsufi.com/console/
- **Create application credentials**: https://eu.api.kimsufi.com/createApp/
- **Create script credentials** (all keys at once): https://eu.api.kimsufi.com/createToken/

Kimsufi North America
---------------------

- **Documentation**: https://ca.api.kimsufi.com/
- **Community support**: api-subscribe@ml.ovh.net
- **Console**: https://ca.api.kimsufi.com/console/
- **Create application credentials**: https://ca.api.kimsufi.com/createApp/
- **Create script credentials** (all keys at once): https://ca.api.kimsufi.com/createToken/

Runabove
--------

- **Community support**: https://community.runabove.com/
- **Console**: https://api.runabove.com/console/
- **Create application credentials**: https://api.runabove.com/createApp/
- **High level SDK**: https://github.com/runabove/python-runabove
