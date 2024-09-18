# PerfAI API Privacy GitHub Action

A [GitHub Action](https://github.com/features/actions) for using [PerfAI API Privacy](https://app.apiprivacy.com/) to test for data leaks in your APIs. Tests include classification of sensitive and non-sensitive data and documenting it, Generating comprehensive test plan against [API Privacy Top-10 List](https://docsend.com/view/96jygz72tsfpq4kv), Executing these tests against the target environment. This action can be configured to automatically block risks introduced into the codebase as part of your pipeline.
If you want to learn more, contact us at <support@perfai.ai>.

# Example usage
```
# This is a starter workflow to help you get with API-Privacy Tests

name: PerfAI

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
      actions: read              # only required for a private repository by github/codeql-action/upload-sarif to get the Action run status 
    runs-on: ubuntu-latest

    steps:
       - name: API Privacy Test
         uses: perfai-inc/perfai-ai-running@v1.0
         with:
          # The API Privacy username with which the AI Running will be executed
          perfai-username: ${{ secrets.perfai_username }}
          # The API Privacy Password with which the AI Running will be executed
          perfai-password: ${{ secrets.perfai_password}}
          # The catalog id need to provide 
          perfai-catalog-id: "123456789"
          # The name of the project for security scan
          perfai-wait-for-completio: "true"
  ```         
The API Privacy credentials are read from github secrets.

Warning: Never store your secrets in the repository.


## How to get API Id

### Step 1: Log in to API Privacy
- Log in at [API Privacy Dashboard](https://app.apiprivacy.com).
- After logging in, click on **APIs** on the dashboard.

### Step 2: Select APIs
- Click on horizontal three dotted lines then Copy the **API Id**.
  
 ![image](https://github.com/user-attachments/assets/41552daf-8135-4861-8d40-820aa6780062)

----------------------------------------------------------------------------------------------------------------------------
### Action Run

### `perfai-username`
**Required**: API Privacy Username.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-password`
**Required**: API Privacy Password

| **Default value**   | `""` |
|----------------|-------|

### `perfai-api-id`
**Required**: API Id generated for the API in API Privacy.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-api-name`
**Required**: API Name / Label.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-wait-for-completion`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"false"` |
|----------------|-------|

### `perfai-fail-on-new-leaks`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"false"` |
|----------------|-------|
