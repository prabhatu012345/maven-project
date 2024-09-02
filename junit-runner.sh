#!/bin/bash

# Navigate to the project directory (if necessary)
# cd /path/to/your/project

# Run Maven tests
mvn test

# Capture the result of the tests
RESULT=$?

# Exit with the result of the Maven test command
exit $RESULT
