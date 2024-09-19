# PerfAI API Privacy GitHub Action

A [GitHub Action](https://github.com/features/actions) for using [PerfAI API Privacy](https://app.apiprivacy.com/) to test for data leaks in your APIs. Tests include classification of sensitive and non-sensitive data and documenting it, Generating comprehensive test plan against [API Privacy Top-10 List](https://docsend.com/view/96jygz72tsfpq4kv), Executing these tests against the target environment. This action can be configured to automatically block risks introduced into the codebase as part of your pipeline.
If you want to learn more, contact us at <support@perfai.ai>.

# Example usage
```
# This is a starter workflow to help you get with API-Privacy Tests

name: API Privacy Test

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '21 19 * * 4'

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:


permissions:
  contents: read

jobs:

  Trigger_Privacy_AI_Run:
    permissions:
      security-events: write     # for github/codeql-action/upload-sarif to upload SARIF results
    runs-on: ubuntu-latest

    steps:
       - name: PerfAI APIPrivacy Test
         uses: PerfAI-Inc/perfai-api-privacy@v0.0.1
         with:
          # The API Privacy username with which the AI Running will be executed
          perfai-username: ${{ secrets.perfai_username }}
          # The API Privacy Password with which the AI Running will be executed
          perfai-password: ${{ secrets.perfai_password}}
          # API name/label
          perfai-api-name: "demo"
          # API Id generated for the API in API Privacy
          perfai-api-id: "66ebcabcc737e29472660cfe"
          # To wait till the tests gets completed, set to `true` 
          perfai-wait-for-completion: "true"
          # To fail the build on new leaks introduced with this commit, set to `true`.
          perfai-fail-on-new-leaks: "false"
  ```         
The API Privacy credentials are read from github secrets.

Warning: Never store your secrets in the repository.

----------------------------------------------------------------------------------------------------------------------------
### Inputs

### `perfai-username`
**Required**: API Privacy Username.

### `perfai-password`
**Required**: API Privacy Password

### `perfai-api-id`
**Required**: API Id generated for the API in API Privacy.

 1. After login into API Privacy. 

 2. Click on **APIs** on the dashboard.
 
 3. Click on horizontal three dotted lines then Copy the **API Id**.

### `perfai-api-name`
**Required**: API Name / Label.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-wait-for-completion`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"true"` |
|----------------|-------|

### `perfai-fail-on-new-leaks`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"false"` |
|----------------|-------|
