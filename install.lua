local BASE_URL = "https://raw.githubusercontent.com"
local USER = "ChungIndustries"
local REPO = "GithubAPI"
local BRANCH = "master"
local FILE = "src/apis/github.lua"
local URL = BASE_URL .. "/" .. USER .. "/" .. REPO .. "/" .. BRANCH .. "/" .. FILE


local function get_arg(index)
    local argOffset = arg[1] == "run" and 2 or 0;
    return arg[index + argOffset]
end

local function get_content(url) 
    local response = http.get(url)
    local content = response.readAll()
    response.close()
    return content
end

local function write_file(path, content)
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

local function main(authtoken, root)
    local temp_path = root.."/".."github.lua"
    write_file(temp_path, get_content(URL))
    os.loadAPI(temp_path)

    github.download_repo(authtoken, "ChungIndustries", "GithubAPI", "main", root.."/GithubAPI/")

    os.unloadAPI(temp_path)
    fs.delete(temp_path)
end

main(get_arg(1), "")