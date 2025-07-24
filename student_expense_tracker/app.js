import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Expense from './models/expense.js';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';


dotenv.config();
const app = express();
const PORT = 3000;

// Set __dirname manually
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// MongoDB connection
mongoose.connect('mongodb+srv://stuadmin:5dL9qSWYm2mqnluD@cluster0.weiu5bx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB error:', err));

// Routes
app.get('/', (req, res) => {
  res.render('form');
});

app.post('/add-expense', async (req, res) => {
  const { title, amount, category, priority, reason } = req.body;
  try {
    const newExpense = new Expense({
      title,
      amount: parseFloat(amount),
      category,
      priority,
      reason,
    });
    await newExpense.save();
   res.redirect('/expenses');
  } catch (err) {
    res.status(400).send('Failed to save expense: ' + err.message);
  }
});

// Show edit form
app.get('/edit/:id', async (req, res) => {
  const expense = await Expense.findById(req.params.id);
  res.render('edit', { expense });
});

// Handle update
app.post('/edit/:id', async (req, res) => {
  const { title, amount, category, priority, reason } = req.body;
  await Expense.findByIdAndUpdate(req.params.id, {
    title,
    amount,
    category,
    priority,
    reason,
  });
  res.redirect('/expenses');
});

// Handle delete
app.post('/delete/:id', async (req, res) => {
  await Expense.findByIdAndDelete(req.params.id);
  res.redirect('/expenses');
});

app.get('/expenses', async (req, res) => {
  const expenses = await Expense.find().sort({ date: -1 });
  res.render('expenses', { expenses });
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
