import httpclient, json, sequtils, strutils

type
  ArchivesSpace* = ref object of RootObj
    ## This type describes an ArchivesSpace request.
    base_url*: string
    client: HttpClient
    username: string

proc newArchivesSpace*(url: string="http://localhost:8089", user: string="admin", password: string="admin"): ArchivesSpace =
  ## Constructs a new ArchivesSpace instance.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##
  let client = newHttpClient()
  let json_data = parseJson(client.post(url & "/users/" & user & "/login?password=" & password).body)
  let session = json_data["session"].getStr()
  client.headers = newHttpHeaders({"X-ArchivesSpace-Session": session})
  ArchivesSpace(base_url: url, client: client, username: user)

method get_all_repositories*(this: ArchivesSpace): string {. base .} =
  ## Gets all repositories in an ArchivesSpace instance.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_all_respositories()
  ##
  this.client.get(this.base_url & "/repositories").body

method get_repository_by_id*(this: ArchivesSpace, repo_id: string): string {. base .} =
  ## Gets a repository by its id.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    x.get_repository_by_id("7")
  ##
  this.client.get(this.base_url & "/repositories/" & $repo_id).body

method create_repository*(this: ArchivesSpace, repo_code: string, repo_name: string): string {. base .} =
  ## Creates a new repository in the ArchivesSpace instance.
  ##
  ## Requires:
  ##   repo_code (string): An unique identifier.
  ##   repo_name (string): The name of the new repository.
  ##
  ## Returns:
  ##   string: An HTTP status code. (200, 400, or 403)
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.create_repository("NIM", "Nim Test")
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
  ##    let x = newArchivesSpace()
  ##    echo x.delete_repository("7")
  ##
  this.client.delete(this.base_url & "/repositories/" & repo_code).status

method update_repository_name*(this: ArchivesSpace, repo_code: string, repo_name: string): string {. base .} =
  ## Updates a repository name.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.update_repository.name("7", "New Repo Name")
  ##
  var old_data = parseJson(this.get_repository_by_id(repo_code))
  let body = %*{
    "repo_code": old_data["repo_code"].getStr(),
    "name": repo_name,
    "publish": old_data["publish"].getBool()
  }
  this.client.post(this.base_url & "/repositories/" & repo_code, body = $body).status

method get_list_of_user_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of user ids as strings.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_list_of_user_ids()
  ##
  this.client.get(this.base_url & "/users?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

when isMainModule:
  let x = newArchivesSpace()
  echo x.get_list_of_user_ids()