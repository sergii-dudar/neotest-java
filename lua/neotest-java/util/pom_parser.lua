-- Utility to get Maven project artifactId
local M = {}

---@param project_dir string
---@return string|nil
function M.get_artifact_id(project_dir)
	-- Try Maven command first (most reliable)
	local maven_result = M.get_artifact_id_from_maven(project_dir)
	if maven_result then
		return maven_result
	end

	-- Fallback to parsing pom.xml
	local pom_path = project_dir .. "/pom.xml"
	return M.get_artifact_id_from_pom(pom_path)
end

---@param project_dir string
---@return string|nil
function M.get_artifact_id_from_maven(project_dir)
	local handle = io.popen(
		string.format(
			"cd '%s' && mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout 2>/dev/null",
			project_dir
		)
	)
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	if result and result ~= "" then
		-- Trim whitespace
		result = result:match("^%s*(.-)%s*$")
		-- Make sure it looks like a valid artifactId (not an error message)
		if result:match("^[a-zA-Z0-9._-]+$") then
			return result
		end
	end

	return nil
end

---@param pom_path string
---@return string|nil
function M.get_artifact_id_from_pom(pom_path)
	local file = io.open(pom_path, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	-- Match <artifactId>...</artifactId> but not in <parent> or <dependency> sections
	local lines = {}
	for line in content:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local in_parent = false
	local in_dependency = false
	local in_plugin = false

	for _, line in ipairs(lines) do
		if line:match("<parent>") then
			in_parent = true
		elseif line:match("</parent>") then
			in_parent = false
		elseif line:match("<dependency>") or line:match("<dependencies>") then
			in_dependency = true
		elseif line:match("</dependency>") or line:match("</dependencies>") then
			in_dependency = false
		elseif line:match("<plugin>") or line:match("<plugins>") then
			in_plugin = true
		elseif line:match("</plugin>") or line:match("</plugins>") then
			in_plugin = false
		elseif not in_parent and not in_dependency and not in_plugin then
			local artifact_id = line:match("<artifactId>([^<]+)</artifactId>")
			if artifact_id then
				return artifact_id
			end
		end
	end

	return nil
end

return M
