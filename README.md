# AON LinkedIn Lead Capture Application

A modern, full-stack lead capture application with LinkedIn OAuth integration, built with React, Node.js, and designed for Azure deployment.

## 🚀 Features

- **LinkedIn OAuth Integration**: Secure authentication with LinkedIn
- **Modern UI/UX**: Beautiful, responsive design with smooth animations
- **Lead Capture**: Comprehensive form for capturing business leads
- **Azure Ready**: Configured for Azure App Service deployment
- **Cosmos DB Integration**: Optional database integration for lead storage
- **Production Ready**: Security headers, compression, and error handling

## 🏗️ Architecture

### Frontend (React + TypeScript)
- **React 18** with TypeScript
- **Tailwind CSS** for styling
- **Framer Motion** for animations
- **React Router** for navigation
- **Responsive Design** with mobile-first approach

### Backend (Node.js + Express)
- **Express.js** server with security middleware
- **Passport.js** for LinkedIn OAuth
- **Session management** with express-session
- **Azure Cosmos DB** integration (optional)
- **Production optimizations** (compression, security headers)

### Infrastructure (Azure + Terraform)
- **Azure App Service** for hosting
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD
- **Docker** containerization

## 🛠️ Setup Instructions

### Prerequisites
- Node.js 18+
- Azure subscription
- LinkedIn Developer App
- Terraform (for infrastructure)

### 1. LinkedIn OAuth Setup

1. Go to [LinkedIn Developer Portal](https://www.linkedin.com/developers/)
2. Create a new app or use existing app
3. Add OAuth 2.0 redirect URLs:
   - Development: `http://localhost:3001/auth/linkedin/callback`
   - Production: `https://your-app-name.azurewebsites.net/auth/linkedin/callback`
4. Note your Client ID and Client Secret

### 2. Environment Configuration

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Required environment variables:
```env
LINKEDIN_CLIENT_ID=your-linkedin-client-id
LINKEDIN_CLIENT_SECRET=your-linkedin-client-secret
BASE_URL=http://localhost:3001
SESSION_SECRET=your-super-secret-session-key
```

### 3. Local Development

```bash
# Install dependencies
npm install

# Start development server (both frontend and backend)
npm run dev

# Or start them separately:
npm run dev:client  # Frontend on http://localhost:5173
npm run dev:server  # Backend on http://localhost:3001
```

### 4. Azure Deployment

#### Option A: Using Terraform

1. **Configure Terraform variables:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Azure subscription details
   ```

2. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure App Service environment variables** in Azure Portal:
   - `LINKEDIN_CLIENT_ID`
   - `LINKEDIN_CLIENT_SECRET`
   - `BASE_URL` (your Azure App Service URL)
   - `SESSION_SECRET`
   - `NODE_ENV=production`

#### Option B: Manual Azure Setup

1. Create Azure App Service (Linux, Node.js 18)
2. Configure environment variables in App Service settings
3. Set up deployment from GitHub or deploy manually

### 5. GitHub Actions Deployment

1. **Set up Azure publish profile:**
   - Download publish profile from Azure App Service
   - Add as `AZURE_WEBAPP_PUBLISH_PROFILE` secret in GitHub

2. **Push to main branch** to trigger automatic deployment

## 📁 Project Structure

```
├── src/                    # Frontend React application
│   ├── components/         # Reusable React components
│   ├── contexts/          # React contexts (Auth)
│   ├── pages/             # Page components
│   └── ...
├── server/                # Backend Node.js application
│   ├── index.js          # Main server file
│   └── build.js          # Build script
├── terraform/             # Infrastructure as code
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Variable definitions
│   └── outputs.tf        # Output definitions
├── .github/workflows/     # GitHub Actions
└── ...
```

## 🔒 Security Features

- **Helmet.js**: Security headers
- **CORS**: Configured for production
- **Session Security**: Secure cookies in production
- **Input Validation**: Form validation and sanitization
- **Environment Variables**: Sensitive data protection

## 🎨 Design Features

- **Modern UI**: Clean, professional design
- **Responsive**: Mobile-first responsive design
- **Animations**: Smooth transitions with Framer Motion
- **Accessibility**: WCAG compliant components
- **Loading States**: User feedback during operations

## 📊 Lead Capture Flow

1. **LinkedIn Login**: User authenticates with LinkedIn
2. **Profile Completion**: User fills additional business information
3. **Data Storage**: Lead data saved to Cosmos DB (optional)
4. **Dashboard**: Success confirmation and next steps

## 🚀 Production Considerations

- **Environment Variables**: All sensitive data in environment variables
- **Database**: Optional Cosmos DB integration for lead storage
- **Monitoring**: Application Insights integration ready
- **Scaling**: Azure App Service scaling configuration
- **SSL**: HTTPS enforced in production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Contact: support@aonleadcapture.com

## 🔄 Updates

- **v1.0.0**: Initial release with LinkedIn OAuth and lead capture
- **v1.1.0**: Added Azure Cosmos DB integration
- **v1.2.0**: Enhanced UI/UX with animations and responsive design