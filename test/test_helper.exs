Mimic.copy(Application)
Mimic.copy(Dk6santa.Email)
Mimic.copy(Ecto.Adapters.SQL)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Dk6santa.Repo, :manual)
