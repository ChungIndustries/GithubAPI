local BASE_URL = "https://raw.githubusercontent.com"
local USER = "ChungIndustries"
local REPO = "GithubAPI"
local BRANCH = "master"
local URL = BASE_URL .. "/" .. USER .. "/" .. REPO .. "/" .. BRANCH .. "/"

local dependencies = {
    "src/apis/github.lua",
}

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
    for _, dependency in pairs(dependencies) do
        local content = get_content(URL..dependency)
        write_file(REPO..dependency, content)
    end
end

main()