import httpclient, json, strutils, strformat

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
  let json_data = parseJson(client.post(fmt"{url}/users/{user}/login?password={password}").body)
  let session = json_data["session"].getStr()
  client.headers = newHttpHeaders({"X-ArchivesSpace-Session": session})
  ArchivesSpace(base_url: url, client: client, username: user)

method get_all_the_things(this: ArchivesSpace, request: string, last_page: int): seq[JsonNode] {. base .} =
  var page = 1
  var data: JsonNode
  while page <= last_page:
    data = parseJson(this.client.get(request).body)
    let things = data["results"].getElems()
    for thing in things:
      result.add(thing)
    page += 1

method list_all_corporate_entity_agent_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of corporate entity agent ids as strings.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_corporate_entity_agent_ids()
  ##
  this.client.get(fmt"{this.base_url}/agents/corporate_entities?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

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
  var data = parseJson(this.client.get(fmt"{this.base_url}/agents/corporate_entities?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/agents/corporate_entities?page={$page}&page_size=10", last_page)

method get_a_corporate_entity_by_id*(this: ArchivesSpace, entity_id: string): string {. base .} =
  ## Gets a corporate entity by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_corporate_entity_by_id("2")
  ##
  this.client.get(fmt"{this.base_url}/agents/corporate_entities/{entity_id}").body

method delete_corporate_entity*(this: ArchivesSpace, entity_id: string): string {. base .} =
  ## Deletes a coporate entity.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_corporate_entity("2")
  ##
  this.client.delete(fmt"{this.base_url}/agents/corporate_entities/{entity_id}").status

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
  var data = parseJson(this.client.get(fmt"{this.base_url}/agents/families?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/agents/families?page={$page}&page_size=10", last_page)

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
  this.client.get(fmt"{this.base_url}/agents/families/{family_id}").body

method delete_family*(this: ArchivesSpace, family_id: string): string {. base .} =
  ## Deletes a family.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_family("2")
  ##
  this.client.delete(fmt"{this.base_url}/agents/families/{family_id}").status

method list_all_person_agents*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of person agents.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_person_agents()
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/agents/people?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/agents/people?page={$page}&page_size=10", last_page)

method list_all_person_agent_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of person agent ids as strings.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_person_agent_ids()
  ##
  this.client.get(fmt"{this.base_url}/agents/people?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method get_a_person_by_id*(this: ArchivesSpace, person_id: string): string {. base .} =
  ## Gets a person by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_person_by_id("119")
  ##
  this.client.get(fmt"{this.base_url}/agents/people/{person_id}").body

method delete_person*(this: ArchivesSpace, person_id: string): string {. base .} =
  ## Deletes a person agent.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_person("2")
  ##
  this.client.delete(fmt"{this.base_url}/agents/people/{person_id}").status

method list_all_software_agents*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of software agents.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_software_agents()
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/agents/software?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/agents/software?page={$page}&page_size=10", last_page)

method list_all_software_agent_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Gets a sequence of software agent ids as strings.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_software_agent_ids()
  ##
  this.client.get(fmt"{this.base_url}/agents/software?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method get_a_software_by_id*(this: ArchivesSpace, software_id: string): string {. base .} =
  ## Gets a software by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_software_by_id("1")
  ##
  this.client.get(fmt"{this.base_url}/agents/software/{software_id}").body

method delete_software*(this: ArchivesSpace, software_id: string): string {. base .} =
  ## Deletes a software agent.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_software("2")
  ##
  this.client.delete(fmt"{this.base_url}/agents/software/{software_id}").status

method list_records_by_external_id*(this: ArchivesSpace, external_id: string, id_type: string = ""): string {. base .} =
  ## List records by their external ID(s).
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_records_by_external_id("DNKB292")
  ##
  var type_paramenter = ""
  if id_type != "":
    type_paramenter = fmt"&type={id_type}"
  this.client.get(fmt"{this.base_url}/by-external-id?eid={external_id}{type_paramenter}").body

method list_all_container_profile_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Get a list of Container Profile ids.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_container_profile_ids()
  ##
  this.client.get(fmt"{this.base_url}/container_profiles?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method list_all_container_profiles*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of container profiles.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_container_profiles()
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/contatiner_profiles?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/container_profiles?page={$page}&page_size=10", last_page)

method get_a_container_profile_by_id*(this: ArchivesSpace, container_profile_id: string): string {. base .} =
  ## Gets a container profile by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_container_profile_by_id("1")
  ##
  this.client.get(fmt"{this.base_url}/container_profile/{container_profile_id}").body

method delete_container_profile*(this: ArchivesSpace, identifier: string): string {. base .} =
  ## Deletes a container profile.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_container_profile("2")
  ##
  this.client.delete(fmt"{this.base_url}/container_profile/{identifier}").status

method get_global_preferences*(this: ArchivesSpace): string {. base .} =
  ## Get global preferences.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_global_preferences()
  ##
  this.client.get(fmt"{this.base_url}/current_global_preferences").body

method calculate_extent(this: ArchivesSpace, record_uri: string): string {. base .} =
  # Todo: this returns {"error":"undefined method `[]' for nil:NilClass"}.  What versions of AS support this?
  this.client.get(fmt"{this.base_url}/extent_calculator?record_uri={record_uri}").body

method get_job_types*(this: ArchivesSpace): string {. base .} =
  ## Lists all supported job types
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_job_types()
  ##
  this.client.get(fmt"{this.base_url}/job_types").body

method list_all_location_profile_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Get a list of Location Profile ids.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_location_profile_ids()
  ##
  this.client.get(fmt"{this.base_url}/location_profiles?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method list_all_location_profiles*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of location profiles.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_location_profiles()
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/location_profiles?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/location_profiles?page={$page}&page_size=10", last_page)

method get_a_location_profile_by_id*(this: ArchivesSpace, identifier: string): string {. base .} =
  ## Gets a location profile by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_location_profile_by_id("1")
  ##
  this.client.get(fmt"{this.base_url}/location_profile/{identifier}").body

method delete_location_profile*(this: ArchivesSpace, identifier: string): string {. base .} =
  ## Deletes a location profile.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_location_profile("2")
  ##
  this.client.delete(fmt"{this.base_url}/location_profile/{identifier}").status

method list_all_location_ids*(this: ArchivesSpace): seq[string] {. base .} =
  ## Get a list of Location ids.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_location_ids()
  ##
  this.client.get(fmt"{this.base_url}/locations?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method list_all_locations*(this: ArchivesSpace): seq[JsonNode] {. base .} =
  ## Gets a sequence of JsonNodes of locations.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_locations()
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/locations?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/locations?page={$page}&page_size=10", last_page)

method get_a_location_by_id*(this: ArchivesSpace, identifier: string): string {. base .} =
  ## Gets a location by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_location_by_id("1")
  ##
  this.client.get(fmt"{this.base_url}/location/{identifier}").body

method delete_location*(this: ArchivesSpace, identifier: string): string {. base .} =
  ## Deletes a location.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_location("2")
  ##
  this.client.delete(fmt"{this.base_url}/location/{identifier}").status

method list_all_reports*(this: ArchivesSpace): string {. base .} =
  ## List all reports.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_reports()
  ##
  this.client.get(fmt"{this.base_url}/reports").body

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
  this.client.get(fmt"{this.base_url}/repositories").body

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
  this.client.get(fmt"{this.base_url}/repositories/{$repo_id}").body

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
  this.client.post(fmt"{this.base_url}/repositories", body = $body).status

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
  this.client.delete(fmt"{this.base_url}/repositories/{repo_code}").status

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
  this.client.post(fmt"{this.base_url}/repositories/{repo_code}", body = $body).status

method list_all_accessions*(this: ArchivesSpace, repo_id: int): seq[JsonNode] {. base .} =
  ## Lists all accessions for a repository.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_accessions(2)
  ##
  var page = 1
  var data = parseJson(this.client.get(fmt"{this.base_url}/repositories/{repo_id}/accessions?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/repositories/{repo_id}/accessions?page={$page}&page_size=10", last_page)

method list_all_accession_ids*(this: ArchivesSpace, repo_id: int): seq[string] {. base .} =
  ## Get a list of accession ids for a repository.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.list_all_accession_ids(2)
  ##
  this.client.get(fmt"{this.base_url}/repositories/{repo_id}/accessions?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

method get_an_accession_by_id*(this: ArchivesSpace, repo_id: int, identifier: int): string {. base .} =
  ## Gets an accession by id.
  ##
  ## Examples:
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_an_accession_by_id(2, 2)
  ##
  this.client.get(fmt"{this.base_url}/repositories/{repo_id}/accessions/{identifier}").body

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
  this.client.get(fmt"{this.base_url}/users?all_ids=true").body.replace("[", "").replace("]", "").replace("\n", "").split(",")

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
  var data = parseJson(this.client.get(fmt"{this.base_url}/users?page={$page}&page_size=10").body)
  let last_page = data["last_page"].getInt()
  this.get_all_the_things(fmt"{this.base_url}/users?page={$page}&page_size=10", last_page)

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
  this.client.post(fmt"{this.base_url}/users?password={password}", body = $user).status

method delete_user*(this: ArchivesSpace, user_id: string): string {. base .} =
  ## Deletes a user.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.delete_user()
  this.client.delete(fmt"{this.base_url}/users/{user_id}").status

method get_a_users_details*(this: ArchivesSpace, user_id: string): string {. base .} =
  ## Gets a user's details including current permissions.
  ##
  ## Examples:
  ##
  ## .. code-block:: nim
  ##
  ##    let x = newArchivesSpace()
  ##    echo x.get_a_users_details("5")
  this.client.get(fmt"{this.base_url}/users/{user_id}").body

when isMainModule:
  let x = newArchivesSpace()
  echo x.list_all_accession_ids(2)
