import httpclient, json

type
  ArchivesSpace* = ref object of RootObj
    ## This type describes an ArchivesSpace request.
    base_url*: string
    client: HttpClient
    headers: string

proc newArchivesSpace*(url: string="http://localhost:8089", user: string="admin", password: string="admin"): ArchivesSpace =
  let client = newHttpClient()
  let json_data = parseJson(client.post(url & "/users/" & user & "/login?password=" & password).body)
  let session = json_data["session"].getStr()
  let headers = $(%{
    "X-ArchivesSpace-Session": %session
  }) & "\c\l"
  ArchivesSpace(base_url: url, client: client, headers: headers)

when isMainModule:
  var x = newArchivesSpace()
  echo x.headers