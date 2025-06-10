
# AON Azure Deployment

## Files Included

- `terraform/main.tf`: Terraform configuration for Azure App Service and resources.
- `backend/server.py`: Flask backend handling LinkedIn OAuth and lead submission.
- `frontend/PostLogin.jsx`: React frontend component for post-login user form.
- `README.md`: This deployment guide.

## Setup

1. Initialize and apply Terraform to create Azure resources:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. Set the following environment variables in Azure App Service Configuration:
   - `LINKEDIN_CLIENT_ID=784jsddghxw155`
   - `LINKEDIN_CLIENT_SECRET=WPL_AP1.iIRvkzWg2nzBCEyD.PsS8sg==`
   - `BASE_URL=https://aon-lead-app-eastus2-1.azurewebsites.net`
   - Add your Cosmos DB connection strings if applicable.

3. Build React frontend and place in `build/` folder inside backend directory.

4. Deploy backend Flask app (`server.py`) to Azure App Service with gunicorn command:
   ```bash
   python3 -m gunicorn server:app
   ```

5. Ensure LinkedIn OAuth redirect URL is set to:
   `https://aon-lead-app-eastus2-1.azurewebsites.net/callback/linkedin`

6. Test the full login, data capture, and submission flow.

## Notes

- Adjust secrets and keys as needed for your environment.
- This is a minimal working package; extend as needed for your full app.
