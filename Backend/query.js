const { v4: uuidv4 } = require('uuid');
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

const MESSAGE_ACTION_ENUM = {
  REACT: 'rea',
  DELETE: 'del',
  REC: 'rec',
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
    time_stamp = Date.now();
    client.query('insert into links (link_id, sender_id, group_id, title, link, info, timestamp) values ($1, $2, $3, $4, $5, $6, $7)', [link_id, sender_id, group_id, link.title, link.link, link.info, time_stamp], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve({
        link_id: link_id,
        time_stamp: time_stamp
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_send_message_to_message_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { receiver_id, sender_id, link_id } = body;
    client.query('insert into message_actions(receiver_id, sender_id, link_id, time_stamp, action_type) values ($1, $2, $3, $4, $5)', [receiver_id, sender_id, link_id, Date.now(), MESSAGE_ACTION_ENUM.REC], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_group_members = (body) => {
  return new Promise(function (resolve, reject) {
    const { group_id } = body;
    client.query('select user_id from participants where group_id = $1', [group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(
        results.rows
      );
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const remove_from_participants = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('delete from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve({
        time_stamp: Date.now()
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_remove_user_to_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { receiver_id, group_id, affected_id, time_stamp } = body;
    client.query('insert into group_actions(receiver_id, group_id, affected_id, time_stamp, action_type) values ($1, $2, $3, $4, $5)', [receiver_id, group_id, affected_id, time_stamp, GROUP_ACTION_ENUM.REMOVE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const change_role = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id, role } = body;
    client.query('update participants set role = $1 where user_id = $2 and group_id = $3', [role, user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve({
        time_stamp: Date.now()
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_change_role_to_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { receiver_id, group_id, affected_id, affected_role, time_stamp } = body;
    client.query('insert into group_actions(receiver_id, group_id, affected_id, affcted_role, time_stamp, action_type) values ($1, $2, $3, $4, $5, $6)', [receiver_id, group_id, affected_id, affected_role, time_stamp, GROUP_ACTION_ENUM.CHANGE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_to_existing = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('insert into participants(user_id, group_id, roles) values ($1, $2, $3)', [user_id, group_id, ROLE_ENUM.MEMBER], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve({
        time_stamp: Date.now()
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

module.exports = {
  login,
  signup,
  new_group,
  add_to_participants,
  new_message,
  add_send_message_to_message_action,
  add_remove_user_to_group_action,
  get_group_members,
  remove_from_participants,
  change_role,
  add_change_role_to_group_action
}