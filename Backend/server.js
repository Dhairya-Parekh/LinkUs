const express = require("express");
const query = require('./query');


const app = express();

// set port, listen for requests
const PORT = process.env.BACKEND_PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});

// app.use((req, res, next) => {
//   res.header("Access-Control-Allow-Origin", "http://localhost:3000");
//   res.header("Access-Control-Allow-Credentials", "true");
//   res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
//   next();
// });

// parsing the incoming data
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

//-------------------------------------------------------------------------------------------------------------------------------------------------------
query.get_group_members({group_id: 123})
app.post('/login', (req, res) => {
  query.login(req.body)
    .then(response => {
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/signup', (req, res) => {
  query.signup(req.body)
    .then(response => {
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/create_group', (req, res) => {
  query.new_group(req.body)
    .then(response => {
      temp = []
      success = true;
      for(let i = 0; i < req.body.members.length; i++){
        temp_body = {user_name : req.body.members[i].participants_name, group_id : response.group_id, role : req.body.members[i].role, time_stamp : response.time_stamp}
        query.add_all_to_participants(temp_body)
        .then(response1 => {
          if(!reponse){
            success = false;
           temp.push(temp.req.body.members[i].participants_name)
          }
        })
      }
      response["success"] = success;
      response["message"] = temp;
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.get('/get_updates', (req, res) => {
  all_updates = {"time_stamp": new Date()}
  query.get_new_messages(req.query)
    .then(response => {
      all_updates["new_messages"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_del_messages(req.query)
    .then(response => {
      all_updates["delete_messages"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_reacts(req.query)
    .then(response => {
      all_updates["react"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_role_changes(req.query)
    .then(response => {
      all_updates["change_role"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_removed_members(req.query)
    .then(response => {
      all_updates["remove_member"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_added_members(req.query)
    .then(response => {
      all_updates["add_user"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  //----------------------------------
  query.get_new_groups(req.query)
    .then(response => {
      all_updates["get_added"] = response;
    })
    .catch(error => {
      res.status(500).send(error);
    })
  res.status(200).send(all_updates);
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/send_message', (req, res) => {
  query.new_message(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, sender_id : req.body.user_id, link_id : response.link_id, time_stamp : response.time_stamp}
            query.add_send_message_to_message_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/react', (req, res) => {
  temp_body = {user_id: req.body.sender_id, link_id: req.body.link_id, react: req.body.react}
  query.react_to_link(temp_body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.sender_id){
            temp_body = {receiver_id : response1[i].user_id, sender_id: req.body.user_id, link_id: req.body.link_id, time_stamp: response.time_stamp}
            query.add_react_to_message_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/delete_message', (req, res) => {
  temp_body = {link_id: req.body.link_id}
  query.remove_link(temp_body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, sender_id: req.body.user_id, link_id: req.body.link_id, time_stamp: response.time_stamp}
            query.add_delete_message_to_message_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/add_user', (req, res) => {
  temp_body = {user_id: req.body.user_id, user_name: req.body.new_member_name, role: req.body.new_member_role, group_id: req.body.group_id}
  query.add_one_to_participants(temp_body)
    .then(response => {
      if(response.success){
        temp_body = {group_id: req.body.group_id}
        query.get_group_members(temp_body)
        .then(response1 => {
          for(let i = 0; i < response1.length; i++){
            if(response1[i].user_id != req.body.user_id && response1[i].user_id != response.new_member_id){
              temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: response.new_member_id, affected_role: req.body.role, time_stamp: response.time_stamp}
              query.add_new_member_to_group_action(temp_body);
            }
          }
        })
      }
      
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/change_role', (req, res) => {
  query.change_role(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.user_id, affected_role: req.body.role, time_stamp: response.time_stamp}
            query.add_change_role_to_group_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/remove_member', (req, res) => {
  query.remove_from_participants(req.body)
    .then(response => {
      if(response){
        temp_body = {group_id: req.body.group_id}
        query.get_group_members(temp_body)
        .then(response1 => {
          for(let i = 0; i < response1.length; i++){
            if(response1[i].user_id != req.body.kicker_id){
              temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.user_id, time_stamp: response.time_stamp}
              query.add_remove_user_to_group_action(temp_body);
            }
          }
          response["success"] = true;
          response["message"] = "User Removed";
          res.status(200).send(response);
        })      
      }
      else{
        response = {}
        response["success"] = false;
        response["message"] = "User Not Removed";
        response["time_stamp"] = Date.now();
        res.status(200).send(response);
      }
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------