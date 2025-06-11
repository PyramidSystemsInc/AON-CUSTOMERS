import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

console.log('Building application...');

try {
  // Build the client
  console.log('Building client...');
  execSync('npm run build', { stdio: 'inherit' });
  
  // Copy server files to dist
  console.log('Preparing server files...');
  const serverDir = path.join(process.cwd(), 'server');
  const distDir = path.join(process.cwd(), 'dist');
  
  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
  }
  
  // Copy package.json
  const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  const prodPackageJson = {
    name: packageJson.name,
    version: packageJson.version,
    type: packageJson.type,
    scripts: {
      start: packageJson.scripts.start
    },
    dependencies: packageJson.dependencies
  };
  
  fs.writeFileSync(
    path.join(distDir, 'package.json'),
    JSON.stringify(prodPackageJson, null, 2)
  );
  
  console.log('Build completed successfully!');
} catch (error) {
  console.error('Build failed:', error);
  process.exit(1);
}