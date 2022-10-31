class AutoJwt
  def initialize(app)
    @app = app
  end

  def call(env)
    # jwt跳过以下检查
    return @app.call(env) if ['/api/v1/session', '/api/v1/validation_codes'].include? env['PATH_INFO']

    header = env['HTTP_AUTHORIZATION']
    jwt = header.split(' ')[1] rescue ' '
    begin
      payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } 
    rescue JWT::ExpiredSignature
      return [401, {}, [JSON.generate({msg: '登录已过期'})]]
    rescue
      return [401, {}, [JSON.generate({msg: '登录已失效'})]]
    end
    env['current_user_id'] = payload[0]['user_id'] rescue nil 
    # 状态码，响应头，响应体 执行所有controller 
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end
