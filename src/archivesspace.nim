import httpclient, json

type
  ArchivesSpace* = ref object of RootObj
    ## This type describes an ArchivesSpace request.
    base_url*: string
    client: HttpClient

proc newArchivesSpace*(url: string="http://localhost:8089", user: string="admin", password: string="admin"): ArchivesSpace =
  let client = newHttpClient()
  let json_data = parseJson(client.post(url & "/users/" & user & "/login?password=" & password).body)
  let session = json_data["session"].getStr()
  client.headers = newHttpHeaders({"X-ArchivesSpace-Session": session})
  ArchivesSpace(base_url: url, client: client)

method get_all_repositories*(this: ArchivesSpace): string {. base .} =
  this.client.get(this.base_url & "/repositories").body

method get_repository_by_id*(this: ArchivesSpace, repo_id: int): string {. base .} =
  this.client.get(this.base_url & "/repositories/" & $repo_id).body

when isMainModule:
  var x = newArchivesSpace()
  echo x.get_repository_by_id(2)