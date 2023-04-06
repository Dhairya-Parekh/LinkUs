import { v4 as uuidv4 } from 'uuid';
require('dotenv').config({ path: './config.env' });
const { Client } = require('pg');

const client = new Client({
  host: process.env.DATABASE_HOST,
  database: process.env.DATABASE_NAME,
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  port: process.env.DATABASE_PORT,
  connectionString: process.env.DATABASE_URL,
});

const ROLE_ENUM = {
  ADMIN: 'adm',
  MEMBER: 'mem',
}

const GROUP_ACTION_ENUM = {
  REMOVE: 'rem',
  CHANGE: 'chg',
  ADD: 'add',
  GET_ADDED: 'get',
}

client.connect((err) => {
  if (err) {
    console.error('connection error', err.stack)
  }
  else {
    console.log('connected to database')
  }
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const login = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_name, password } = body;
    client.query('select user_id FROM users where user_name = $1 and passcode = $2', [user_name, password], (error, results) => {
      if (error) {
        reject(error);
      }
      if (results.rows.length == 0) {
        resolve({
          success: false,
          user_id: null,
          message: "Invalid username or password"
        });
      }
      else {
        resolve({
          success: true,
          user_id: results.rows[0].user_id,
          message: "Login successful"
        });
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const signup = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_name, password, email } = body;
    client.query('select user_id FROM users where user_name = $1', [user_name], (error, results) => {
      if (error) {
        reject(error);
      }
      if (results.rows.length == 0) {
        user_id = uuidv4();
        client.query('insert into users (user_id, user_name, passcode, email_id) values ($1, $2, $3, $4)', [user_id, user_name, password, email], (error, results1) => {
          resolve({
            success: true,
            user_id: user_id,
            message: "Voila! You are now a member of our community."
          });
        })
      }
      else {
        resolve({
          success: false,
          user_id: null,
          message: "Username already exists"
        });
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const new_group = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_name, group_info, members } = body;
    group_id = uuidv4();
    client.query('insert into groups (group_id, group_name, group_info) values ($1, $2, $3)', [group_id, group_name, group_info], (error, results) => {
      if (error) {
        reject(error);
      }
      client.query('insert into participants (group_id, user_id, roles) values ($1, $2, $3)', [group_id, user_id, ROLE_ENUM.ADMIN], (error, results1) => {
        if (error) {
          reject(error);
        }
      })
      resolve({
        group_id: group_id
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_to_participants = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('insert into participants(user_id, group_id, roles) values ($1, $2, $3)', [user_id, group_id, ROLE_ENUM.MEMBER], (error, results) => {
      if (error) {
        reject(error);
      }
      client.query('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values ($1, $2, $3, $4, $5, $6)', [user_id, group_id, user_id, ROLE_ENUM.MEMBER, Date.now(), GROUP_ACTION_ENUM.ADD], (error, results1) => {
        resolve(
          true
        );
      })
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const new_message = (body) => {
  return new Promise(function (resolve, reject) {
    const { sender_id, group_id, link } = body;
    link_id = uuidv4();
    client.query('insert into links (link_id, sender_id, group_id, title, ) values ($1, $2, $3)', [group_id, group_name, group_info], (error, results) => {
      if (error) {
        reject(error);
      }
      client.query('insert into participants (group_id, user_id, roles) values ($1, $2, $3)', [group_id, user_id, ROLE_ENUM.ADMIN], (error, results1) => {
        if (error) {
          reject(error);
        }
      })
      resolve({
        group_id: group_id
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_to_participants = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('insert into participants(user_id, group_id, roles) values ($1, $2, $3)', [user_id, group_id, ROLE_ENUM.MEMBER], (error, results) => {
      if (error) {
        reject(error);
      }
      client.query('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values ($1, $2, $3, $4, $5, $6)', [user_id, group_id, user_id, ROLE_ENUM.MEMBER, Date.now(), GROUP_ACTION_ENUM.ADD], (error, results1) => {
        resolve(
          true
        );
      })
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

module.exports = {
  login,
  signup,
  new_group,
  add_to_participants
}