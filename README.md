# StuCents – Student Expense Tracker

StuCents is a Node.js and MongoDB-based web app that helps students track their spending and prioritize needs-based expenses.

## 🚀 Features

- Add, view, and categorize expenses
- Prioritize based on needs
- RESTful API with Express
- MongoDB data storage

---

## 🐳 Docker-based Setup Instructions

### ✅ Prerequisites

- Docker installed: [Install Docker](https://docs.docker.com/get-docker/)
- MongoDB URI (MongoDB Atlas or local instance)
- `.env` file with:

```env
PORT=3000
MONGODB_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/stucents
