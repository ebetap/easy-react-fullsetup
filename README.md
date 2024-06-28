# React.js Project Setup Script Documentation

## Overview
This script automates the setup process for a React.js project with essential tools and configurations. It initializes Git, installs dependencies, sets up ESLint and Prettier, configures React Router and Redux Toolkit with API integration, creates necessary directory structures, and prepares Docker and GitHub Actions configurations.

## Prerequisites
- Node.js installed (version 14 or higher recommended)
- npm (Node Package Manager) installed
- Basic familiarity with Bash scripting

## Usage
1. **Customize Parameters**: Edit the `PROJECT_NAME`, `API_URL`, and `DOCKER_PORT` variables in the script according to your project requirements.

2. **Run the Script**:
   ```bash
   bash setup-react-project.sh
   ```

   Replace `setup-react-project.sh` with the name of your script file.

3. **Follow Prompts**: The script will prompt you during the Git repository initialization, ensuring you understand whether it's a new repository or an existing one.

4. **Completion**: Once the script finishes execution, your React.js project will be set up with the configured tools and configurations.

## Components
### 1. Git Repository Initialization
- Initializes a new Git repository if one doesn't exist.
- Commits initial project files.

### 2. Dependency Installation
- Installs necessary npm packages:
  - Tailwind CSS for styling
  - PostCSS and Autoprefixer for CSS processing
  - React Router DOM for routing
  - Redux Toolkit and related packages for state management
  - Other utilities like ESLint, Prettier, Jest for testing, Axios for API requests, etc.

### 3. ESLint and Prettier Setup
- Configures ESLint with recommended settings for React applications.
- Integrates Prettier for consistent code formatting.

### 4. Directory Structure Setup
- Creates essential directories:
  - `src/components`, `src/features`, `src/pages` for React components and pages
  - `src/app`, `src/styles`, `src/hooks`, `src/utils` for application structure
- Initializes key files like `store.js`, `App.js`, `index.js`, and `tailwind.css`.

### 5. React Router and Redux Toolkit Integration
- Sets up basic routing with React Router.
- Configures Redux Toolkit with API integration using `createApi` from `@reduxjs/toolkit/query/react`.
- Provides example usage for fetching, adding, updating, and deleting posts from an API.

### 6. Environment Configuration
- Creates a `.env` file with the specified `API_URL`.

### 7. Docker Setup
- Generates a `Dockerfile` for containerizing the React application.
- Creates a `docker-compose.yml` file for Docker Compose setup, exposing the application on the specified port (`DOCKER_PORT`).

### 8. GitHub Actions Workflow
- Creates a GitHub Actions workflow (`ci.yml`) for Continuous Integration (CI):
  - Installs dependencies, runs tests, and deploys to production on successful builds.
  - Includes a linting step using ESLint to maintain code quality.

### 9. Versioning and Changelog Initialization
- Initializes versioning with an initial version (`0.1.0`) and a `CHANGELOG.md` file to track project changes.

## Customization
- Edit `.eslintrc.json`, `.prettierrc`, `tailwind.config.js`, and other configuration files to tailor to specific project needs.
- Modify API endpoints and Redux slices (`apiSlice.js`) based on your backend API structure.

## Security Considerations
- Ensure sensitive information (like API keys) is handled securely, possibly through environment variables.

## Support and Feedback
For questions, feedback, or issues related to this setup script, please reach out to beta.priyoko@students.amikom.ac.id
