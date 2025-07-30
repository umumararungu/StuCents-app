# Use official Node.js base image
FROM node:18

# Set working directory inside container
WORKDIR /app

# Copy app source code from the subdirectory
COPY student_expense_tracker/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app files
COPY student_expense_tracker/. .

# Expose app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]