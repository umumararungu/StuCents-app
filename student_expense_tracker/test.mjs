// test.js
import { jest } from '@jest/globals';
import mongoose from 'mongoose';
import request from 'supertest';
import { MongoMemoryServer } from 'mongodb-memory-server';
import Expense from './models/expense.js';
import express from 'express';
import app from './app.js'; // <-- export your Express app separately for testing

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  await new Promise((resolve) => mongoose.connection.once('open', resolve));
});

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) {
    await mongoServer.stop();
  }
});

afterEach(async () => {
  await Expense.deleteMany();
});


describe('StuCents Expense API', () => {
  test('POST /add-expense should add a new expense', async () => {
    const res = await request(app)
      .post('/add-expense')
      .send({
        title: 'Lunch',
        amount: 1200,
        category: 'Food',
        priority: 'Need',
        reason: 'Daily meal',
      });
    expect(res.status).toBe(302); // because of redirect
    const expenses = await Expense.find();
    expect(expenses.length).toBe(1);
    expect(expenses[0].title).toBe('Lunch');
  });

  test('GET /expenses should return all expenses', async () => {
    await Expense.create({
      title: 'Bus Ticket',
      amount: 500,
      category: 'Transport',
      priority: 'Need',
    });
    const res = await request(app).get('/expenses');
    expect(res.status).toBe(200);
    expect(res.text).toContain('Bus Ticket'); // Rendered EJS content
  });

  test('POST /edit/:id should update an expense', async () => {
    const expense = await Expense.create({
      title: 'Movie',
      amount: 1000,
      category: 'Entertainment',
      priority: 'Want',
    });

    const res = await request(app)
      .post(`/edit/${expense._id}`)
      .send({
        title: 'Movie Night',
        amount: 1500,
        category: 'Entertainment',
        priority: 'Luxury',
      });
    expect(res.status).toBe(302);
    const updated = await Expense.findById(expense._id);
    expect(updated.title).toBe('Movie Night');
    expect(updated.amount).toBe(1500);
  });

  test('POST /delete/:id should delete an expense', async () => {
    const expense = await Expense.create({
      title: 'Snacks',
      amount: 300,
      category: 'Food',
      priority: 'Want',
    });

    const res = await request(app).post(`/delete/${expense._id}`);
    expect(res.status).toBe(302);
    const found = await Expense.findById(expense._id);
    expect(found).toBeNull();
  });


});
