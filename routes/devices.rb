class App < Sinatra::Base
  register Sinatra::Namespace

  # Begin devices namespace
  namespace '/devices' do
    
    # Register device
    post '/register' do
      content_type 'application/json'
    
      begin
        body_params = JSON.parse(request.body.read)
        token_repr = body_params["token"]
        device_token = body_params["device_token"]
        device_name = body_params["device_name"]
        model = body_params["model"]
        system_version = body_params["system_version"]
        app_version = body_params["app_version"]
        app_bundle_version = body_params["app_bundle_version"]
        locale = body_params["locale"]
        development = body_params["development"]
      rescue Exception => e
        give_error(400, ERROR_INVALID_BODY, "The body is not valid.").to_json
      end
      
      token = token_from_representation(token_repr)
      user = token.user
      
      register_device_for_user(token.user, device_token, device_name, model, system_version, app_version, app_bundle_version, locale, development)
      
      Urbanairship.register_device(device_token, :alias => device_name, :tags => [ model, system_version, "v" + app_version, "v" + app_bundle_version, locale ])
      
      return { "success" => true }.to_json
    end
  
  end # End namespace /devices
  
  # Find token by representation of the token
  def token_from_representation(repr)
    token = Token.first(:token => repr)
    if token.nil?
      give_error(400, ERROR_USER_TOKEN_NOT_FOUND, "Token not found.").to_json
    end
    
    return token
  end
  
  # Register a device for a user
  def register_device_for_user(user, device_token, device_name, model, system_version, app_version, app_bundle_version, locale, development)
    device = Device.first(:device_token => device_token)
    if device.nil?
      # Create new device if it does not already exist
      device = Device.new
      user.devices.push(device)
    end
    
    # Update information
    device.device_token = device_token
    device.device_name = device_name
    device.model = model
    device.system_version = system_version
    device.app_version = app_version
    device.app_bundle_version = app_bundle_version
    device.locale = locale
    device.development = development
    
    device.save!
  end

end