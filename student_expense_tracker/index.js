import readline from 'readline';
import { addExpense, listExpenses } from './utils/expenseManager.js';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function mainMenu() {
  console.log('\n--- Student Expense Tracker ---');
  console.log('1. Add Expense');
  console.log('2. View Expenses');
  console.log('3. Exit');
  rl.question('Choose an option: ', async (option) => {
    if (option === '1') {
      rl.question('Category: ', (category) => {
        rl.question('Amount: ', (amount) => {
          rl.question('Priority (high/medium/low): ', (priority) => {
            addExpense({ category, amount: parseFloat(amount), priority });
            mainMenu();
          });
        });
      });
    } else if (option === '2') {
      listExpenses();
      mainMenu();
    } else {
      rl.close();
    }
  });
}

mainMenu();

