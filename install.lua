local BASE_URL = "https://raw.githubusercontent.com"
local USER = "ChungIndustries"
local REPO = "GithubAPI"
local BRANCH = "master"
local URL = BASE_URL .. "/" .. USER .. "/" .. REPO .. "/" .. BRANCH .. "/"

local api_dependencies = {
    "/src/apis/github.lua"
}

local function get_file_name(path)
    return fs.getName(path)
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

local function main()
    for _, dependency in pairs(api_dependencies) do
        local content = get_content(URL..dependency)
        local file_path = REPO .. "/" ..get_file_name(dependency)
        write_file(file_path, content)
        os.load(file_path)
    end
end

main()