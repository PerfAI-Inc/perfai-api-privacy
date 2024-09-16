### Getting Start with Github Action 'RUN'
-------

## How to get Catalog Id

### Step 1: Log in to API Privacy
- Log in at [API Privacy Dashboard](https://app.apiprivacy.com).
- After logging in, click on **APIs** on the dashboard.

### Step 2: Select APIs
- Click on horizontal three dotted lines then Copy the **Catalog_id**.
  
 ![image](https://github.com/user-attachments/assets/41552daf-8135-4861-8d40-820aa6780062)

----------------------------------------------------------------------------------------------------------------------------
### Action Run

### `perfai-username`
**Required**: The PerfAI Username with which the AI Running will be executed.

**Note**: You can create a new user <a href="https://app.apiprivacy.com/#sign-up" target="_blank">https://app.apiprivacy.com</a>


| **Default value**   | `""` |
|----------------|-------|

### `perfai-password`
**Required**: The PerfAI password with which the AI Running will be executed

| **Default value**   | `""` |
|----------------|-------|

### `perfai-catalog-id`
**Required**: The catalog ID of the API Registry.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-wait-for-completion`
**Optional**: Set to `true` or `false`.

| **Default value**   | `"false"` |
|----------------|-------|


# Example usage
Below is a sample of a complete workflow action.

Full sample
```
# This is a starter workflow to help you get with API-Privacy AI Running

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
       - name: API Privacy AI Running
         uses: perfai-inc/perfai-ai-running@v1.0
         with:
          # The API Privacy username with which the AI Running will be executed
          perfai-username: ${{ secrets.perfai_username }}
          # The API Privacy Password with which the AI Running will be executed
          perfai-password: ${{ secrets.perfai_password}}
          # The catalog id need to provide 
          perfai-catalog-id: "26xxxxxxxxxx75"
          # The name of the project for security scan
          perfai-wait-for-completio: "true"
           
The API Privacy credentials are read from github secrets.

Warning: Never store your secrets in the repository.
```


          
