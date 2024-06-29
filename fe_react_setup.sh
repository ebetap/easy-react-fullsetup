#!/bin/bash

set -e  # Exit script on any error

# Prompt for parameters
read -p "Enter project name: " PROJECT_NAME
read -p "Enter API URL: " API_URL
read -p "Enter Docker port: " DOCKER_PORT

# Function to initialize Git repository if not already initialized
initialize_git_repository() {
  if [ ! -d "$PROJECT_NAME/.git" ]; then
    echo "Initializing Git repository..."
    git -C "$PROJECT_NAME" init
    git -C "$PROJECT_NAME" add .
    git -C "$PROJECT_NAME" commit -m "Initial commit"
    echo "Git repository initialized with initial commit."
  else
    echo "Git repository already exists. Skipping initialization."
  fi
}

# Function to install dependencies
install_dependencies() {
  echo "Installing dependencies..."
  npm install -D tailwindcss@latest postcss@latest autoprefixer@latest \
    react-router-dom @reduxjs/toolkit @reduxjs/toolkit/query react-hook-form react-helmet redux-persist \
    eslint eslint-config-prettier eslint-plugin-prettier prettier \
    jest @testing-library/react @testing-library/jest-dom \
    axios
}

# Function to setup ESLint and Prettier
setup_eslint_prettier() {
  echo "Setting up ESLint and Prettier..."
  cat <<EOF > "$PROJECT_NAME/.eslintrc.json"
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

  cat <<EOF > "$PROJECT_NAME/.prettierrc"
{
  "singleQuote": true,
  "semi": false
}
EOF
}

# Function to create directory structure
setup_directory_structure() {
  echo "Creating directory structure..."
  mkdir -p "$PROJECT_NAME/src/components" "$PROJECT_NAME/src/features" \
    "$PROJECT_NAME/src/pages" "$PROJECT_NAME/src/app" "$PROJECT_NAME/src/styles" \
    "$PROJECT_NAME/src/hooks" "$PROJECT_NAME/src/utils"
  touch "$PROJECT_NAME/src/app/store.js" "$PROJECT_NAME/src/App.js" \
    "$PROJECT_NAME/src/index.js" "$PROJECT_NAME/src/styles/tailwind.css"
  touch "$PROJECT_NAME/jsconfig.json" "$PROJECT_NAME/tailwind.config.js"
}

# Function to setup React Router and Redux Toolkit with pokemonApi setup
setup_react_router_redux_toolkit() {
  echo "Setting up React Router and Redux Toolkit..."
  cat <<EOF > "$PROJECT_NAME/src/App.js"
import React from 'react';
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

  cat <<EOF > "$PROJECT_NAME/src/app/store.js"
import { configureStore } from '@reduxjs/toolkit';
import { pokemonApi } from '../features/api/pokemonApi';
import { persistReducer, persistStore } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

const persistConfig = {
  key: 'root',
  storage,
};

const persistedReducer = persistReducer(persistConfig, {
  [pokemonApi.reducerPath]: pokemonApi.reducer,
});

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(pokemonApi.middleware),
});

