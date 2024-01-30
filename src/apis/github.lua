local API_PREFIX = "https://api.github.com/repos/"

function get_request(url, authToken)
    local response = http.get(url, {Authorization="Bearer "..authToken})

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


function download_file(authToken, download_url, localPath)
    local content = get_request(download_url, authToken)
    local f = fs.open(localPath, "w")
    f.write(content)
    f.close()
end


function download_files(authToken, user, repo, branch, path, localPath)
    path = path or ""
    branch = branch or "main"
    localPath = localPath or ("/downloads/"..repo.."/")

    local result = json.decode(get_request(API_PREFIX..user.."/"..repo.."/contents/"..path.."?ref="..branch, authToken))

    for _, file in pairs(result) do
        if file.type == "file" then
            print("Downloading: "..file.path)
            download_file(authToken, file.download_url, localPath..file.name)
        elseif file.type == "dir" then
            download_files(authToken, user, repo, branch, file.path, localPath..file.name.."/")
        end
    end
end


function download_repo(authToken, user, repo, branch, localPath)
    print("Connecting to Github...")
    download_files(authToken, user, repo, branch, "", localPath)
    print("Download complete!")
end


function get_latest_commit(authToken, user, repo)
    return json.decode(get_request(API_PREFIX..user.."/"..repo.."/commits", authToken))[1]
end


function check_for_updates(authToken, user, repo, lastUpdate)
    local latestCommit = get_latest_commit(authToken, user, repo)
    return latestCommit.commit.committer.date ~= lastUpdate
end
