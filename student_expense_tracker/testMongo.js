import dotenv from 'dotenv';
import mongoose from 'mongoose';

dotenv.config();


const uri = process.env.MONGO_URI;

mongoose.connect(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => {
  console.log("✅ Successfully connected to MongoDB Atlas!");
  mongoose.connection.close(); // Close connection after success
})
.catch((err) => {
  console.error("❌ MongoDB connection error:", err);
});
