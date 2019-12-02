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

method get_list_of_users*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes containing details about each user in the instance of ArchivesSpace.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_list_of_users()
  ##
  var page = 1
  var data = parseJson(this.client.get(this.base_url & "/users?page=" & $page & "&page_size=10").body)
  let last_page = data["last_page"].getInt()
  while page <= last_page:
    data = parseJson(this.client.get(this.base_url & "/users?page=" & $page & "&page_size=10").body)
    let users = data["results"].getElems()
    for user in users:
      result.add(user)
    page += 1

method create_user*(this: ArchivesSpace, username: string, password: string, is_admin: bool= false, full_name: string=""): string {. base .} =
  ## Creates a new user.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.create_user("Ryan", "ryan", true, "Ryan Mueller")
  var name = ""
  if full_name == "":
    name = username
  else:
    name = full_name
  let user = %*{
    "username": username,
    "name": name,
    "is_admin": is_admin,
  }
  this.client.post(this.base_url & "/users?password=" & password, body = $user).status

method delete_user*(this: ArchivesSpace, user_id: string): string {. base .} =
  ## Deletes a user.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_user()
  this.client.delete(this.base_url & "/users/" & user_id).status

method get_a_users_details*(this: ArchivesSpace, user_id: string): string {. base .} =
  ## Gets a user's details including current permissions.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_users_details("5")
  this.client.get(this.base_url & "/users/" & user_id).body

method list_all_corporate_entity_agent_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of corporate entity agent ids as strings.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_corporate_entity_agent_ids()
  ##
  this.client.get(this.base_url & "/agents/corporate_entities?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method list_all_corporate_entity_agents*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of corporate entity agents.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_corporate_entity_agents()
  ##
  var page = 1
  var data = parseJson(this.client.get(this.base_url & "/agents/corporate_entities?page=" & $page & "&page_size=10").body)
  let last_page = data["last_page"].getInt()
  while page <= last_page:
    data = parseJson(this.client.get(this.base_url & "/agents/corporate_entities?page=" & $page & "&page_size=10").body)
    let entities = data["results"].getElems()
    for entity in entities:
      result.add(entity)
    page += 1

method get_a_corporate_entity_by_id*(this: ArchivesSpace, entity_id: string): string {. base .} =
  ## Gets a corporate entity by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_corporate_entity_by_id("2")
  ##
  this.client.get(this.base_url & "/agents/corporate_entities/" & entity_id).body

method delete_corporate_entity*(this: ArchivesSpace, entity_id: string): string {. base .} =
  ## Deletes a coporate entity.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_corporate_entity("2")
  ##
  this.client.delete(this.base_url & "/agents/corporate_entities/" & entity_id).status

method list_all_family_agents*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of family agents..
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_family_agents()
  ##
  var page = 1
  var data = parseJson(this.client.get(this.base_url & "/agents/families?page=" & $page & "&page_size=10").body)
  let last_page = data["last_page"].getInt()
  while page <= last_page:
    data = parseJson(this.client.get(this.base_url & "/agents/families?page=" & $page & "&page_size=10").body)
    let families = data["results"].getElems()
    for family in families:
      result.add(family)
    page += 1

method list_all_family_agent_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of family agent ids as strings.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_family_agent_ids()
  ##
  this.client.get(this.base_url & "/agents/families?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method get_a_family_by_id*(this: ArchivesSpace, family_id: string): string {. base .} =
  ## Gets a family by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_family_by_id("2")
  ##
  this.client.get(this.base_url & "/agents/families/" & family_id).body


when isMainModule:
  let x = newArchivesSpace()
  echo x.get_a_family_by_id("1")