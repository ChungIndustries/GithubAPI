local API_PREFIX = "https://api.github.com/repos/"

function github_http_request(url, authToken)
    local response = http.get(url, {Authorization="token "..authToken})
    local content = response.readAll()
    response.close()
    return content
end


function download_file(authToken, fileURL, localPath)
    local content = github_http_request(file.download_url, authToken)
    local f = fs.open(localPath..file.name, "w")
    f.write(content)
    f.close()
end


function download_files(authToken, user, repo, path, branch, localPath)
    path = path or ""
    branch = branch or "main"
    localPath = localPath or ("/downloads/"..repo.."/")

    print("------------- "..authToken.." --------------")

    local result = json.deserialize(github_http_request(API_PREFIX..user.."/"..repo.."/contents"..path.."?ref="..branch, authToken))

    print("LAAAAAAAA: "..authToken)

    for _, file in pairs(result) do
        if file.type == "file" then
            print("Downloading file: "..file.name)
            download_file(authToken, file, localPath)
        elseif file.type == "dir" then
            print("Listing directory: "..file.name)
            download_files(authToken, user, repo, path.."/"..file.name, branch, localPath..file.name.."/")
        end
    end
end


function download_repo(authToken, user, repo, branch, localPath)
    print("Connecting to Github...")
    download_files(authToken, user, repo, "", branch, localPath)
    print("Download complete!")
end


function get_latest_commit(authToken, user, repo)
    return json.decode(github_http_request(API_PREFIX..user.."/"..repo.."/commits", authToken))[1]
end


function check_for_updates(authToken, user, repo, lastUpdate)
    local latestCommit = get_latest_commit(authToken, user, repo)
    return latestCommit.commit.committer.date ~= lastUpdate
end
