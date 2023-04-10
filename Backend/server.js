const express = require("express");
const query = require('./query');

const app = express();

// set port, listen for requests
const PORT = process.env.BACKEND_PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Credentials", "true");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

// parsing the incoming data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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

app.post('/reset', (req, res) => {
  query.reset()
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
    .then(async response => {
      temp = "These users"
      success = true;
      for(let i = 0; i < req.body.members.length; i++){
        temp_body = {user_name : req.body.members[i].participant_name, group_id : response.group_id, role : req.body.members[i].role, time_stamp : response.time_stamp}
        await query.add_all_to_participants(temp_body)
        .then(response1 => {
          if(!response1){
            if(success){
              temp += (req.body.members[i].participant_name)
            }
            else{
              temp += (", " + req.body.members[i].participant_name)
            }
            success = false;
          }
        })
      }
      temp += " are not a member of our community."
      await query.get_group_members({group_id : response.group_id})
      .then(response2 => {
        response["members"] = response2;
        response["success"] = success;
        response["message"] = temp;
        res.status(200).send(response);
      })
    })
    .catch(error => {
      console.log(error)
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.get('/get_updates', (req, res) => {
  all_updates = {"time_stamp": new Date()}
  query.get_new_messages(req.query)
    .then(async response => {
      all_updates["new_messages"] = response;
      for(let i = 0; i < all_updates["new_messages"].length; i++){
        temp_body = {"link_id": all_updates["new_messages"][i].link_id}
        await query.get_tags(temp_body)
        .then(response8 => {
          all_updates["new_messages"][i]["tags"] = response8;
        })
      }
  query.get_del_messages(req.query)
    .then(response1 => {
      all_updates["delete_messages"] = response1;
  query.get_reacts(req.query)
    .then(response2 => {
      all_updates["react"] = response2;  
  query.get_role_changes(req.query)
    .then(response3 => {
      all_updates["change_role"] = response3;
  query.get_removed_members(req.query)
    .then(response4 => {
      all_updates["remove_member"] = response4;
  query.get_added_members(req.query)
    .then(response5 => {
      all_updates["add_user"] = response5;
  query.get_new_groups(req.query)
    .then(async response6 => {
      all_updates["get_added"] = response6;
      for(let i = 0; i < all_updates["get_added"].length; i++){
        temp_body = {"group_id": all_updates["get_added"][i].group_id}
        await query.get_group_members(temp_body)
        .then(response7 => {
          all_updates["get_added"][i]["members"] = response7;
        })
      }
      res.status(200).send(all_updates);
    })
    .catch(error => {
      res.status(500).send(error);
    })
  })
  })
  .catch(error => {
    res.status(500).send(error);
  })
  })
  .catch(error => {
    res.status(500).send(error);
  })
  })
  .catch(error => {
    res.status(500).send(error);
  })
  })
  .catch(error => {
    res.status(500).send(error);
  })
  })
  .catch(error => {
    res.status(500).send(error);
  })
})


//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/send_message', (req, res) => {
  query.new_message(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.sender_id){
            temp_body = {receiver_id : response1[i].user_id, sender_id : req.body.sender_id, link_id : response.link_id, time_stamp : response.time_stamp}
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
            temp_body = {receiver_id : response1[i].user_id, sender_id: req.body.sender_id, link_id: req.body.link_id, time_stamp: response.time_stamp}
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
  query.remove_link(req.body)
    .then(response => {
      if(response.success){
        temp_body = {group_id: req.body.group_id}
        query.get_group_members(temp_body)
        .then(response1 => {
          for(let i = 0; i < response1.length; i++){
            if(response1[i].user_id != req.body.user_id){
              temp_body = {receiver_id : response1[i].user_id, sender_id: req.body.user_id, link_id: req.body.link_id, time_stamp: response.time_stamp}
              query.add_delete_message_to_message_action(temp_body);
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

app.post('/add_user', (req, res) => {
  temp_body = {user_id: req.body.user_id, user_name: req.body.new_member_name, affected_role: req.body.new_member_role, group_id: req.body.group_id}
  query.add_one_to_participants(temp_body)
    .then(response => {
      if(response.success){
        temp_body = {group_id: req.body.group_id}
        query.get_group_members(temp_body)
        .then(response1 => {
          for(let i = 0; i < response1.length; i++){
            if(response1[i].user_id != req.body.user_id && response1[i].user_id != response.new_member_id){
              temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: response.new_member_id, affected_role: req.body.new_member_role, time_stamp: response.time_stamp}
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
      if(response.success){
        temp_body = {group_id: req.body.group_id}
        query.get_group_members(temp_body)
        .then(response1 => {
          for(let i = 0; i < response1.length; i++){
            if(response1[i].user_id != req.body.user_id){
              temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.user_id, affected_role: req.body.role, time_stamp: response.time_stamp}
              query.add_change_role_to_group_action(temp_body);
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

app.get('/dummy', async (req, res) => {
  l = [];
  for(let i = 0; i < 3; i++){
    response1 = await query.get_group_members({group_id: '4a952228-37cf-4fa7-b3f2-b8d9d5352543'});
    console.log(response);
    l.push("response");
  }
  console.log(l);
  res.send(l);
})
