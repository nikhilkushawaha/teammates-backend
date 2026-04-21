# Teammates Backend

This is the backend service for the Teammates project. It provides a robust REST API and real-time WebSocket communication built with Node.js, Express, MongoDB, and Socket.IO.

## Tech Stack
- **Runtime:** Node.js
- **Language:** TypeScript
- **Framework:** Express.js
- **Database:** MongoDB (with Mongoose)
- **Authentication:** Passport.js (Local & Google OAuth 2.0, Cookie-based Sessions)
- **Real-time:** Socket.IO
- **Validation:** Zod
- **Security:** bcrypt

## Prerequisites
- Node.js (v18+ recommended)
- MongoDB instance (running locally or MongoDB Atlas)
- Docker & Docker Compose (optional, for isolated environments and deployment)

## Local Development Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Environment Configuration:**
   Copy the example environment file and configure it with your settings.
   ```bash
   cp .env.example .env
   ```
   *Ensure you update `.env` with a valid `MONGO_URI`, a `SESSION_SECRET`, and your Google OAuth credentials if using social login.*

3. **Database Seeding (Optional):**
   If you need initial data like user roles, you can run the seeder:
   ```bash
   npm run seed
   ```

4. **Start the Development Server:**
   ```bash
   npm run dev
   ```
   The server will start on `http://localhost:5000` (or the port defined in your `.env` file). It uses `ts-node-dev` for automatic hot-reloading.

## Available Scripts

- `npm run dev`: Starts the development server with hot-reloading.
- `npm run build`: Compiles TypeScript to JavaScript into the `dist/` folder.
- `npm run start`: Runs the compiled node application from the `dist/` folder (used in production).
- `npm run seed`: Executes the database seeders directly using `ts-node`.

## Docker & Deployment

This project includes a comprehensive set of deployment scripts and Docker configurations, making it ready to be shipped anywhere Docker is supported.

### Quick Start with Docker
```bash
docker-compose up --build
```
*Ensure your `.env` is configured properly before spinning up the containers.*

### Deployment Documentation
For automated setup and production deployment processes, refer to the included guides:
- [START_HERE.md](./START_HERE.md) (Entry point for production setup)
- [README_DOCKER_SETUP.md](./README_DOCKER_SETUP.md) (Detailed setup via `setup-docker.sh`)
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) (General deployment concepts)
- [DOCKER_QUICK_REFERENCE.md](./DOCKER_QUICK_REFERENCE.md) (Useful docker commands)

## Authentication Flow
The API is currently structured to support two types of authentication:
1. **Local Authentication:** Standard email/password flow using bcrypt for hashing.
2. **Google OAuth2:** Implemented via Passport.js out of the box.

Authentication state is managed via secure HTTP-only cookies (`cookie-session`).
