const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
require('dotenv').config({ path: './config.env' });
const { Client } = require('pg');
const bcrypt = require('bcrypt');
const saltRounds = 10
var format = require('pg-format');

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
  MEMBER: 'mem'
}

const GROUP_ACTION_ENUM = {
  REMOVE: 'rem',
  CHANGE: 'chg',
  ADD: 'add',
  GET_ADDED: 'get'
}

const MESSAGE_ACTION_ENUM = {
  REACT: 'rea',
  RECEIVE: 'rec',
  DELETE: 'del'
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
const reset = () => {
  return new Promise(function (resolve, reject) {
  const sql = fs.readFileSync('./server_schema.sql').toString();
    client.query(sql, function (error, results, fields) {
        if (error) {
          reject(error);
        }
      else{
        resolve(
          true
        )
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const login = (body) => {
  return new Promise(function (resolve, reject) {
  const { user_name, password } = body;
    client.query('select user_id, passcode, email FROM users where user_name = $1', [user_name], (error, results) => {
      if (error) {
        reject(error);
      }
      if (results.rows.length == 0) {
        resolve({
          success: false,
          user_id: null,
          email: null,
          message: "Invalid username"
        });
      }
      else {
        bcrypt
        .compare(password, results.rows[0].passcode)
        .then(res => {
          if(!res){
            resolve({
              success: false,
              user_id: null,
              email: null,
              message: "Wrong password"
            })
          }
          else{
            resolve({
              success: true,
              user_id: results.rows[0].user_id,
              email: results.rows[0].email,
              message: "Login successful"
            })
          }
        })
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
        bcrypt
        .genSalt(saltRounds)
        .then(salt => {
          return bcrypt.hash(password, salt)
        })
        .then(hash => {
          client.query('insert into users (user_id, user_name, passcode, email) values ($1, $2, $3, $4)', [user_id, user_name, hash, email], (error, results1) => {
            if (error) {
              reject(error);
            }
            resolve({
              success: true,
              user_id: user_id,
              email: email,
              message: "Voila! You are now a member of our community."
            });
          })
        })
      }
      else {
        resolve({
          success: false,
          user_id: null,
          email: null,
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
        group_id: group_id,
        time_stamp: new Date()
      });
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const check_user = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id } = body;
    client.query('select * from users where user_id = $1', [user_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve(
          false
        )
      }
      else{
        resolve(
          true
        )
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const check_group = (body) => {
  return new Promise(function (resolve, reject) {
    const { group_id } = body;
    client.query('select * from groups where group_id = $1', [group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve(
          false
        )
      }
      else{
        resolve(
          true
        )
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_all_to_participants = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_name, group_id, role, time_stamp } = body;
    client.query('select user_id from users where user_name = $1', [user_name], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve(
          false
        )
      }
      else{
        client.query('select * from participants where user_id = $1 and group_id = $2', [results.rows[0].user_id, group_id], (error, results2) => {
          if (error) {
            reject(error);
          }
          if(results2.rows.length == 0){
            client.query('insert into participants(user_id, group_id, roles) values ($1, $2, $3)', [results.rows[0].user_id, group_id, role], (error, results1) => {
              if (error) {
                reject(error);
              }
              client.query('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values ($1, $2, $3, $4, $5, $6)', [results.rows[0].user_id, group_id, results.rows[0].user_id, role, time_stamp, GROUP_ACTION_ENUM.GET_ADDED], (error, results3) => {
                if (error) {
                  reject(error);
                }
                resolve(
                  true
                );
              })
            })
          }
          else{
            resolve(
              true
            )
          }
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const new_message = (body) => {
  return new Promise(function (resolve, reject) {
    const { sender_id, group_id, link } = body;
    link_id = uuidv4();
    time_stamp = new Date();
    client.query('insert into links (link_id, sender_id, group_id, title, link, info, time_stamp) values ($1, $2, $3, $4, $5, $6, $7)', [link_id, sender_id, group_id, link.title, link.link, link.info, time_stamp], (error, results) => {
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

const add_tags = (body) => {
  return new Promise(function (resolve, reject) {
    const { tag_list } = body;
    var values = tag_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into tags (link_id, tags) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_send_message_to_message_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { add_message_list } = body;
    var values = add_message_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into message_actions (receiver_id, sender_id, link_id, time_stamp, action_type) values %L', values), [], (error, results) => {
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
    client.query('select users.user_id, users.user_name, participants.roles from participants, users where group_id = $1 and users.user_id = participants.user_id', [group_id], (error, results) => {
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
    const { user_id, kicker_id, group_id } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [kicker_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve(
          false
        )
      }
      else{
        if(results.rows[0].roles != ROLE_ENUM.ADMIN){
          resolve(
            false
          )
        }
        else{
          client.query('delete from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results1) => {
            if (error) {
              reject(error);
            }
            time_stamp = new Date()
            client.query('insert into group_actions(receiver_id, group_id, affected_id, time_stamp, action_type) values ($1, $2, $3, $4, $5)', [user_id, group_id, user_id, time_stamp, GROUP_ACTION_ENUM.REMOVE], (error, results) => {
              if (error) {
                reject(error);
              }
              resolve({
                time_stamp: time_stamp
              });
            })
          })
        }
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_remove_user_to_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { remove_member_list } = body;
    var values = remove_member_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into group_actions(receiver_id, group_id, affected_id, time_stamp, action_type) values %L', values), [], (error, results) => {
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
    const { user_id, group_id, changer_id, role } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [changer_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length != 0){
        if(results.rows[0].roles != ROLE_ENUM.ADMIN){
          resolve({
            success: false,
            message: "You are not an admin of this group",
            time_stamp: new Date()
          })
        }
        else{
          client.query('update participants set roles = $1 where user_id = $2 and group_id = $3', [role, user_id, group_id], (error, results1) => {
            if (error) {
              reject(error);
            }
            resolve({
              success: true,
              message: "Role changed successfully",
              time_stamp: new Date()
            });
          })
        }
      }
      else{
        resolve({
          success: false,
          message: "You are not a member of this group",
          time_stamp: new Date()
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_change_role_to_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { change_role_list } = body;
    var values = change_role_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_one_to_participants = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, user_name, group_id, affected_role } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows[0].roles != ROLE_ENUM.ADMIN){
        resolve({
          success: false,
          message: "You are not an admin",
          new_member_id: null,
          time_stamp: new Date()
        })
      }
      else{
        client.query('select user_id from users where user_name = $1', [user_name], (error, results1) => {
          if (error) {
            reject(error);
          }
          if(results1.rows.length == 0){
            resolve({
              success: false,
              message: "User not found",
              new_member_id: null,
              time_stamp: new Date()
            })
          }
          else{
            client.query('insert into participants(user_id, group_id, roles) values ($1, $2, $3)', [results1.rows[0].user_id, group_id, affected_role], (error, results2) => {
              if (error) {
                reject(error);
              }
              time_stamp = new Date();
              client.query('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values ($1, $2, $3, $4, $5, $6)', [results1.rows[0].user_id, group_id, results1.rows[0].user_id, affected_role, time_stamp, GROUP_ACTION_ENUM.GET_ADDED], (error, results3) => {
                if (error) {
                  reject(error);
                }
                resolve({
                  success: true,
                  message: "User added successfully",
                  new_member_id: results1.rows[0].user_id,
                  time_stamp: time_stamp
                });
              })
            })
          }
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_new_member_to_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { add_user_list } = body;
    var values = add_user_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into group_actions(receiver_id, group_id, affected_id, affected_role, time_stamp, action_type) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const remove_link = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, link_id, group_id } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve({
          success: false,
          time_stamp: new Date()
        })
      }
      else{
        if(results.rows[0].roles != ROLE_ENUM.ADMIN){
          client.query('select sender_id from links where link_id = $1 and sender_id = $2', [link_id, user_id], (error, results1) => {
            if (error) {
              reject(error);
            }
            if(results1.rows.length == 0){
              resolve({
                success: false,
                time_stamp: new Date()
              })
            }
            else{
              resolve({
                success: true,
                time_stamp: new Date()
              });
            }
          })
        }
        else{
          resolve({
            success: true,
            time_stamp: new Date()
          });
        }
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_delete_message_to_message_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { delete_list } = body;
    var values = delete_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into message_actions(receiver_id, sender_id, link_id, time_stamp, action_type) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const react_to_link = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, link_id, react } = body;

    client.query('select * from reacts where user_id = $1 and link_id = $2', [user_id, link_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length != 0){
        
        if(react == 'n'){
          client.query('delete from reacts where user_id = $1 and link_id = $2', [user_id, link_id], (error, results1) => {
            if (error) {
              reject(error);
            }
          })
          return;
        }else{
          client.query('update reacts set react = $1 where user_id = $2 and link_id = $3', [react, user_id, link_id], (error, results1) => {
            if (error) {
              reject(error);
            }
            resolve({
              time_stamp: new Date()
            });
          })
          
        }
        
      }
      else{
        client.query('insert into reacts(user_id, link_id, react) values ($1, $2, $3)', [user_id, link_id, react], (error, results2) => {
          if (error) {
            reject(error);
          }
          resolve({
            time_stamp: new Date()
          });
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const add_react_to_message_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { react_list } = body;
    var values = react_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into message_actions(receiver_id, sender_id, link_id, time_stamp, action_type) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_new_messages = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select links.link_id, links.sender_id, links.group_id, links.title, links.link, links.info, links.time_stamp from message_actions, links where message_actions.link_id = links.link_id and message_actions.receiver_id = $1 and message_actions.time_stamp >= $2 and message_actions.action_type = $3', [user_id, time_stamp, MESSAGE_ACTION_ENUM.RECEIVE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_del_messages = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select link_id from message_actions where receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, MESSAGE_ACTION_ENUM.DELETE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_reacts = (body) => {
  return new Promise(async (resolve, reject) => {
    const { user_id, time_stamp } = body;
    try {
      const results = await client.query('select sender_id, link_id from message_actions where receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, MESSAGE_ACTION_ENUM.REACT]);
      const promises = [];

      for (let i = 0; i < results.rows.length; i++) {
        const promise = new Promise((resolve, reject) => {
          client.query('select react from reacts where user_id = $1 and link_id = $2', [results.rows[i].sender_id, results.rows[i].link_id], (error, results1) => {
            if (error) {
              reject(error);
            } else {
              resolve(results1.rows[0].react);
            }
          });
        });
        promises.push(promise);
      }
      const reactArray = await Promise.all(promises);
      for (let i = 0; i < results.rows.length; i++) {
        results.rows[i]['react'] = reactArray[i];
      }
      resolve(results.rows);
    } 
    catch (error) {
      reject(error);
    }
  });
};

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_role_changes = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select group_id, affected_id, affected_role from group_actions where receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, GROUP_ACTION_ENUM.CHANGE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_removed_members = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select affected_id, group_id from group_actions where receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, GROUP_ACTION_ENUM.REMOVE], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_added_members = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select users.user_name, group_actions.affected_id as user_id, group_actions.group_id, group_actions.affected_role as role from group_actions, users where users.user_id = group_actions.affected_id and receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, GROUP_ACTION_ENUM.ADD], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_deleted_groups = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select group_id from delete_groups where receiver_id = $1 and time_stamp >= $2', [user_id, time_stamp], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_new_groups = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, time_stamp } = body;
    client.query('select group_actions.group_id, group_actions.affected_role, groups.group_name, groups.group_info from group_actions, groups where group_actions.group_id = groups.group_id and receiver_id = $1 and time_stamp >= $2 and action_type = $3', [user_id, time_stamp, GROUP_ACTION_ENUM.GET_ADDED], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results.rows);
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const get_tags = (body) => {
  return new Promise(function (resolve, reject) {
    const { link_id } = body;
    client.query('select tags from tags where link_id = $1', [link_id], async(error, results) => {
      if (error) {
        reject(error);
      }
      const promises = [];
      for (let i = 0; i < results.rows.length; i++) {
        promises.push(new Promise((resolve, reject) => {
          const tags = results.rows[i].tags;
          resolve(tags);
        }));
      }
      const response = await Promise.all(promises);
      resolve(response);
    });
  });
};

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const delete_old_links = () => {
  return new Promise(function (resolve, reject) {
    const currentDate = new Date();
    const weekBeforeDate = new Date(currentDate.getTime() - (process.env.WINDOW_LENGTH * 24 * 60 * 60 * 1000));
    client.query('delete from links where time_stamp < $1', [weekBeforeDate], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve(results);
    });
  });
};

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const check_admin = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve({
          success: false,
          message: "You are not a member of this group"
        })
      }
      else if(results.rows[0].roles != ROLE_ENUM.ADMIN){
        resolve({
          success: false,
          message: "You are not an admin"
        })
      }
      else{
        resolve({
          success: true,
          message: "Group deleted"
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const leave_group = (body) => {
  return new Promise(function (resolve, reject) {
    const { user_id, group_id } = body;
    client.query('select roles from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      if(results.rows.length == 0){
        resolve({
          success: false,
          message: "You are not a member of this group"
        })
      }
      else if(results.rows[0].roles != ROLE_ENUM.ADMIN){
        client.query('delete from participants where user_id = $1 and group_id = $2', [user_id, group_id], (error, results1) => {
          if (error) {
            reject(error);
          }
          resolve({
            success: true,
            message: "You are no longer a member of this group"
          })
        })
      }
      else{
        client.query('select * from participants where user_id != $1 and group_id = $2 and roles = $3', [user_id, group_id, ROLE_ENUM.ADMIN], (error, results2) => {
          if (error) {
            reject(error);
          }
          if(results2.rows.length == 0){
            resolve({
              success: false,
              message: "You cannot leave the group"
            })
          }
          else{
            resolve({
              success: true,
              message: "You are no longer a member of this group"
            })
          }
        })
      }
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const delete_group_action = (body) => {
  return new Promise(function (resolve, reject) {
    const { delete_group_list } = body;
    var values = delete_group_list;
    if(values.length == 0){
      resolve()
    }
    client.query(format('insert into delete_groups(receiver_id, group_id, time_stamp) values %L', values), [], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

const delete_group = (body) => {
  return new Promise(function (resolve, reject) {
    const { group_id } = body;
    client.query('delete from groups where group_id = $1', [group_id], (error, results) => {
      if (error) {
        reject(error);
      }
      resolve();
    })
  })
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------

module.exports = {
  reset,
  login,
  signup,
  new_group,
  check_user,
  check_group,
  add_all_to_participants,
  new_message,
  add_tags,
  add_send_message_to_message_action,
  add_remove_user_to_group_action,
  get_group_members,
  remove_from_participants,
  change_role,
  add_change_role_to_group_action,
  add_one_to_participants,
  add_new_member_to_group_action,
  remove_link,
  add_delete_message_to_message_action,
  react_to_link,
  add_react_to_message_action,
  get_new_messages,
  get_del_messages,
  get_reacts,
  get_role_changes,
  get_removed_members,
  get_added_members,
  get_deleted_groups,
  get_new_groups,
  get_tags,
  delete_old_links,
  check_admin,
  delete_group_action,
  delete_group,
  leave_group
}