Displays the number of hours and days since the last time a specific Concourse job went green.

The app has two components:

1. an API which returns the number of seconds since a specified Concourse job went green
1. a UI which polls the API and displays the elapsed time in hours and days

# Deploying

The recommended way to deploy this app is using Cloud Foundry.

The following environment variables need to be set for the API:

| ENV | Description |
| ---- | ---- |
| TARGET | the url of the concourse ATC to check |
| PIPELINE | the name of the pipeline to check |
| JOB | the name of the job to check |
| CONCOURSE_USERNAME | basic auth user for this concourse |
| CONCOURSE_PASSWORD | basic auth password for user |
| SKIP_SSL | | 