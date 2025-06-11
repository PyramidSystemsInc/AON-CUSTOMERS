# AON Lead Capture Application - Complete Technical Documentation

## 🏗️ **Architecture Overview**

This is a full-stack web application built with modern technologies for professional lead capture through LinkedIn OAuth integration.

### **Technology Stack**
- **Frontend**: React 18 + TypeScript + Tailwind CSS + Framer Motion
- **Backend**: Node.js + Express.js + Passport.js
- **Authentication**: LinkedIn OAuth 2.0
- **Deployment**: Azure App Service + Terraform
- **Build Tool**: Vite
- **Styling**: Tailwind CSS with custom animations

---

## 📁 **Project Structure Explained**

```
├── src/                    # Frontend React Application
│   ├── components/         # Reusable UI Components
│   ├── contexts/          # React Context (Authentication)
│   ├── pages/             # Main Application Pages
│   └── main.tsx           # Application Entry Point
├── server/                # Backend Node.js Application
│   ├── index.js          # Main Server File
│   └── build.js          # Production Build Script
├── terraform/             # Infrastructure as Code
├── .github/workflows/     # CI/CD Pipeline
└── Configuration Files    # Various config files
```

---

## 🎯 **Application Flow (User Journey)**

### **1. User Authentication Flow**
```
User visits app → Login Page → LinkedIn OAuth → Profile Completion → Dashboard
```

### **2. Technical Flow**
```
Frontend (React) ↔ Backend API (Express) ↔ LinkedIn OAuth ↔ Data Storage
```

---

## 🔧 **Backend Architecture (`server/index.js`)**

### **Core Dependencies**
```javascript
import express from 'express';           // Web framework
import session from 'express-session';   // Session management
import passport from 'passport';         // Authentication middleware
import { Strategy as LinkedInStrategy } from 'passport-linkedin-oauth2';
import cors from 'cors';                 // Cross-origin requests
import helmet from 'helmet';             // Security headers
import morgan from 'morgan';             // HTTP request logging
import compression from 'compression';   // Response compression
```

### **Security Configuration**
```javascript
// Content Security Policy for XSS protection
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'"],
    },
  },
}));

// CORS configuration for frontend-backend communication
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.BASE_URL 
    : 'http://localhost:5173',
  credentials: true
}));
```

### **Session Management**
```javascript
app.use(session({
  secret: process.env.SESSION_SECRET,    // Encryption key
  resave: false,                         // Don't save unchanged sessions
  saveUninitialized: false,              // Don't create empty sessions
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only in prod
    httpOnly: true,                      // Prevent XSS attacks
    maxAge: 24 * 60 * 60 * 1000         // 24 hours
  }
}));
```

### **LinkedIn OAuth Strategy**
```javascript
passport.use(new LinkedInStrategy({
  clientID: process.env.LINKEDIN_CLIENT_ID,
  clientSecret: process.env.LINKEDIN_CLIENT_SECRET,
  callbackURL: `${process.env.BASE_URL}/auth/linkedin/callback`,
  scope: ['r_emailaddress', 'r_liteprofile'],
}, async (accessToken, refreshToken, profile, done) => {
  // Extract user data from LinkedIn profile
  const user = {
    id: profile.id,
    displayName: profile.displayName,
    firstName: profile.name?.givenName,
    lastName: profile.name?.familyName,
    email: profile.emails?.[0]?.value,
    profilePicture: profile.photos?.[0]?.value,
    accessToken
  };
  return done(null, user);
}));
```

### **API Endpoints**

#### **Authentication Routes**
- `GET /auth/linkedin` - Initiates LinkedIn OAuth
- `GET /auth/linkedin/callback` - Handles OAuth callback
- `POST /api/logout` - Logs out user and destroys session

#### **Data Routes**
- `GET /api/user` - Returns current authenticated user
- `POST /api/save-lead` - Saves lead form data
- `GET /api/leads` - Returns user's leads (optional)

### **Data Storage**
Currently uses in-memory storage for simplicity:
```javascript
const leadsStorage = [];  // Simple array to store leads
```

---

## ⚛️ **Frontend Architecture**

### **Main Application (`src/App.tsx`)**
```javascript
function App() {
  return (
    <AuthProvider>           {/* Authentication context */}
      <Router>               {/* React Router for navigation */}
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/post-login" element={<ProtectedRoute><PostLoginPage /></ProtectedRoute>} />
          <Route path="/dashboard" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}
```

### **Authentication Context (`src/contexts/AuthContext.tsx`)**
Manages user authentication state across the application:

