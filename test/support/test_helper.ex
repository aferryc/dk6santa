defmodule TestHelper do
  def basic_auth_token() do
    user = Application.get_env(:dk6santa, :basic_user)
    pass = Application.get_env(:dk6santa, :basic_user)
    token = Base.encode64("#{user}:#{pass}")
    "Basic #{token}"
  end
end
