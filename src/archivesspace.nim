import httpclient, json

type
  ArchivesSpace* = ref object of RootObj
    ## This type describes an ArchivesSpace request.
    base_url*: string
    client: HttpClient
    username: string

proc newArchivesSpace*(url: string="http://localhost:8089", user: string="admin", password: string="admin"): ArchivesSpace =
  let client = newHttpClient()
  let json_data = parseJson(client.post(url & "/users/" & user & "/login?password=" & password).body)
  let session = json_data["session"].getStr()
  client.headers = newHttpHeaders({"X-ArchivesSpace-Session": session})
  ArchivesSpace(base_url: url, client: client, username: user)

method get_all_repositories*(this: ArchivesSpace): string {. base .} =
  this.client.get(this.base_url & "/repositories").body

method get_repository_by_id*(this: ArchivesSpace, repo_id: int): string {. base .} =
  this.client.get(this.base_url & "/repositories/" & $repo_id).body

method create_repository*(this: ArchivesSpace, repo_code: string, repo_name: string): string {. base .} =
  ## Creates a new repository in the ArchivesSpace instance.
  ##
  ## Requires:
  ##   repo_code (string): An unique numerical value to serve as an identifier.
  ##   repo_name (string): The name of the new repository.
  ##
  ## Returns:
  ##   string: An HTTP status code. (200, 400, or 403)
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    var x = newArchivesSpace()
  ##    echo x.create_repository("7", "Nim Test")
  ##
  let body = %*{
    "repo_code": repo_code,
    "name": repo_name,
    "created_by": this.username,
    "publish": true
  }
  this.client.post(this.base_url & "/repositories", body = $body).status

method delete_repository*(this: ArchivesSpace, repo_code: string): string {. base .} =
  ## Deletes an existing repository.
  ##
  ## Examples
  ##
  ## .. code-block:: nim
  ##
  ##    var x = newArchivesSpace()
  ##    echo x.delete_repository("7")
  ##
  this.client.delete(this.base_url & "/repositories/" & repo_code).status


when isMainModule:
  var x = newArchivesSpace()
  echo x.delete_repository("103")