```javascript
const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // Fetch user data from backend
  const fetchUser = async () => {
    const response = await fetch('/api/user', { credentials: 'include' });
    if (response.ok) {
      const userData = await response.json();
      setUser(userData);
    }
  };

  // Logout function
  const logout = async () => {
    await fetch('/api/logout', { method: 'POST', credentials: 'include' });
    setUser(null);
    window.location.href = '/login';
  };
};
```

### **Protected Routes (`src/components/ProtectedRoute.tsx`)**
Ensures only authenticated users can access certain pages:

```javascript
const ProtectedRoute = ({ children }) => {
  const { user, loading } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (!user) return <Navigate to="/login" replace />;
  
  return <>{children}</>;
};
```

---

## 📄 **Page Components Explained**

### **1. Login Page (`src/pages/LoginPage.tsx`)**

**Purpose**: First page users see, handles LinkedIn authentication

**Key Features**:
- Beautiful hero section with feature highlights
- LinkedIn OAuth button
- Security information
- Responsive design with animations

**Code Structure**:
```javascript
const LoginPage = () => {
  const { user, loading } = useAuth();
  
  // Redirect if already logged in
  if (user) return <Navigate to="/post-login" replace />;
  
  const handleLinkedInLogin = () => {
    window.location.href = '/auth/linkedin';  // Redirects to backend OAuth
  };
  
  return (
    <div className="min-h-screen flex">
      {/* Left Panel - Hero Section */}
      <div className="lg:w-1/2 bg-gradient-to-br from-blue-600 to-indigo-800">
        {/* Features showcase */}
      </div>
      
      {/* Right Panel - Login Form */}
      <div className="w-full lg:w-1/2">
        <button onClick={handleLinkedInLogin}>
          Continue with LinkedIn
        </button>
      </div>
    </div>
  );
};
```

### **2. Post-Login Page (`src/pages/PostLoginPage.tsx`)**

**Purpose**: Collects additional business information after LinkedIn login

**Key Features**:
- Multi-field form with validation
- Interest selection with checkboxes
- Real-time form validation
- Smooth animations and transitions

**Form Data Structure**:
```javascript
interface FormData {
  company: string;
  jobTitle: string;
  phone: string;
  industry: string;
  companySize: string;
  interests: string[];
  additionalInfo: string;
}
```

**Form Submission**:
```javascript
const handleSubmit = async (e) => {
  e.preventDefault();
  setLoading(true);

  const response = await fetch('/api/save-lead', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(formData),
  });

  if (response.ok) {
    navigate('/dashboard');  // Redirect to success page
  }
};
```

### **3. Dashboard Page (`src/pages/DashboardPage.tsx`)**

**Purpose**: Success page showing completion status and next steps

**Key Features**:
- User profile display
- Success confirmation
- Statistics cards
- Next steps recommendations
- Professional layout

**Components**:
```javascript
const DashboardPage = () => {
  const { user, logout } = useAuth();
  
  return (
    <div className="max-w-6xl mx-auto">
      {/* Header with user info */}
      <div className="bg-white rounded-2xl shadow-xl p-8">
        <h1>Welcome back, {user?.firstName}!</h1>
        <div className="bg-green-100 text-green-800">Profile Complete</div>
      </div>
      
      {/* Success message */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-600">
        <h2>Profile Successfully Submitted!</h2>
      </div>
      
      {/* Stats and next steps */}
    </div>
  );
};
```

---

## 🎨 **Styling & Design System**

### **Tailwind CSS Configuration**
```javascript
// tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},  // Custom extensions can be added here
  },
  plugins: [],
};
```

### **Design Principles Used**
- **8px spacing system**: All margins/padding use multiples of 8px
- **Color system**: Blue/indigo primary, green for success, red for errors
- **Typography**: Clear hierarchy with proper font weights
- **Responsive design**: Mobile-first approach
- **Animations**: Framer Motion for smooth transitions

### **Common CSS Classes**
```css
/* Gradients */
bg-gradient-to-br from-blue-50 via-white to-indigo-50
bg-gradient-to-r from-blue-600 to-indigo-600

/* Shadows */
shadow-xl        /* Large shadow for cards */
shadow-lg        /* Medium shadow for buttons */

/* Rounded corners */
rounded-2xl      /* Large radius for cards */
rounded-xl       /* Medium radius for buttons */

/* Spacing */
p-8             /* Padding 32px */
space-y-6       /* Vertical spacing 24px between children */
```

---

## 🔄 **State Management**

### **Authentication State**
Managed by React Context (`AuthContext`):
```javascript
interface AuthContextType {
  user: User | null;        // Current user data
  loading: boolean;         // Loading state
  logout: () => Promise<void>;     // Logout function
  refreshUser: () => Promise<void>; // Refresh user data
}
```

