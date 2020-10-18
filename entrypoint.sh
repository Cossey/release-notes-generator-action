#!/bin/sh
set -e

printf '\033[0;34m
Open sourced by Decathlon
Updated by Cossey
\033[0m'

TRIGGER_ACTION="closed"

echo "Getting Action Information"
ACTION=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["action"]' | cut -f2 | sed 's/\"//g')
MILESTONE_NUMBER=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","number"]' | cut -f2)

#Check if Milestone exists, which means actions was raised by a milestone operation.
if [[ -z "$MILESTONE_NUMBER" ]]; then
    echo "Milestone number is missing. Was the action raised by a milestone event?"
    exit 1
fi

OUTPUT_FILENAME="changelog.md"
#Check if a filename prefix is provided
if [[ ! -z "$FILENAME_PREFIX" ]]; then
    OUTPUT_FILENAME="$FILENAME_PREFIX$MILESTONE_NUMBER.md"
fi

#Check if we should use milestone title instead
if [[ ! -z "$USE_MILESTONE_TITLE" ]]; then
    MILESTONE_TITLE=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","title"]' | cut -f2 | sed 's/\"//g' | sed 's/ /_/g')
    OUTPUT_FILENAME="$MILESTONE_TITLE.md"
fi

#Output folder configuration
if [ -z "$OUTPUT_FOLDER" ]; then
  echo "OUTPUT_FOLDER ENV is missing, using the default one"
  OUTPUT_FOLDER='.'
else
  mkdir $OUTPUT_FOLDER
fi

echo "Checking for custom configuration..."
CONFIG_FILE=".github/release-notes.yml"
if [[ ! -f ${CONFIG_FILE} ]]; then
    echo "No config file specified."
    CONFIG_FILE=""
else
    echo "Configuring the action using $CONFIG_FILE"
fi

if [[ "$ACTION" == "$TRIGGER_ACTION" ]]; then
    echo "Creating release notes for Milestone $MILESTONE_NUMBER into the $OUTPUT_FILENAME file"
    java -jar /github-changelog-generator.jar \
    --changelog.repository=${GITHUB_REPOSITORY} \
    --changelog.milestone-reference=id \
    --github.username=${GITHUB_ACTOR} \
    --github.password=${GITHUB_TOKEN} \
    --spring.config.location=${CONFIG_FILE} \
    ${MILESTONE_NUMBER} \
    ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
    cat ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
else
    echo "Release notes generation skipped because action was: $ACTION"
    exit 78
fi
