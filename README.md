# StuCents – Student Expense Tracker

StuCents is a Node.js and MongoDB-based web app that helps students track their spending and prioritize needs-based expenses.

## Teck Stack

- Node.js + Express
- MongoDB Atlas (cloud database)
- EJS (for HTML views)
- Docker
- Terraform (for Infrastructure as Code)
- Azure Container Apps

---

## Features

- Add and save expenses (title, amount, category, priority, reason)
- View, edit, and delete expenses
- Connects to a secure MongoDB Atlas database
- Deployed to Azure using Docker and Terraform

## Local Setup

### 1. Clone the repository

```bash
git clone https://github.com/umumararungu-cynthia/stucents-app.git
cd stucents-app

- Docker installed: [Install Docker](https://docs.docker.com/get-docker/)
- MongoDB URI (MongoDB Atlas)
- `.env` file with:

```env
PORT=3000
MONGO_URI=mongodb+srv://stuadmin:5dL9qSWYm2mqnluD@cluster0.weiu5bx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
```

## Install Dependencies

``` bash
npm install
```

## Run the App
``` bash
npm start
```

## Demo Video

https://go.screenpal.com/watch/cTiw21nIz07