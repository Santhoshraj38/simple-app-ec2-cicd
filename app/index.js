const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Main Root Endpoint
app.get('/', (req, res) => {
  res.json({
    status: "success",
    message: "Welcome to the Simple Node.js Application!",
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString(),
    features: [
      "Containerized deployment",
      "CI/CD deployment pipeline",
      "Terraform managed infrastructure"
    ]
  });
});

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: "UP",
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Start server if this file is run directly
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}

module.exports = app;
