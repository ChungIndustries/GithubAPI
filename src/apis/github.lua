local API_PREFIX = "https://api.github.com/repos/"

local function get_url(user, repo, branch, path)
    branch = branch or "main"
    path = path or ""
    return API_PREFIX..user.."/"..repo.."/"..path.."?ref="..branch
end


local function get_request(url, auth_token)
    local response = http.get(url, {Authorization="Bearer "..auth_token})

    if response == nil then
        print("Bad HTTP Response: "..url)
        return
    end

    local responseCode = response.getResponseCode()

    if responseCode ~= 200 then
        print("Bad HTTP Response Code: "..responseCode)
        return
    end

    local content = response.readAll()
    response.close()
    return content
end


local function download_file(auth_token, download_url, local_path)
    local content = get_request(download_url, auth_token)
    local f = fs.open(local_path, "w")
    f.write(content)
    f.close()
end


local function download_files(auth_token, user, repo, branch, path, local_path)
    local result = json.decode(get_request(get_url(user, repo, branch, "contents/"..path), auth_token))

    for _, file in pairs(result) do
        if file.type == "file" then
            print("Downloading: "..file.path)
            download_file(auth_token, file.download_url, local_path..file.name)
        elseif file.type == "dir" then
            download_files(auth_token, user, repo, branch, file.path, local_path..file.name.."/")
        end
    end
end


function download(auth_token, user, repo, branch, path, local_path)
    branch = branch or "main"
    path = path or ""
    local_path = local_path or ("/"..repo.."/")

    print("Connecting to Github...")
    download_files(auth_token, user, repo, branch, path, local_path)
    print("Download complete!")
end


function download_repo(auth_token, user, repo, branch, local_path)
    download(auth_token, user, repo, branch, "", local_path)
end


function get_latest_commit(auth_token, user, repo, branch)
    return json.decode(get_request(get_url(user, repo, branch, "commits"), auth_token))[1]
end


function check_for_updates(auth_token, user, repo, branch, last_updated)
    local latestCommit = get_latest_commit(auth_token, user, repo, branch)
    return latestCommit.commit.committer.date ~= last_updated
end
