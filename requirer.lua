function requireRecursive(path)
    local iterFn, dirObj = hs.fs.dir(path)

    if iterFn then
        for file in iterFn, dirObj do
            if file ~= "." and file ~= ".." then
                local filePath = path .. '/' .. file
                requireRecursive(filePath)

                if filePath:sub(-4) == ".lua" then
                    require(filePath:sub(0, -5))
                end
            end
        end
    end
end

requireRecursive("./tasks")