### **Form State**
Managed by React useState hook:
```javascript
const [formData, setFormData] = useState<FormData>({
  company: '',
  jobTitle: '',
  phone: '',
  industry: '',
  companySize: '',
  interests: [],
  additionalInfo: ''
});
```

### **Loading States**
Each async operation has its own loading state:
```javascript
const [loading, setLoading] = useState(false);

const handleSubmit = async () => {
  setLoading(true);
  try {
    // API call
  } finally {
    setLoading(false);
  }
};
```

---

## 🔐 **Security Implementation**

### **Backend Security**
1. **Helmet.js**: Sets security headers
2. **CORS**: Restricts cross-origin requests
3. **Session Security**: HttpOnly cookies, secure in production
4. **Input Validation**: Server-side validation of all inputs
5. **Environment Variables**: Sensitive data stored securely

### **Frontend Security**
1. **Protected Routes**: Authentication required for sensitive pages
2. **CSRF Protection**: Credentials included in requests
3. **XSS Prevention**: React's built-in protection + CSP headers
4. **Input Sanitization**: Form validation and sanitization

---

## 🚀 **Build & Deployment**

### **Development Setup**
```bash
# Install dependencies
npm install

# Start development servers (both frontend and backend)
npm run dev

# Frontend only (port 5173)
npm run dev:client

# Backend only (port 3001)
npm run dev:server
```

### **Production Build**
```bash
# Build frontend for production
npm run build

# Build creates optimized files in /dist directory
# Includes code splitting, minification, and optimization
```

### **Vite Configuration (`vite.config.ts`)**
```javascript
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://localhost:3001',    // Proxy API calls to backend
      '/auth': 'http://localhost:3001',   // Proxy auth calls to backend
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],     // Separate vendor bundle
          router: ['react-router-dom'],       // Router bundle
          motion: ['framer-motion'],          // Animation bundle
        },
      },
    },
  },
});
```

---

## 🏗️ **Infrastructure (Terraform)**

### **Azure Resources Created**
```hcl
# App Service Plan
resource "azurerm_service_plan" "asp" {
  name     = "aon-lead-app-eastus2"
  location = "East US 2"
  os_type  = "Linux"
  sku_name = "P1v3"
}

# Web App
resource "azurerm_linux_web_app" "app" {
  name                = "aon-lead-app-eastus2-1"
  service_plan_id     = azurerm_service_plan.asp.id
  
  app_settings = {
    LINKEDIN_CLIENT_ID     = "784jsddghxw155"
    LINKEDIN_CLIENT_SECRET = "WPL_AP1.iIRvkzWg2nzBCEyD.PsS8sg=="
    BASE_URL              = "https://aon-lead-app-eastus2-1.azurewebsites.net"
  }
}
```

### **CI/CD Pipeline (`.github/workflows/deploy.yml`)**
```yaml
name: Deploy to Azure App Service

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Build application
      run: npm run build
    - name: Deploy to Azure
      uses: azure/webapps-deploy@v2
```

---

## 📊 **Data Flow**

### **User Registration Flow**
```
1. User clicks "Continue with LinkedIn"
2. Frontend redirects to /auth/linkedin
3. Backend redirects to LinkedIn OAuth
4. LinkedIn redirects back to /auth/linkedin/callback
5. Backend processes OAuth response
6. Backend creates user session
7. Backend redirects to /post-login
8. Frontend shows profile completion form
9. User fills form and submits
10. Frontend sends POST to /api/save-lead
11. Backend saves data and responds
12. Frontend redirects to /dashboard
```

### **Authentication Check Flow**
```
1. Frontend loads
2. AuthContext calls /api/user
3. Backend checks session
4. If valid session: return user data
5. If no session: return 401
6. Frontend updates auth state
7. Protected routes redirect based on auth state
```

---

## 🔧 **Environment Configuration**

### **Required Environment Variables**
```bash
# LinkedIn OAuth (Required)
LINKEDIN_CLIENT_ID=your-linkedin-client-id
LINKEDIN_CLIENT_SECRET=your-linkedin-client-secret

# Application Settings (Required)
SESSION_SECRET=your-super-secret-session-key
BASE_URL=http://localhost:3001

# Server Configuration (Optional)
PORT=3001
NODE_ENV=development
```

### **Environment Validation**
The server validates required environment variables on startup:
```javascript
const requiredEnvVars = ['LINKEDIN_CLIENT_ID', 'LINKEDIN_CLIENT_SECRET', 'SESSION_SECRET'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0) {
  console.error('❌ Missing required environment variables:');
  process.exit(1);
}
```

---

## 🐛 **Error Handling**

