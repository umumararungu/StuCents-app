import mongoose from 'mongoose';

const expenseSchema = new mongoose.Schema({
  title: { type: String, required: false },
  amount: { type: Number, required: true, min: 100 },
  category: { type: String, enum: ['Food', 'Transport', 'Entertainment'], required: true },
  priority: { type: String, enum: ['Need', 'Want', 'Luxury'], required: true },
  date: { type: Date, default: Date.now },
  reason: { type: String, required: false },
});

export default mongoose.model('Expense', expenseSchema);
