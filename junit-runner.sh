#!/bin/bash

# Navigate to the project directory (if necessary)
cd /test/java/com/example/

# Run Maven tests
mvn test

# Capture the result of the tests
RESULT=$?

# Exit with the result of the Maven test command
exit $RESULT
