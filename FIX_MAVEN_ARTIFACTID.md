# Fix: Maven ArtifactId for DAP Debugging

## Summary
This commit fixes DAP debugging when Maven project directory name differs from artifactId.

## Commit
```
commit bf93c8aabaf9361c016572dd2873869f372a3613
Author: Serhii Dudar <shtanga.net@gmail.com>
Date:   Thu Jan 29 02:23:10 2026 +0200
```

## Changes

### Files Modified:
1. **lua/neotest-java/util/pom_parser.lua** (NEW)
   - Extracts Maven artifactId from project
   - Primary method: `mvn help:evaluate -Dexpression=project.artifactId`
   - Fallback method: Parse pom.xml manually
   
2. **lua/neotest-java/core/spec_builder/init.lua**
   - Added `require("neotest-java.util.pom_parser")`
   - Modified DAP strategy to use artifactId for Maven projects
   - Falls back to directory name for non-Maven projects

## Testing

Before pushing to GitHub, test with your projects:

1. **Update your Neovim config to use your fork:**
   ```lua
   -- In your lazy.nvim config:
   {
       "sergii-dudar/neotest-java",  -- Your fork
       branch = "main",
   }
   ```

2. **Test scenarios:**
   - ✅ Project where directory name = artifactId (should work as before)
   - ✅ Project where directory name ≠ artifactId (your demo-spring case)
   - ✅ Project without Maven (should fallback gracefully)
   - ✅ Project with Maven properties in artifactId
   - ✅ Multi-module Maven project

3. **What to verify:**
   - `<leader>tR` (neotest debug) works correctly
   - Check neotest-java logs for debug messages
   - Verify no performance issues (Maven command overhead)

## Next Steps

### If Testing is Successful:

1. **Create a branch for the PR:**
   ```bash
   cd /home/serhii/serhii.home/git/neotest-java
   git checkout -b fix/maven-artifactid-dap
   git cherry-pick bf93c8a
   git push origin fix/maven-artifactid-dap
   ```

2. **Open PR to upstream:**
   - Go to: https://github.com/rcasia/neotest-java
   - Create Pull Request from your fork
   - Reference the issue (if any) or describe the problem
   - Include test results

### PR Description Template:

```markdown
## Problem
When debugging tests with DAP strategy (`strategy = "dap"`), neotest-java fails with 
"Could not resolve java executable" error when the project directory name doesn't 
match the Maven artifactId.

## Root Cause
Neotest-java uses directory name (`root:name()`) as projectName for DAP, but 
JDTLS/Eclipse indexes Maven projects by their artifactId. When these differ, 
the project lookup fails.

## Solution
- Added `util/pom_parser.lua` to extract artifactId from Maven projects
- Uses `mvn help:evaluate` command (with XML parsing fallback)
- Modified `spec_builder/init.lua` to use artifactId for Maven projects
- Backward compatible: falls back to directory name for non-Maven projects

## Benefits
- ✅ Directory name can differ from artifactId
- ✅ Handles Maven property interpolation
- ✅ Works with parent POMs and profiles
- ✅ Backward compatible

## Testing
Tested with:
- Simple Maven project (artifactId != directory name)
- Maven project with properties
- Non-Maven project (fallback works)
```

### Performance Optimization (Optional):

If Maven command is too slow, consider caching:

```lua
-- In pom_parser.lua, add module-level cache
local artifact_cache = {}

function M.get_artifact_id(project_dir)
    if artifact_cache[project_dir] then
        return artifact_cache[project_dir]
    end
    
    local result = M.get_artifact_id_from_maven(project_dir)
    if result then
        artifact_cache[project_dir] = result
        return result
    end
    
    -- ... rest of the code
end
```

## Current Status

✅ Committed to your fork: `sergii-dudar/neotest-java@bf93c8a`
⏳ Ready for testing
⏳ Not yet pushed to GitHub
⏳ PR not yet created

## Rollback

If you need to revert:
```bash
cd /home/serhii/serhii.home/git/neotest-java
git reset --hard HEAD~1
```
