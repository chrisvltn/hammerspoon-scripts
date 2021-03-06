local logger = hs.logger.new('Requirer', 'info')

function requireRecursive(path)
    local iterFn, dirObj = hs.fs.dir(path)

    if iterFn then
        for file in iterFn, dirObj do
            if file ~= "." and file ~= ".." then
                local filePath = path .. '/' .. file

                local fileType = hs.fs.attributes(filePath, 'mode')
                logger.df('file path: [%s] %s', fileType, filePath)
                if fileType == 'directory' then
                    requireRecursive(filePath)
                end

                if filePath:sub(-4) == ".lua" then
                    if pcall(function() require(filePath:sub(0, -5)) end) then
                        logger.df("File '%s' was required successfully", file)
                    else
                        logger.df("Error requiring the file '%s'", file)
                    end
                end
            end
        end
    end
end

requireRecursive("./tasks")