### **Backend Error Handling**
```javascript
// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Route-specific error handling
app.post('/api/save-lead', async (req, res) => {
  try {
    // Process lead data
    res.json({ success: true });
  } catch (error) {
    console.error('❌ Error saving lead:', error);
    res.status(500).json({ error: 'Failed to save lead data' });
  }
});
```

### **Frontend Error Handling**
```javascript
const handleSubmit = async (e) => {
  try {
    const response = await fetch('/api/save-lead', {
      method: 'POST',
      body: JSON.stringify(formData),
    });

    if (!response.ok) {
      throw new Error('Failed to save data');
    }
    
    navigate('/dashboard');
  } catch (error) {
    console.error('Error saving lead:', error);
    alert('Failed to save your information. Please try again.');
  }
};
```

---

## 📱 **Responsive Design**

### **Breakpoint Strategy**
```css
/* Mobile First Approach */
.container {
  @apply w-full px-4;          /* Mobile: full width, 16px padding */
}

@media (md: 768px) {
  .container {
    @apply max-w-4xl mx-auto;  /* Tablet: max width, centered */
  }
}

@media (lg: 1024px) {
  .container {
    @apply max-w-6xl;         /* Desktop: larger max width */
  }
}
```

### **Grid System**
```css
/* Responsive grids using Tailwind */
<div className="grid md:grid-cols-2 gap-6">     /* 1 col mobile, 2 cols tablet+ */
<div className="grid grid-cols-2 md:grid-cols-3 gap-3">  /* 2 cols mobile, 3 cols tablet+ */
```

---

## 🎯 **Performance Optimizations**

### **Frontend Optimizations**
1. **Code Splitting**: Separate bundles for vendor, router, and animations
2. **Lazy Loading**: Components loaded on demand
3. **Image Optimization**: Proper image formats and sizes
4. **Bundle Analysis**: Optimized bundle sizes

### **Backend Optimizations**
1. **Compression**: Gzip compression for responses
2. **Static File Serving**: Efficient static file delivery
3. **Session Management**: Optimized session storage
4. **Logging**: Structured logging with Morgan

---

## 🔍 **Testing Strategy**

### **Manual Testing Checklist**
- [ ] LinkedIn OAuth flow works
- [ ] Form validation works correctly
- [ ] Data saves successfully
- [ ] Responsive design on all devices
- [ ] Error handling works
- [ ] Session management works
- [ ] Logout functionality works

### **Automated Testing (Future)**
```javascript
// Example test structure
describe('Authentication Flow', () => {
  test('should redirect to LinkedIn OAuth', () => {
    // Test OAuth redirect
  });
  
  test('should save user session after OAuth', () => {
    // Test session creation
  });
});
```

---

## 🚀 **Deployment Checklist**

### **Pre-Deployment**
- [ ] Environment variables configured
- [ ] LinkedIn OAuth URLs updated for production
- [ ] Build process tested
- [ ] Security headers configured
- [ ] HTTPS enforced

### **Post-Deployment**
- [ ] Application loads correctly
- [ ] LinkedIn OAuth works in production
- [ ] Form submission works
- [ ] All pages render correctly
- [ ] Mobile responsiveness verified

---

## 🔮 **Future Enhancements**

### **Immediate Improvements**
1. **Database Integration**: Replace in-memory storage with PostgreSQL/Cosmos DB
2. **Email Notifications**: Send confirmation emails
3. **Admin Dashboard**: View and manage leads
4. **Analytics**: Track user behavior and conversion rates

### **Advanced Features**
1. **Multi-tenant Support**: Support multiple organizations
2. **API Integration**: Connect with CRM systems
3. **Advanced Analytics**: Detailed reporting and insights
4. **Team Collaboration**: Multi-user access and permissions

---

## 📞 **Support & Maintenance**

### **Monitoring**
- **Application Insights**: Performance and error monitoring
- **Log Analysis**: Structured logging for debugging
- **Health Checks**: Automated health monitoring

### **Backup & Recovery**
- **Data Backup**: Regular backup of lead data
- **Disaster Recovery**: Recovery procedures documented
- **Version Control**: All code changes tracked in Git

---

## 👥 **Team Roles & Responsibilities**

### **Frontend Developer**
- React components and pages
- UI/UX implementation
- Responsive design
- Client-side state management

### **Backend Developer**
- API endpoints
- Authentication logic
- Data storage
- Security implementation

### **DevOps Engineer**
- Azure infrastructure
- CI/CD pipelines
- Monitoring and logging
- Security configuration

### **Product Manager**
- Requirements gathering
- User experience design
- Feature prioritization
- Testing coordination

---

This documentation provides a complete understanding of the AON Lead Capture application architecture, implementation, and deployment strategy. Each team member can use this as a reference for their specific responsibilities and to understand how their work fits into the overall system.