const express = require("express");
require('dotenv').config({path:'./config.env'});
const { Client } = require('pg')

const client = new Client({
  host: process.env.DATABASE_HOST,
  database: process.env.DATABASE_NAME,
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  port: process.env.DATABASE_PORT,
  connectionString: process.env.DATABASE_URL,
});

const app = express();

// set port, listen for requests
const PORT = process.env.BACKEND_PORT || 8080;

client.connect((err) => {
  if (err) {
    console.error('connection error', err.stack)
    console.log("Host: ", process.env.DATABASE_HOST)
    console.log("Database: ", process.env.DATABASE_NAME)
    console.log("User: ", process.env.DATABASE_USER)
    console.log("Password: ", process.env.DATABASE_PASSWORD)
  } 
  else {
    console.log('connected')
    console.log("Host: ", process.env.DATABASE_HOST)
    console.log("Database: ", process.env.DATABASE_NAME)
    console.log("User: ", process.env.DATABASE_USER)
    console.log("Password: ", process.env.DATABASE_PASSWORD)
  }
})

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});

app.get('/hello_world',(req,res) => {
  return res.json({ "Hello": "World" });
});