export const persistor = persistStore(store);
EOF

  cat <<EOF > "$PROJECT_NAME/src/features/api/pokemonApi.js"
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const pokemonApi = createApi({
  reducerPath: 'pokemonApi',
  baseQuery: fetchBaseQuery({ baseUrl: '$API_URL' }),
  endpoints: (builder) => ({
    getPokemons: builder.query({
      query: () => 'pokemon',
    }),
    getPokemonById: builder.query({
      query: (id) => \`pokemon/\${id}\`,
    }),
    addPokemon: builder.mutation({
      query: (newPokemon) => ({
        url: 'pokemon',
        method: 'POST',
        body: newPokemon,
      }),
    }),
    updatePokemon: builder.mutation({
      query: ({ id, updatedPokemon }) => ({
        url: \`pokemon/\${id}\`,
        method: 'PUT',
        body: updatedPokemon,
      }),
    }),
    deletePokemon: builder.mutation({
      query: (id) => ({
        url: \`pokemon/\${id}\`,
        method: 'DELETE',
      }),
    }),
  }),
});

export const {
  useGetPokemonsQuery,
  useGetPokemonByIdQuery,
  useAddPokemonMutation,
  useUpdatePokemonMutation,
  useDeletePokemonMutation,
} = pokemonApi;
EOF

  cat <<EOF > "$PROJECT_NAME/src/pages/Home.js"
import React from 'react';
import { Helmet } from 'react-helmet';
import {
  useGetPokemonsQuery,
  useDeletePokemonMutation,
} from '../features/api/pokemonApi';

function Home() {
  const { data: pokemons, error, isLoading, isError } = useGetPokemonsQuery();
  const [deletePokemon] = useDeletePokemonMutation();

  const handleDelete = async (pokemonId) => {
    try {
      await deletePokemon(pokemonId).unwrap();
    } catch (err) {
      console.error('Failed to delete Pokémon:', err);
    }
  };

  if (isLoading) return <div>Loading...</div>;
  if (isError) return <div>Error: {error.message}</div>;

  return (
    <div className="p-4">
      <Helmet>
        <title>Pokémon List</title>
      </Helmet>
      <h1 className="text-xl">Pokémon List</h1>
      <div>
        {pokemons.map((pokemon) => (
          <div key={pokemon.id} className="border p-2 mb-2">
            <h2>{pokemon.name}</h2>
            <p>{pokemon.type}</p>
            <button onClick={() => handleDelete(pokemon.id)}>Delete</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Home;
EOF

  cat <<EOF > "$PROJECT_NAME/src/pages/About.js"
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

  echo "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > "$PROJECT_NAME/src/styles/tailwind.css"

  echo '{"compilerOptions":{"baseUrl":"src"},"include":["src"]}' > "$PROJECT_NAME/jsconfig.json"

  cat <<EOF > "$PROJECT_NAME/tailwind.config.js"
module.exports = {
  darkMode: 'class',
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
  echo "REACT_APP_API_URL=$API_URL" > "$PROJECT_NAME/.env"
}

# Function to create Dockerfile
create_dockerfile() {
  echo "Creating Dockerfile..."
  cat <<EOF > "$PROJECT_NAME/Dockerfile"
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

# Function to create Docker Compose file
create_docker_compose_file() {
  echo "Creating Docker Compose file..."
  cat <<EOF > "$PROJECT_NAME/docker-compose.yml"
version: '3'
services:
  web:
    build: .
    ports:
      - "$DOCKER_PORT:3000"
    volumes:
      - .:/app
EOF
}

# Function to create GitHub Actions workflow
create_github_actions_workflow() {
  echo "Creating GitHub Actions workflow..."
  mkdir -p "$PROJECT_NAME/.github/workflows"
  cat <<EOF > "$PROJECT_NAME/.github/workflows/ci.yml"
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

      - name: Build and test
        run: |
          npm run build --if-present
          npm test

      - name: Deploy to production
        if: success()
        run: |
          echo "Deploying to production..."
          # Add your deployment script or commands here

  lint:
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

      - name: Lint with ESLint
        run: npm run lint
EOF
}

# Function to initialize versioning and changelog
initialize_versioning_and_changelog() {
  echo "Initializing versioning and changelog..."
  echo "0.1.0" > "$PROJECT_NAME/VERSION"
  cat <<EOF > "$PROJECT_NAME/CHANGELOG.md"
# Changelog
- Initial release
EOF
}

# Main script function
main() {
  initialize_git_repository
  install_dependencies
  setup_eslint_prettier
  setup_directory_structure
  setup_react_router_redux_toolkit
  create_env_file
  create_dockerfile
  create_docker_compose_file
  create_github_actions_workflow
  initialize_versioning_and_changelog

  echo "React.js project setup completed. Enjoy coding with TailwindCSS, Redux Toolkit, and more!"
}

# Run main function
main
