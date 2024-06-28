#!/bin/bash

set -e  # Exit script on any error

# Function to install dependencies
install_dependencies() {
  echo "Installing dependencies..."
  npm install -D tailwindcss@latest postcss@latest autoprefixer@latest \
    react-router-dom @reduxjs/toolkit @reduxjs/toolkit/query react-hook-form react-helmet redux-persist \
    eslint eslint-config-prettier eslint-plugin-prettier prettier
}

# Function to initialize ESLint and Prettier
setup_eslint_prettier() {
  echo "Setting up ESLint and Prettier..."
  cat <<EOF > .eslintrc.json
{
  "extends": [
    "react-app",
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:prettier/recommended"
  ],
  "plugins": ["prettier"],
  "rules": {
    "prettier/prettier": "error"
  }
}
EOF

  cat <<EOF > .prettierrc
{
  "singleQuote": true,
  "semi": false
}
EOF
}

# Function to create directory structure
setup_directory_structure() {
  echo "Creating directory structure..."
  mkdir -p src/components src/features src/pages src/app src/styles src/hooks src/utils
  touch src/app/store.js src/App.js src/index.js src/styles/tailwind.css
  touch jsconfig.json tailwind.config.js
}

# Function to create React Router and Redux Toolkit with createApi setup
setup_react_router_redux_toolkit() {
  echo "Setting up React Router and Redux Toolkit..."
  cat <<EOF > src/App.js
import { BrowserRouter as Router, Route, Switch, NavLink } from 'react-router-dom';
import { Provider } from 'react-redux';
import { store } from './app/store';
import Home from './pages/Home';
import About from './pages/About';

function App() {
  return (
    <Provider store={store}>
      <Router>
        <nav className="p-4 flex justify-between items-center">
          <div>
            <NavLink exact to="/" activeClassName="text-blue-500" className="mr-4">
              Home
            </NavLink>
            <NavLink to="/about" activeClassName="text-blue-500">
              About
            </NavLink>
          </div>
        </nav>
        <Switch>
          <Route path="/about" component={About} />
          <Route path="/" component={Home} />
        </Switch>
      </Router>
    </Provider>
  );
}

export default App;
EOF

  cat <<EOF > src/app/store.js
import { configureStore } from '@reduxjs/toolkit';
import { apiSlice } from 'features/api/apiSlice';
import { persistReducer, persistStore } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

const persistConfig = {
  key: 'root',
  storage,
};

const persistedReducer = persistReducer(persistConfig, {
  [apiSlice.reducerPath]: apiSlice.reducer,
});

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(apiSlice.middleware),
});

export const persistor = persistStore(store);
EOF

  cat <<EOF > src/features/api/apiSlice.js
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const apiSlice = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  endpoints: (builder) => ({
    getPosts: builder.query({
      query: () => 'posts',
    }),
  }),
});

export const { useGetPostsQuery } = apiSlice;
EOF

  cat <<EOF > src/pages/Home.js
import React from 'react';
import { Helmet } from 'react-helmet';

function Home() {
  return (
    <div className="p-4">
      <Helmet>
        <title>Home Page</title>
      </Helmet>
      <h1 className="text-xl">Home Page</h1>
      <p>Welcome to the Home page.</p>
    </div>
  );
}

export default Home;
EOF

  cat <<EOF > src/pages/About.js
import React from 'react';
import { Helmet } from 'react-helmet';

function About() {
  return (
    <div className="p-4">
      <Helmet>
        <title>About Page</title>
      </Helmet>
      <h1 className="text-xl">About Page</h1>
      <p>Welcome to the About page.</p>
    </div>
  );
}

export default About;
EOF

  echo "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/styles/tailwind.css

  echo '{"compilerOptions":{"baseUrl":"src"},"include":["src"]}' > jsconfig.json

  cat <<EOF > tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
  theme: {
    extend: {
      colors: {
        primary: '#1a202c',
        secondary: '#2d3748',
        accent: '#38b2ac',
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
EOF
}

# Function to create .env file
create_env_file() {
  echo "Creating .env file..."
  echo "REACT_APP_API_URL=https://api.example.com" > .env
}

# Function to create Dockerfile
create_dockerfile() {
  echo "Creating Dockerfile..."
  cat <<EOF > Dockerfile
# Dockerfile
FROM node:14-alpine

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./

RUN npm install

COPY . .

CMD ["npm", "start"]
EOF
}

# Function to create docker-compose.yml
create_docker_compose_file() {
  echo "Creating docker-compose.yml..."
  cat <<EOF > docker-compose.yml
version: '3'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ".:/app"
EOF
}

# Function to create GitHub Actions workflow
create_github_actions_workflow() {
  echo "Creating GitHub Actions workflow..."
  mkdir -p .github/workflows
  cat <<EOF > .github/workflows/ci.yml
name: CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test
EOF
}

# Main script
main() {
  install_dependencies
  setup_eslint_prettier
  setup_directory_structure
  setup_react_router_redux_toolkit
  create_env_file
  create_dockerfile
  create_docker_compose_file
  create_github_actions_workflow

  echo "React.js project setup completed. Enjoy coding with TailwindCSS, Redux Toolkit, and more!"
}

# Run main function
main
