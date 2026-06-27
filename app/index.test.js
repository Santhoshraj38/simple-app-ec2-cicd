const request = require('supertest');
const app = require('./index');

describe('GET /', () => {
  it('should return a JSON response with welcome message and success status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'success');
    expect(res.body).toHaveProperty('message');
    expect(res.body).toHaveProperty('version', '1.0.0');
    expect(res.body).toHaveProperty('features');
    expect(Array.isArray(res.body.features)).toBe(true);
  });
});

describe('GET /health', () => {
  it('should return 200 OK with UP status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'UP');
    expect(res.body).toHaveProperty('uptime');
    expect(res.body).toHaveProperty('timestamp');
  });
});
