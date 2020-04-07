if [ -z  "$PUB_DEXED_RLZ" ]; then
    echo "no access token available to delete artifacts of job" $1
    exit 1
fi

export PUB_DEXED_RLZ="H_AUTBZCrxUsh-XYTSXz"
curl -g --header "PRIVATE-TOKEN: $PUB_DEXED_RLZ" \
        --header 'Content-Type: application/json' \
        --request DELETE "https://gitlab.com/api/v4/projects/15908229/jobs/"$1"/artifacts"
