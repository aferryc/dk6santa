defmodule TestHelper do
  def basic_auth_token() do
    user = Dk6santa.Helper.env(:basic_user)
    pass = Dk6santa.Helper.env(:basic_user)
    token = Base.encode64("#{user}:#{pass}")
    "Basic #{token}"
  end
end
