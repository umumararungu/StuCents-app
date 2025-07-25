# Use official Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR student_expense_tracker

# Copy app files
COPY student_expense_tracker/package*.json ./
RUN npm install
COPY . .

# Expose app port
EXPOSE 3000

# Start the app
CMD ["node", "student_expense_tracker/app.js"]
