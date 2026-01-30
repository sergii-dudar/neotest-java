# Fix: Project Name Resolution for DAP Debugging

## Problem

DAP debugging fails in multi-module (mostly in Maven) projects because neotest-java uses the **root directory name** instead of the **module's actual name** (Maven artifactId or Gradle project name).

**Error:** `Could not resolve java executable for project 'wrong-name'`

## Root Cause

1. Used `root:name()` instead of `module.base_dir`
2. Directory names often differ from Maven artifactId or Gradle project name
3. Multi-module projects at any depth weren't handled

## Solution

**Maven:** xmllint (24ms) → mvn offline → manual parsing  
**Gradle:** gradle properties -> directory name
