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
    console.log("URL: ", process.env.DATABASE_URL)
  } 
  else {
    console.log('connected')
    console.log("Host: ", process.env.DATABASE_HOST)
    console.log("Database: ", process.env.DATABASE_NAME)
    console.log("User: ", process.env.DATABASE_USER)
    console.log("Password: ", process.env.DATABASE_PASSWORD)
    console.log("URL: ", process.env.DATABASE_URL)
  }
})

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});

app.get('/hello_world',(req,res) => {
  const query = `
    SELECT *
    FROM lol
  `;
  client.query(query, (err, res_q) => {
    if (err) {
      console.error(err);
    } else {
      console.log("Query executed successfully");
      console.log(res_q.rows);
      return res.json(res_q.rows);
    }
  });  
});

app.get('/hello_world2',(req,res) => {
  const query = `create table lol (id serial primary key, name varchar(255) not null);`;
  client.query(query, (err, res_q) => {
    if (err) {
      console.error(err);
    } else {
      console.log("Query create table executed successfully");
      console.log(res_q.rows);
      const query2 = `insert into lol (1, 'test');`;
      client.query(query2, (err, res_q2) => {
        if (err) {
          console.error(err);
        } else {
          console.log("Query insert into table executed successfully");
          console.log(res_q2.rows);
          return res.json(res_q2.rows);
        }
      });
      return res.json(res_q.rows);
    }
  });
});

