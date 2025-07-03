import fs from 'fs';

const FILE = './expenses.json';

function loadExpenses() {
  if (!fs.existsSync(FILE)) return [];
  const data = fs.readFileSync(FILE, 'utf-8');
  return JSON.parse(data);
}

function saveExpenses(expenses) {
  fs.writeFileSync(FILE, JSON.stringify(expenses, null, 2));
}

export function addExpense(expense) {
  const expenses = loadExpenses();
  expenses.push({ ...expense, date: new Date().toISOString() });
  saveExpenses(expenses);
  console.log('Expense added!');
}

export function listExpenses() {
  const expenses = loadExpenses();
  if (expenses.length === 0) {
    console.log('No expenses found.');
    return;
  }
  expenses.sort((a, b) => {
    const priorityOrder = { high: 1, medium: 2, low: 3 };
    return priorityOrder[a.priority] - priorityOrder[b.priority];
  });
  console.table(expenses);
}

