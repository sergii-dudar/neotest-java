local logger = require("neotest-java.logger")
local pom_parser = require("neotest-java.util.pom_parser")
local gradle_parser = require("neotest-java.util.gradle_parser")

local M = {}

--- Resolve project name using multiple strategies in order of reliability:
--- 1. Parse module's pom.xml (Maven) or settings.gradle (Gradle)
--- 2. Use directory name as last resort
---
--- @param module_dir neotest-java.Path The module directory
--- @param project_type string "maven" or "gradle"
--- @return string The resolved project name
function M.resolve_project_name(module_dir, project_type)
	logger.debug("Resolving projectName from build file for module: " .. module_dir:to_string())

	-- Strategy 1: Parse build file (pom.xml or settings.gradle)
	if project_type == "maven" then
		local pom_path = module_dir:append("pom.xml")
		if vim.fn.filereadable(pom_path:to_string()) == 1 then
			local artifact_id = pom_parser.get_artifact_id(module_dir:to_string())
			if artifact_id then
				logger.info("Resolved projectName from pom.xml: " .. artifact_id)
				return artifact_id
			end
		end
	elseif project_type == "gradle" then
		local project_name = gradle_parser.get_project_name(module_dir:to_string())
		if project_name then
			logger.info("Resolved projectName from Gradle: " .. project_name)
			return project_name
		end
	end

	-- Strategy 2: Use directory name as last resort
	local dir_name = module_dir:name()
	logger.warn("Could not resolve projectName from build file, using directory name: " .. dir_name)
	return dir_name
end

return M
