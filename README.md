## Getting Started

Follow these steps to get started with PerfAI:

### Step 1: Sign Up for a Free Account
- Visit [PerfAI Sign Up](https://apiprivacy.com) to create a free account.

### Step 2: Log in to API Privacy
- Log in at [API Privacy Dashboard](https://app.apiprivacy.com).
- After logging in, click on **Add API** on the dashboard to register your API.

### Step 3: Add a Sample OpenAPI Specification
- Copy and paste the following sample OpenAPI Specification URL: https://petstore.swagger.io/v2/swagger.yaml
  
### Step 4: Set API Server/Base Path
- Click on **API Server/Base Path**.
- Copy and paste the sample base path URL: https://petstore.swagger.io/v2


### Step 5: Add Credentials to Vault
- Click on **Vault**.
- Then, click on **Add Credentials** to securely store your API credentials.

---

By following these steps, you'll be ready to start using PerfAI for API privacy API Registry and AI Running.

For Authentication

![image](https://github.com/user-attachments/assets/b7911e67-ea30-4180-8765-0d2ac7cc9f54)

For Authorization

![image](https://github.com/user-attachments/assets/15b417c9-9cb1-4e96-aa2c-cd8af73f0960)

### Step 6:  
- Click on Label **Enter Name**.

### Step 7:  
- Click on Emails **Enter Email-Id**.
- You can add multiple Email-Id

### Step 8: 
- Click and Seletct on **Run Schedule**.

### Step 9: 
- Click on **Add API**.


Here is sample API Registry

![image](https://github.com/user-attachments/assets/1d6b5e7f-5354-4c06-b121-dba66a935003)

-----------------------------------------------------------------------------------------------------------------------------
## Inputs

### `perfai-username`
**Required**: The PerfAI Username with which the Action Run will be executed.

**Note**: You can create a new user https://app.apiprivacy.com/#sign-up.

| **Default value**   | `""` |
|----------------|-------|

### `perfai-password`
**Required**: The Password of the PerfAI user with which the Action Run will be executed.

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


          
