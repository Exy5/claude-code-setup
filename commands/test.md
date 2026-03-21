---
description: Generate unit tests for a specific file or class
---

Generate comprehensive unit tests for the specified target.

**Target:** $ARGUMENTS

Spawn the `test-writer` agent for the target above. It will:
1. Analyze the target code for public API, branches, and edge cases
2. Generate tests using the appropriate framework (JUnit/Mockito for Java, Jest/Jasmine for Angular/React)
3. Target 90%+ code coverage
4. Create test files following project naming conventions
